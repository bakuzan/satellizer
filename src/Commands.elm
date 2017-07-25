module Commands exposing (..)

import Http
-- import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (CountData, Counts, Count)
import RemoteData


fetchData : Cmd Msg
fetchData =
    Http.get (fetchGraphqlUrl getCountString) dataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchStatus


fetchGraphqlUrl : String -> String
fetchGraphqlUrl graphqlString =
    "/graphql?query=" ++ graphqlString

dataDecoder : Decode.Decoder CountData
dataDecoder =
  decode CountData
      |> required "data" countsDecoder

countsDecoder : Decode.Decoder Counts
countsDecoder =
    decode Counts
        |> required "ongoing" countDecoder
        |> required "complete" countDecoder
        |> required "onhold" countDecoder
        |> required "total" countDecoder

countDecoder : Decode.Decoder Count
countDecoder =
    decode Count
        |> required "count" Decode.int


getCountString : String
getCountString =
  "{ ongoing: animeConnection(filter: { isAdult: false, status: 1 }) { count } onhold: animeConnection(filter: { isAdult: false, status: 3 }) { count } complete: animeConnection(filter: { isAdult: false, status: 2 }) { count } total: animeConnection(filter: { isAdult: false }) { count } }"

-- this response: "{\"data\":{\"ongoing\":{\"count\":54},\"onhold\":{\"count\":12},\"complete\":{\"count\":1691}}}"

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
