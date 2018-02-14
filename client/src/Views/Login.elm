module Views.Login exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Models exposing (Model)


view : Model -> List (Html msg)
view model =
    case model.config.client_id of
        Nothing ->
            [ Html.h4 [] [ Html.text "No client id provided" ] ]

        Just clientId ->
            [ Html.h4 [] [ Html.text "Grant access to Elvanto" ]
            , Html.a
                [ A.class "button button-primary button-lg"
                , A.href <| oauthLink clientId model.host
                ]
                [ Html.text "Login" ]
            ]


oauthLink : String -> String -> String
oauthLink clientId host =
    "https://api.elvanto.com/oauth?type=user_agent&client_id=" ++ clientId ++ "&redirect_uri=http%3A%2F%2F" ++ host ++ "&scope=ManageServices"
