module Messages exposing (Msg(..))

import Elvanto exposing (Service)
import Http
import Models exposing (Config, Match, Step)


type Msg
    = NoOp
    | FetchServices
    | ReceiveServices (Result Http.Error (List Service))
    | ChooseService Service
    | ReceiveMatches (Result Http.Error (List Match))
    | ConfirmWrite (List Match)
    | Cancel
    | ReceiveConfirm (Result Http.Error Bool)
    | UpdateClientId (Config -> Step) Config String
    | UpdateFilesLocation (Config -> Step) Config String
    | UpdatePlaylistLocation (Config -> Step) Config String
    | SaveConfig Config
    | CancelConfig
    | ReceiveConfig (Result Http.Error Config)
    | ToggleExtraFile String
    | GoToSetup
    | UpdateFilesFilter String
