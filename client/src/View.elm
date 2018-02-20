module View exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(..))
import Models exposing (Alert, AlertType(..), Model, Step(..))
import Views.Login
import Views.SelectSongs
import Views.Services
import Views.Setup
import Views.Util exposing (blueButton)


view : Model -> Html Msg
view model =
    Html.div [ A.id "main" ]
        [ navbar model
        , Html.div [ A.class "my-8 mx-4 w-100 min-h-screen" ] <|
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
                [ Html.h1 [] [ Html.text "Elv -> ProP" ]
                , settingsLink model.step
                ]


alerts : List Alert -> List (Html Msg)
alerts a =
    List.map alert a


alert : Alert -> Html Msg
alert a =
    Html.div [ A.attribute "role" "alert", A.class "mb-4" ]
        [ alertHeading a.type_
        , Html.div [ A.class <| alertMainClass a.type_ ]
            [ Html.p [] [ Html.text a.message ]
            ]
        ]


settingsLink : Step -> Html Msg
settingsLink step =
    case step of
        Setup _ ->
            Html.text ""

        _ ->
            blueButton [ A.class "w-full", E.onClick GoToSetup ] [ Html.text "Setup" ]


alertMainClass : AlertType -> String
alertMainClass t =
    case t of
        Success ->
            "border border-t-0 border-green-light rounded-b bg-green-lightest px-4 py-3 text-green-dark"

        Danger ->
            "border border-t-0 border-red-light rounded-b bg-red-lightest px-4 py-3 text-red-dark"


alertHeading : AlertType -> Html Msg
alertHeading t =
    case t of
        Success ->
            Html.div [ A.class "bg-green text-white font-bold rounded-t px-4 py-2" ] [ Html.text "Success" ]

        Danger ->
            Html.div [ A.class "bg-red text-white font-bold rounded-t px-4 py-2" ] [ Html.text "Uh oh!" ]
