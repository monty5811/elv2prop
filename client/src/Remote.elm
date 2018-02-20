module Remote
    exposing
        ( FetchError(..)
        , bodyToFetchError
        , chooseReq
        , confirmReq
        , fetchServices
        , saveConfig
        )

import Elvanto exposing (Service, decodeService, encodeService)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as P
import Json.Encode as Encode
import Messages exposing (Msg(..))
import Models exposing (Config, Match, decodeConfig, decodeMatch, encodeConfig, encodeMatches)


post : String -> List ( String, Encode.Value ) -> Decode.Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = url
        , body = body |> Encode.object |> Http.jsonBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


fetchServices : String -> Cmd Msg
fetchServices token =
    post "/fetch" [ ( "token", Encode.string token ) ] (Decode.list decodeService)
        |> Http.send ReceiveServices


chooseReq : Service -> Cmd Msg
chooseReq s =
    post "/choose" [ ( "service", encodeService s ) ] (Decode.list decodeMatch)
        |> Http.send ReceiveMatches


confirmReq : Service -> List Match -> List String -> Cmd Msg
confirmReq s ms extras =
    post "/confirm"
        [ ( "service", encodeService s )
        , ( "songs", encodeMatches ms )
        , ( "extras", Encode.list <| List.map Encode.string extras )
        ]
        (Decode.succeed True)
        |> Http.send ReceiveConfirm


saveConfig : Config -> Cmd Msg
saveConfig c =
    post "/update-config" [ ( "config", encodeConfig c ) ] decodeConfig
        |> Http.send ReceiveConfig



-- Errors


bodyToFetchError : String -> FetchError
bodyToFetchError body =
    Decode.decodeString decodeFetchError body
        |> Result.map rawtoFetchError
        |> Result.withDefault Unknown


rawtoFetchError : RawFetchError -> FetchError
rawtoFetchError err =
    case err.msg of
        "No services found on Elvanto" ->
            NoServices

        "We encountered a problem talking to Elvanto, please try again" ->
            HttpError

        "Elvanto API Error" ->
            case err.extra of
                Just extra ->
                    Elvanto extra

                Nothing ->
                    Elvanto unknownElvantoExtra

        _ ->
            Unknown


decodeFetchError : Decode.Decoder RawFetchError
decodeFetchError =
    P.decode RawFetchError
        |> P.required "msg" Decode.string
        |> P.optional "extra" (Decode.maybe decodeElvantoError) Nothing


type alias RawFetchError =
    { msg : String, extra : Maybe ElvantoError }


type FetchError
    = HttpError
    | NoServices
    | Elvanto ElvantoError
    | Unknown


type alias ElvantoError =
    { code : Int
    , message : String
    }


decodeElvantoError : Decode.Decoder ElvantoError
decodeElvantoError =
    P.decode ElvantoError
        |> P.required "code" Decode.int
        |> P.required "message" Decode.string


unknownElvantoExtra : ElvantoError
unknownElvantoExtra =
    { code = 0
    , message = "Unknown Elvanto API Error"
    }
