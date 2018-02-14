module Views.Setup exposing (view)

import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Messages exposing (Msg(CancelConfig, SaveConfig, UpdateClientId, UpdateFilesLocation, UpdatePlaylistLocation))
import Models exposing (Config, Step(FirstRun, Setup))


view : Bool -> Config -> List (Html Msg)
view isFirstRun config =
    List.concat
        [ [ header isFirstRun ]
        , introText1 isFirstRun
        , form isFirstRun config
        ]


form : Bool -> Config -> List (Html Msg)
form isFirstRun config =
    List.concat
        [ [ Html.form []
                [ Html.div [ A.class "input-single" ]
                    [ Html.label [] [ Html.text "Playlist File Location" ]
                    , Html.input
                        [ A.value <| Maybe.withDefault "" config.playlist_file_path
                        , A.type_ "text"
                        , E.onInput (UpdatePlaylistLocation (configCtor isFirstRun) config)
                        ]
                        []
                    ]
                , Html.div [ A.class "input-single" ]
                    [ Html.label [] [ Html.text "Song Library Location" ]
                    , Html.input
                        [ A.value <| Maybe.withDefault "" config.song_library_path
                        , A.type_ "text"
                        , E.onInput (UpdateFilesLocation (configCtor isFirstRun) config)
                        ]
                        []
                    ]
                ]
          ]
        , introText2 isFirstRun
        , [ Html.form []
                [ Html.div [ A.class "input-single" ]
                    [ Html.label [] [ Html.text "Client ID" ]
                    , Html.input
                        [ A.value <| Maybe.withDefault "" config.client_id
                        , E.onInput (UpdateClientId (configCtor isFirstRun) config)
                        , A.type_ "text"
                        ]
                        []
                    ]
                ]
          ]
        , [ Html.button [ A.class "button button-success", E.onClick (SaveConfig config) ] [ Html.text "Save" ] ]
        , if isFirstRun then
            []
          else
            [ Html.button [ A.class "button button-secondary", E.onClick CancelConfig ] [ Html.text "Cancel" ] ]
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
        Html.h2 [] [ Html.text "Setup" ]
    else
        Html.h2 [] [ Html.text "Settings" ]


introText1 : Bool -> List (Html Msg)
introText1 isFirstRun =
    if isFirstRun then
        [ Html.p [] [ Html.text "Welcome, we need to do some initial setup before we can start." ]
        , Html.p [] [ Html.text "There are just a few settings to sort out:" ]
        , Html.h4 [] [ Html.text "ProPresenter Settings" ]
        , Html.p [] [ Html.text "We need to know where to look for your song and playist files, I have made a best guess at them below, can you please check them and fix them if they are wrong" ]
        ]
    else
        []


introText2 : Bool -> List (Html Msg)
introText2 isFirstRun =
    if isFirstRun then
        [ Html.h4 [] [ Html.text "Elvanto Settings" ]
        , Html.p []
            [ Html.text "In order to get your services from Elvanto, you need to setup an API client, just follow the instructions "
            , Html.a [ A.href "https://www.deanmontgomery.com/2017/08/20/elvanto-propresenter/#setup-in-elvanto" ] [ Html.text "here" ]
            , Html.text " and paste the client ID below"
            ]
        ]
    else
        []
