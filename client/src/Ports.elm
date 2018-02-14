port module Ports exposing (deleteTokenData, saveTokenData)


port saveTokenData : String -> Cmd msg


port deleteTokenData : () -> Cmd msg
