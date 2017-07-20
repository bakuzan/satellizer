module Commands exposing (..)

import Http
-- import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (Count)
import RemoteData


fetchData : Cmd Msg
fetchData =
    Http.get (fetchGraphqlUrl getCountString) dataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchData


fetchGraphqlUrl : String -> String
fetchGraphqlUrl graphqlString =
    "http://localhost:9003/graphql=" ++ graphqlString


dataDecoder : Decode.Decoder (List Count)
dataDecoder =
    Decode.list countDecoder


countDecoder : Decode.Decoder Count
countDecoder =
    decode Count
        |> required "name" Decode.string
        |> required "count" Decode.int

getCountString : String
getCountString =
  "{ ongoing: animeConnection(filter: { isAdult: false, status: 1 }) { count } onhold: animeConnection(filter: { isAdult: false, status: 3 }) { count } complete: animeConnection(filter: { isAdult: false, status: 2 }) { count } }"


-- savePlayerRequest : Player -> Bool -> Http.Request Player
-- savePlayerRequest player isNewPlayer =
--     let
--       method =
--         if isNewPlayer then "POST" else "PATCH"
--
--       url =
--         savePlayerUrl (if isNewPlayer then "" else player.id)
--
--     in
--     Http.request
--         { body = playerEncoder player |> Http.jsonBody
--         , expect = Http.expectJson playerDecoder
--         , headers = []
--         , method = method
--         , timeout = Nothing
--         , url = url
--         , withCredentials = False
--         }
--


-- playerEncoder : Player -> Encode.Value
-- playerEncoder player =
--     let
--         attributes =
--             [ ( "id", Encode.string player.id )
--             , ( "name", Encode.string player.name )
--             , ( "level", Encode.int player.level )
--             ]
--     in
--         Encode.object attributes


-- deletePlayerRequest : PlayerId -> Http.Request PlayerId
-- deletePlayerRequest playerId =
--     Http.request
--         { body = Http.emptyBody
--         , expect = Http.expectStringResponse (\response -> Ok playerId)
--         , headers = []
--         , method = "DELETE"
--         , timeout = Nothing
--         , url = savePlayerUrl playerId
--         , withCredentials = False
--         }
--
