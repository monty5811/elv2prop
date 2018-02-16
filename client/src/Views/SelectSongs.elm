module Views.SelectSongs exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(Cancel, ConfirmWrite, ToggleExtraFile, UpdateFilesFilter))
import Models exposing (Match)
import Regex
import Views.Util exposing (greenButton, redButton, spacer, textInputWithLabel)


view : String -> List Match -> List ( Bool, String ) -> Html Msg
view filt ms allFiles =
    Html.div []
        [ Html.div []
            [ Html.div [ A.class "flex" ]
                [ greenButton [ E.onClick <| ConfirmWrite ms, A.class "w-1/2" ] [ Html.text "Confirm" ]
                , redButton [ E.onClick Cancel, A.class "w-1/2" ] [ Html.text "Cancel" ]
                ]
            ]
        , spacer
        , Html.div [ A.class "flex mt-2" ]
            [ Html.div [ A.class "mx-2 w-1/2" ]
                [ Html.h4 [ A.class "mb-4" ] [ Html.text "Files from Elvanto" ]
                , Html.table [ A.class "w-full" ]
                    [ Html.thead []
                        [ Html.tr []
                            [ Html.th [ A.class "text-left" ] [ Html.text "Elvanto" ]
                            , Html.th [ A.class "text-left" ] [ Html.text "Local File" ]
                            ]
                        ]
                    , Html.tbody [] <| List.map matchRow ms
                    ]
                ]
            , Html.div [ A.class "mx-2 w-1/2" ]
                [ Html.h4 [ A.class "mb-4" ] [ Html.text "Additional Files (click to select)" ]
                , textInputWithLabel "Filter.." UpdateFilesFilter filt
                , Html.table [ A.class "w-full" ]
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
                [ A.class "bg-green-light" ]
            else
                []
    in
    Html.tr opts
        [ Html.td [ A.class cellClass, A.class "cursor-pointer", E.onClick <| ToggleExtraFile name ] [ Html.text name ]
        ]


matchRow : Match -> Html Msg
matchRow m =
    Html.tr []
        [ Html.td [ A.class cellClass ] [ Html.text m.elv ]
        , Html.td [ A.class cellClass ] [ Html.text <| proMatchText m.pro ]
        ]


cellClass : String
cellClass =
    "p-2 border-t border-black"


proMatchText : Maybe String -> String
proMatchText pro =
    case pro of
        Just p ->
            p

        Nothing ->
            "No file found"
