module Commands exposing (..)

import Http
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (PlayerId, Player)
import RemoteData


-- fetchPlayers : Cmd Msg
-- fetchPlayers =
--     Http.get fetchPlayersUrl playersDecoder
--         |> RemoteData.sendRequest
--         |> Cmd.map Msgs.OnFetchPlayers


fetchGraphqlUrl : String -> String
fetchGraphqlUrl graphqlString =
    "http://localhost:9003/graphql=" ++ graphqlString


-- playersDecoder : Decode.Decoder (List Player)
-- playersDecoder =
--     Decode.list playerDecoder


-- playerDecoder : Decode.Decoder Player
-- playerDecoder =
--     decode Player
--         |> required "id" Decode.string
--         |> required "name" Decode.string
--         |> required "level" Decode.int


--
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
