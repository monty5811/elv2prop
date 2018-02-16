module Views.Util
    exposing
        ( blueButton
        , button
        , form
        , greenButton
        , greyButton
        , invertedButton
        , redButton
        , spacer
        , textInput
        , textInputWithLabel
        )

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E


rawButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
rawButton attrs nodes =
    Html.button (List.append [ A.class "font-bold py-2 px-4 rounded" ] attrs) nodes


button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attrs nodes =
    rawButton (List.append [ A.class "text-white" ] attrs) nodes


blueButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
blueButton attrs nodes =
    button (A.class "bg-blue hover:bg-blue-dark" :: attrs) nodes


greenButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
greenButton attrs nodes =
    button (A.class "bg-green hover:bg-green-dark" :: attrs) nodes


redButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
redButton attrs nodes =
    button (A.class "bg-red hover:bg-red-dark" :: attrs) nodes


greyButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
greyButton attrs nodes =
    button (A.class "bg-grey hover:bg-grey-dark" :: attrs) nodes


invertedButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
invertedButton attrs nodes =
    rawButton (List.append [ A.class "text-black" ] attrs) nodes


spacer : Html msg
spacer =
    Html.div [ A.class "h-4" ] []


form : List (Html.Attribute msg) -> List (Html msg) -> Html msg
form attrs nodes =
    Html.form (A.class "bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4" :: attrs) nodes


textInput : (String -> msg) -> String -> Html msg
textInput onInput value =
    Html.input
        [ A.type_ "text"
        , A.class "shadow appearance-none border rounded w-full py-2 px-3 mb-2 text-grey-darker"
        , A.value value
        , A.id "focusable"
        , E.onInput onInput
        ]
        []


textInputWithLabel : String -> (String -> msg) -> String -> Html msg
textInputWithLabel label onInput value =
    Html.div []
        [ Html.label [ A.class "block text-grey-darker text-sm font-bold mb-2 w-full" ] [ Html.text label ]
        , textInput onInput value
        ]
