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
import Remote exposing (chooseReq, confirmReq, fetchServices, saveConfig)


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
            { model | services = services, fetchStatus = Finished } ! []

        ReceiveServices (Err e) ->
            case e of
                Http.BadStatus _ ->
                    ( { model
                        | fetchStatus = NotAsked
                        , step = OauthLink
                        , oauthToken = Nothing
                      }
                    , deleteTokenData ()
                    )

                _ ->
                    ( { model | fetchStatus = Finished } |> addDanger fetchFailedMsg, Cmd.none )

        ChooseService s ->
            { model | chosenService = Just s, fetchStatus = Loading, alerts = [] } ! [ chooseReq s ]

        ReceiveMatches (Ok ms) ->
            { model | matches = ms, step = Confirm, fetchStatus = Finished } ! []

        ReceiveMatches (Err _) ->
            ( { model | fetchStatus = Finished } |> addDanger fetchFailedMsg, Cmd.none )

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

        ReceiveConfirm (Err _) ->
            ( { model | step = Sync, fetchStatus = Finished } |> addDanger "That didn't work, your playlist was not saved", Cmd.none )

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


fetchFailedMsg : String
fetchFailedMsg =
    "That didn't work, try reloading the page."
