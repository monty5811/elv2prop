module Remote exposing (chooseReq, confirmReq, fetchServices, saveConfig)

import Elvanto exposing (Service, decodeService, encodeService)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Messages exposing (Msg(..))
import Models exposing (Config, Match, decodeConfig, decodeMatch, encodeConfig, encodeMatches)


post : String -> List ( String, Encode.Value ) -> Decode.Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = url
        , body = body |> Encode.object |> Http.jsonBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


fetchServices : String -> Cmd Msg
fetchServices token =
    post "/fetch" [ ( "token", Encode.string token ) ] (Decode.list decodeService)
        |> Http.send ReceiveServices


chooseReq : Service -> Cmd Msg
chooseReq s =
    post "/choose" [ ( "service", encodeService s ) ] (Decode.list decodeMatch)
        |> Http.send ReceiveMatches


confirmReq : Service -> List Match -> List String -> Cmd Msg
confirmReq s ms extras =
    post "/confirm"
        [ ( "service", encodeService s )
        , ( "songs", encodeMatches ms )
        , ( "extras", Encode.list <| List.map Encode.string extras )
        ]
        (Decode.succeed True)
        |> Http.send ReceiveConfirm


saveConfig : Config -> Cmd Msg
saveConfig c =
    post "/update-config" [ ( "config", encodeConfig c ) ] decodeConfig
        |> Http.send ReceiveConfig
