module Views.SelectSongs exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(Cancel, ConfirmWrite, ToggleExtraFile, UpdateFilesFilter))
import Models exposing (Match)
import Regex
import Rocket exposing ((=>))


view : String -> List Match -> List ( Bool, String ) -> Html Msg
view filt ms allFiles =
    Html.div []
        [ Html.div []
            [ Html.div [ A.class "two-column" ]
                [ Html.button [ A.class "button button-success button-lg", E.onClick <| ConfirmWrite ms ] [ Html.text "Confirm" ]
                , Html.button [ A.class "button button-danger button-lg", E.onClick Cancel ] [ Html.text "Cancel" ]
                ]
            ]
        , Html.div [ A.class "two-column", A.style [ "margin-top" => "2rem" ] ]
            [ Html.div []
                [ Html.h4 [] [ Html.text "Files from Elvanto" ]
                , Html.table [ A.class "table-striped table-bordered" ]
                    [ Html.thead []
                        [ Html.tr []
                            [ Html.th [] [ Html.text "Elvanto" ]
                            , Html.th [] [ Html.text "Local File" ]
                            ]
                        ]
                    , Html.tbody [] <| List.map matchRow ms
                    ]
                ]
            , Html.div []
                [ Html.h4 [] [ Html.text "Additional Files (click to select)" ]
                , Html.input [ E.onInput UpdateFilesFilter, A.type_ "text", A.placeholder "filter..." ] []
                , Html.table [ A.class "table-hoverable table-bordered" ]
                    [ Html.tbody [] <| List.map extraFileRow <| sortFiles <| filterFiles filt allFiles
                    ]
                ]
            ]
        ]


sortFiles : List ( Bool, String ) -> List ( Bool, String )
sortFiles files =
    let
        ( sel, notSel ) =
            List.partition (\( sel, _ ) -> sel) files
    in
    List.concat [ List.sortBy Tuple.second sel, List.sortBy Tuple.second notSel ]


filterFiles : String -> List ( Bool, String ) -> List ( Bool, String )
filterFiles filt files =
    let
        re =
            (Regex.escape >> Regex.regex >> Regex.caseInsensitive) filt
    in
    files
        |> List.filter (Tuple.second >> Regex.contains re)


extraFileRow : ( Bool, String ) -> Html Msg
extraFileRow ( selected, name ) =
    let
        opts =
            if selected then
                [ A.class "selectedFile" ]
            else
                []
    in
    Html.tr opts
        [ Html.td [ A.style [ "cursor" => "pointer" ], E.onClick <| ToggleExtraFile name ] [ Html.text name ]
        ]


matchRow : Match -> Html Msg
matchRow m =
    Html.tr []
        [ Html.td [] [ Html.text m.elv ]
        , Html.td [] [ Html.text <| proMatchText m.pro ]
        ]


proMatchText : Maybe String -> String
proMatchText pro =
    case pro of
        Just p ->
            p

        Nothing ->
            "No file found"
