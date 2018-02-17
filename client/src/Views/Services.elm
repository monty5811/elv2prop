module Views.Services exposing (view)

import Elvanto exposing (Service)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(ChooseService, FetchServices))
import Models exposing (LoadingStatus(Finished, Loading, NotAsked), Model)
import Views.Util exposing (greenButton)


view : Model -> Html Msg
view model =
    case model.fetchStatus of
        NotAsked ->
            greenButton [ E.onClick FetchServices ] [ Html.text "Fetch Elvanto Services" ]

        Loading ->
            loadingIndicator

        Finished ->
            serviceList model.services


loadingIndicator : Html Msg
loadingIndicator =
    Html.div []
        [ Html.h3 [ A.class "pb-2" ] [ Html.text "Loading..." ]
        , Html.div [ A.class "loader" ] []
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
        [ Html.h3 [ A.class "pb-2" ] [ Html.text heading ]
        , Html.div [] <| List.map serviceView services
        ]


serviceView : Service -> Html Msg
serviceView s =
    Html.div [ A.class <| serviceItemClass s ]
        [ Html.div
            [ A.class "flex", E.onClick <| ChooseService s ]
            [ Html.div [ A.class "m-auto w-5/6" ]
                [ Html.text s.name
                , Html.div [ A.class "pl-2 text-xs" ] [ Html.text <| " (" ++ s.prettyDate ++ ")" ]
                ]
            , Html.div [ A.class "bg-green-dark rounded-full px-2 py-2 text-sm w-8 mx-auto text-center" ]
                [ Html.text <| toString <| List.length s.songs ]
            ]
        ]


serviceItemClass : Service -> String
serviceItemClass s =
    let
        base =
            "my-4 pl-4 py-4 select-none shadow-md"
    in
    if List.length s.songs < 1 then
        base ++ " bg-grey-light cursor-not-allowed"
    else
        base ++ " bg-white cursor-pointer"
