module View exposing (..)

import Elvanto exposing (Service)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (..)
import Models exposing (..)
import Rocket exposing ((=>))
import Views.Login
import Views.SelectSongs
import Views.Services
import Views.Setup


view : Model -> Html Msg
view model =
    Html.div [ A.id "main" ]
        [ navbar model
        , Html.div [ A.id "content" ] <|
            List.concat
                [ alerts model.alerts
                , viewHelper model
                ]
        ]


viewHelper : Model -> List (Html Msg)
viewHelper model =
    case model.step of
        OauthLink ->
            Views.Login.view model

        Sync ->
            [ Views.Services.view model ]

        Confirm ->
            [ Views.SelectSongs.view model.filesFilter model.matches model.allFiles ]

        Setup tmpConfig ->
            Views.Setup.view False tmpConfig

        FirstRun tmpConfig ->
            Views.Setup.view True tmpConfig


navbar : Model -> Html Msg
navbar model =
    case model.step of
        FirstRun _ ->
            Html.div [] []

        _ ->
            Html.nav [ A.id "navbar" ]
                [ Html.h1
                    [ A.style [ "display" => "block" ] ]
                    [ Html.text "Elv -> ProP" ]
                , Html.a
                    [ A.class "button button-primary button-lg"
                    , A.style [ "display" => "block" ]
                    , E.onClick GoToSetup
                    ]
                    [ Html.text "Setup" ]
                ]


alerts : List Alert -> List (Html Msg)
alerts a =
    List.map alert a


alert : Alert -> Html Msg
alert a =
    Html.div [ A.class <| "alert " ++ alertTypeHelper a.type_ ] [ Html.text a.message ]


settingsLink : Step -> Html Msg
settingsLink step =
    case step of
        Setup _ ->
            Html.text ""

        _ ->
            Html.button [ A.class "button button-primary", E.onClick GoToSetup ] [ Html.text "Setup" ]


alertTypeHelper : AlertType -> String
alertTypeHelper t =
    case t of
        Success ->
            "alert-success"

        Danger ->
            "alert-danger"
