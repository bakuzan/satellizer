module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (CountData, Count)
import RemoteData
import Utils.Common as Common


fetchStatusData : Cmd Msg
fetchStatusData =
    Http.get (fetchStatusUrl "anime" False) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchStatus

fetchStatusUrl : String -> Bool -> String
fetchStatusUrl itemType isAdult =
  constructUrl "status-counts" itemType isAdult
  
  
fetchHistoryData : Cmd Msg
fetchHistoryData =
    Http.get (fetchRatingUrl "anime" False) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchRating

fetchRatingUrl : String -> Bool -> String
fetchRatingUrl itemType isAdult =
  constructUrl "rating-counts" itemType isAdult


fetchHistoryData : Cmd Msg
fetchHistoryData =
    Http.get (fetchHistoryUrl "anime" False) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistory

fetchHistoryUrl : String -> Bool -> String
fetchHistoryUrl itemType isAdult =
  constructUrl "history-counts" itemType isAdult


constructUrl : String -> String -> Bool -> String
constructUrl urlType itemType isAdult =
    Common.replace ":type" itemType ("/api/statistics/" ++ urlType ++ "/:type/:isAdult")
      |> Common.replace ":isAdult" (toString isAdult)


countDataDecoder : Decode.Decoder CountData
countDataDecoder =
  Decode.list countDecoder

countDecoder : Decode.Decoder Count
countDecoder =
    decode Count
      |> required "key" Decode.string
      |> required "value" Decode.int
