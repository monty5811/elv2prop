module Main exposing (..)

import Dict
import Messages exposing (..)
import Models exposing (..)
import Navigation
import Update exposing (..)
import View exposing (view)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (always NoOp)
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


parseHash : Navigation.Location -> Maybe String
parseHash loc =
    loc.hash
        |> String.dropLeft 1
        |> String.split "&"
        |> List.map hashParam2Tuple
        |> Dict.fromList
        |> Dict.get "access_token"


hashParam2Tuple : String -> ( String, String )
hashParam2Tuple s =
    case String.split "=" s of
        [ a, b ] ->
            ( a, b )

        _ ->
            ( "", "" )


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags loc =
    let
        maybeUrlToken =
            parseHash loc

        model =
            initialModel flags maybeUrlToken
    in
    case model.step of
        Sync ->
            model
                |> update FetchServices

        _ ->
            model ! []
