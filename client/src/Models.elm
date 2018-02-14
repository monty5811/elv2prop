module Models exposing (..)

import Elvanto exposing (Service, ServiceType, Song)
import Json.Decode as Decode
import Json.Decode.Pipeline as P
import Json.Encode as Encode


type alias Flags =
    { oauthToken : Maybe String
    , host : String
    , savedConfig : Config
    , configFromFile : Bool
    , allFiles : List String
    }


type alias Model =
    { step : Step
    , host : String
    , services : List Service
    , chosenService : Maybe Service
    , matches : List Match
    , fetchStatus : LoadingStatus
    , oauthToken : Maybe String
    , alerts : List Alert
    , config : Config
    , allFiles : List ( Bool, String )
    , filesFilter : String
    }


initialModel : Flags -> Maybe String -> Model
initialModel flags maybeUrlToken =
    let
        initialToken =
            case maybeUrlToken of
                Nothing ->
                    case flags.oauthToken of
                        Nothing ->
                            Nothing

                        Just a ->
                            Just a

                Just a ->
                    Just a
    in
    { step = initialStep flags.savedConfig flags.configFromFile initialToken
    , host = flags.host
    , services = []
    , chosenService = Nothing
    , matches = []
    , fetchStatus = NotAsked
    , oauthToken = initialToken
    , alerts = []
    , config = flags.savedConfig
    , allFiles = flags.allFiles |> List.map ((,) False)
    , filesFilter = ""
    }


type alias Alert =
    { type_ : AlertType
    , message : String
    }


type AlertType
    = Success
    | Danger


initialStep : Config -> Bool -> Maybe String -> Step
initialStep config configFromFile maybeToken =
    case configFromFile of
        False ->
            FirstRun config

        True ->
            case maybeToken of
                Just token ->
                    Sync

                Nothing ->
                    OauthLink


type Step
    = OauthLink
    | Sync
    | Confirm
    | Setup Config
    | FirstRun Config


type alias Match =
    { elv : String
    , pro : Maybe String
    }


decodeMatch : Decode.Decoder Match
decodeMatch =
    P.decode Match
        |> P.required "elv" Decode.string
        |> P.required "pro" (Decode.maybe Decode.string)


encodeMatch : Match -> Encode.Value
encodeMatch m =
    Encode.object
        [ ( "elv", Encode.string m.elv )
        , ( "pro", encodeMaybe Encode.string m.pro )
        ]


encodeMatches : List Match -> Encode.Value
encodeMatches ms =
    ms
        |> List.map encodeMatch
        |> Encode.list


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe encoder m =
    case m of
        Just x ->
            encoder x

        Nothing ->
            Encode.null


type alias Config =
    { client_id : Maybe String
    , song_library_path : Maybe String
    , playlist_file_path : Maybe String
    }


encodeConfig : Config -> Encode.Value
encodeConfig c =
    Encode.object
        [ ( "client_id", encodeMaybe Encode.string c.client_id )
        , ( "song_library_path", encodeMaybe Encode.string c.song_library_path )
        , ( "playlist_file_path", encodeMaybe Encode.string c.playlist_file_path )
        ]


decodeConfig : Decode.Decoder Config
decodeConfig =
    P.decode Config
        |> P.required "client_id" (Decode.maybe Decode.string)
        |> P.required "song_library_path" (Decode.maybe Decode.string)
        |> P.required "playlist_file_path" (Decode.maybe Decode.string)


type LoadingStatus
    = NotAsked
    | Loading
    | Finished
