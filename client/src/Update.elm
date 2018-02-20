module Update exposing (update)

import Http
import Messages exposing (Msg(..))
import Models
    exposing
        ( Alert
        , AlertType(..)
        , LoadingStatus(..)
        , Model
        , Step(..)
        , initialStep
        )
import Ports exposing (deleteTokenData, saveTokenData)
import Remote exposing (FetchError(..), bodyToFetchError, chooseReq, confirmReq, fetchServices, saveConfig)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        FetchServices ->
            case model.oauthToken of
                Nothing ->
                    { model | step = OauthLink } ! []

                Just token ->
                    { model | fetchStatus = Loading } ! [ fetchServices token, saveTokenData token ]

        ReceiveServices (Ok services) ->
            { model | services = services, fetchStatus = Finished, alerts = [] } ! []

        ReceiveServices (Err e) ->
            serviceError e model

        ChooseService s ->
            { model | chosenService = Just s, fetchStatus = Loading, alerts = [] } ! [ chooseReq s ]

        ReceiveMatches (Ok ms) ->
            { model | matches = ms, step = Confirm, fetchStatus = Finished } ! []

        ReceiveMatches (Err e) ->
            ( { model | fetchStatus = Finished } |> addDanger (fetchFailedMsg e), Cmd.none )

        ConfirmWrite ms ->
            let
                extras =
                    model.allFiles
                        |> List.filter Tuple.first
                        |> List.map Tuple.second
            in
            case model.chosenService of
                Just s ->
                    { model
                        | fetchStatus = Loading
                        , filesFilter = ""
                        , allFiles = List.map (\( _, s_ ) -> ( False, s_ )) model.allFiles
                    }
                        ! [ confirmReq s ms extras ]

                Nothing ->
                    model ! []

        Cancel ->
            { model | matches = [], step = Sync, alerts = [] } ! []

        ReceiveConfirm (Ok _) ->
            ( { model | step = Sync, fetchStatus = Finished } |> addSuccess "Playlist saved", Cmd.none )

        ReceiveConfirm (Err e) ->
            ( { model | step = Sync, fetchStatus = Finished } |> addDanger (playlistSaveMsg e), Cmd.none )

        UpdateClientId ctor c id ->
            { model | step = ctor { c | client_id = Just id } } ! []

        UpdatePlaylistLocation ctor c path ->
            { model | step = ctor { c | playlist_file_path = Just path } } ! []

        UpdateFilesLocation ctor c path ->
            { model | step = ctor { c | song_library_path = Just path } } ! []

        SaveConfig c ->
            { model
                | config = c
                , step = OauthLink
                , oauthToken = Nothing
            }
                ! [ saveConfig c ]

        CancelConfig ->
            { model | step = initialStep model.config True model.oauthToken } ! []

        ReceiveConfig (Ok c) ->
            { model | config = c } ! []

        ReceiveConfig (Err e) ->
            Debug.crash ("add error handling" ++ toString e)

        ToggleExtraFile name ->
            let
                extraFiles =
                    model.allFiles
                        |> List.map
                            (\( b, n ) ->
                                if n == name then
                                    ( not b, n )
                                else
                                    ( b, n )
                            )
            in
            { model | allFiles = extraFiles } ! []

        GoToSetup ->
            { model | step = Setup model.config } ! []

        UpdateFilesFilter text ->
            { model | filesFilter = text } ! []


addSuccess : String -> Model -> Model
addSuccess msg model =
    { model | alerts = Alert Success msg :: model.alerts }


addDanger : String -> Model -> Model
addDanger msg model =
    { model | alerts = Alert Danger msg :: model.alerts }


fetchFailedMsg : Http.Error -> String
fetchFailedMsg err =
    "That didn't work, try reloading the page.\n\n(" ++ niceHttpError err ++ ")"


playlistSaveMsg : Http.Error -> String
playlistSaveMsg err =
    "That didn't work, your playlist was not saved\n\n(" ++ niceHttpError err ++ ")"


niceHttpError : Http.Error -> String
niceHttpError err =
    case err of
        Http.BadStatus { status } ->
            status.message

        Http.BadUrl _ ->
            "Bad url"

        Http.Timeout ->
            "The request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadPayload _ _ ->
            "Bad Payload"


serviceError : Http.Error -> Model -> ( Model, Cmd Msg )
serviceError e model =
    case e of
        Http.BadStatus resp ->
            let
                respError =
                    bodyToFetchError resp.body
            in
            case respError of
                HttpError ->
                    ( { model
                        | fetchStatus = NotAsked
                        , step = Sync
                      }
                        |> addDanger "We encountered an issue talking to Elvanto, please try again."
                    , Cmd.none
                    )

                NoServices ->
                    ( { model
                        | fetchStatus = NotAsked
                        , step = Sync
                      }
                        |> addDanger "No Services Found on Elvanto"
                    , Cmd.none
                    )

                Elvanto elvError ->
                    case elvError.code of
                        102 ->
                            -- auth error, logout user in case they need to log in again
                            ( { model
                                | fetchStatus = NotAsked
                                , step = OauthLink
                                , oauthToken = Nothing
                              }
                                |> addDanger elvError.message
                            , deleteTokenData ()
                            )

                        _ ->
                            ( { model
                                | fetchStatus = NotAsked
                                , step = Sync
                              }
                                |> addDanger elvError.message
                            , Cmd.none
                            )

                Unknown ->
                    -- unknown error, logout user in case they need to log in again
                    ( { model
                        | fetchStatus = NotAsked
                        , step = OauthLink
                        , oauthToken = Nothing
                      }
                        |> addDanger "We encountered an error, I'm not sure what happened. Try logging in again."
                    , deleteTokenData ()
                    )

        _ ->
            ( { model | fetchStatus = Finished } |> addDanger (fetchFailedMsg e), Cmd.none )
