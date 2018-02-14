module Views.Services exposing (view)

import Elvanto exposing (Service)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(ChooseService, FetchServices))
import Models exposing (LoadingStatus(Finished, Loading, NotAsked), Model)


view : Model -> Html Msg
view model =
    case model.fetchStatus of
        NotAsked ->
            Html.button [ A.class "button button-success", E.onClick FetchServices ] [ Html.text "Fetch Elvanto Services" ]

        Loading ->
            loadingIndicator

        Finished ->
            serviceList model.services


loadingIndicator : Html Msg
loadingIndicator =
    Html.div []
        [ Html.h3 [] [ Html.text "Loading..." ]
        , Html.div [ A.class "progress progress-lg progress-success progress-indeterminate" ]
            [ Html.div [ A.class "progress-bar" ] []
            ]
        ]


serviceList : List Service -> Html Msg
serviceList services =
    let
        heading =
            case List.length services > 0 of
                True ->
                    "Choose a service to sync"

                False ->
                    "No services found on Elvanto"
    in
    Html.div []
        [ Html.h3 [] [ Html.text heading ]
        , Html.ul [ A.class "serviceList" ] <| List.map serviceView services
        ]


serviceView : Service -> Html Msg
serviceView s =
    case List.length s.songs > 0 of
        True ->
            Html.li
                [ A.class "serviceItem", E.onClick <| ChooseService s ]
                [ Html.text <| s.name ++ " (" ++ s.date ++ ")"
                , Html.span [ A.class "badge badge-success float-right" ] [ Html.text <| toString <| List.length s.songs ]
                ]

        False ->
            Html.li [ A.class "serviceItem disabled" ] [ Html.text <| s.name ++ " (" ++ s.date ++ ")" ]
