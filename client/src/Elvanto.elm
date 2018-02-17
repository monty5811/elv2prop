module Elvanto exposing (Service, ServiceType, Song, decodeService, encodeService)

import Json.Decode as Decode
import Json.Decode.Pipeline as P
import Json.Encode as Encode


type alias Service =
    { id : String
    , date : String
    , prettyDate : String
    , description : String
    , name : String
    , service_type : ServiceType
    , songs : List Song
    , status : Int
    }


type alias ServiceType =
    { id : String
    , name : String
    }


type alias Song =
    { id : String
    , title : String
    }


decodeService : Decode.Decoder Service
decodeService =
    P.decode Service
        |> P.required "id" Decode.string
        |> P.required "date" Decode.string
        |> P.required "pretty_date" Decode.string
        |> P.required "description" Decode.string
        |> P.required "name" Decode.string
        |> P.required "service_type" decodeServiceType
        |> P.required "songs" (Decode.list decodeSong)
        |> P.required "status" Decode.int


decodeServiceType : Decode.Decoder ServiceType
decodeServiceType =
    P.decode ServiceType
        |> P.required "id" Decode.string
        |> P.required "name" Decode.string


decodeSong : Decode.Decoder Song
decodeSong =
    P.decode Song
        |> P.required "id" Decode.string
        |> P.required "title" Decode.string


encodeService : Service -> Encode.Value
encodeService s =
    Encode.object
        [ ( "id", Encode.string s.id )
        , ( "titles", Encode.list (List.map (\song -> song.title |> Encode.string) s.songs) )
        , ( "date", Encode.string s.date )
        , ( "name", Encode.string s.name )
        ]
