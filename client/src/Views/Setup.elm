module Views.Setup exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(CancelConfig, SaveConfig, UpdateClientId, UpdateFilesLocation, UpdatePlaylistLocation))
import Models exposing (Config, Step(FirstRun, Setup))
import Views.Util exposing (blueButton, form, greenButton, spacer, textInputWithLabel)


view : Bool -> Config -> List (Html Msg)
view isFirstRun config =
    List.concat
        [ [ header isFirstRun ]
        , form_ isFirstRun config
        ]


form_ : Bool -> Config -> List (Html Msg)
form_ isFirstRun config =
    [ form []
        [ viewIfTrue isFirstRun introText1
        , Html.h4 [ A.class "py-4" ] [ Html.text "ProPresenter Settings" ]
        , viewIfTrue isFirstRun introText2
        , textInputWithLabel "Playlist File Location"
            (UpdatePlaylistLocation (configCtor isFirstRun) config)
            (Maybe.withDefault "" config.playlist_file_path)
        , textInputWithLabel "Song Library Location"
            (UpdateFilesLocation (configCtor isFirstRun) config)
            (Maybe.withDefault "" config.song_library_path)
        , Html.h4 [ A.class "py-4" ] [ Html.text "Elvanto Settings" ]
        , viewIfTrue isFirstRun introText3
        , textInputWithLabel "Client ID"
            (UpdateClientId (configCtor isFirstRun) config)
            (Maybe.withDefault "" config.client_id)
        , spacer
        , greenButton [ E.onClick (SaveConfig config) ] [ Html.text "Save" ]
        , if isFirstRun then
            Html.text ""
          else
            blueButton [ E.onClick CancelConfig ] [ Html.text "Cancel" ]
        ]
    ]


configCtor : Bool -> (Config -> Step)
configCtor isFirstRun =
    if isFirstRun then
        FirstRun
    else
        Setup


header : Bool -> Html Msg
header isFirstRun =
    if isFirstRun then
        Html.h2 [ A.class "pb-8" ] [ Html.text "Setup" ]
    else
        Html.h2 [ A.class "pb-8" ] [ Html.text "Settings" ]


viewIfTrue : Bool -> Html msg -> Html msg
viewIfTrue show html =
    if show then
        html
    else
        Html.text ""


introText1 : Html msg
introText1 =
    Html.p [] [ Html.text "Welcome, we need to do some initial setup before we can start. There are just a few settings to sort out:" ]


introText2 : Html msg
introText2 =
    Html.div []
        [ Html.p [] [ Html.text "We need to know where to look for your song and playlist files, I have tried to make a best guess at them below, can you please check them and fix them if they are wrong." ]
        , spacer
        ]


introText3 : Html msg
introText3 =
    Html.div []
        [ Html.p []
            [ Html.text "In order to get your services from Elvanto, you need to setup an API client, just follow the instructions "
            , Html.a [ A.href "https://github.com/monty5811/elv2prop#setup-in-elvanto" ] [ Html.text "here" ]
            , Html.text " and paste the client ID below."
            ]
        , spacer
        ]
