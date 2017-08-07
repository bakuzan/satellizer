module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Msgs exposing (Msg)
import Models exposing (CountData, Count, HistoryDetailData, HistoryDetail)
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


fetchRatingData : Cmd Msg
fetchRatingData =
    Http.get (fetchRatingUrl "anime" False) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchRating


fetchRatingUrl : String -> Bool -> String
fetchRatingUrl itemType isAdult =
  constructUrl "rating-counts" itemType isAdult


fetchHistoryData : String -> Cmd Msg
fetchHistoryData breakdown =
    Http.get (fetchHistoryUrl "anime" False breakdown) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistory


fetchHistoryUrl : String -> Bool -> String -> String
fetchHistoryUrl itemType isAdult breakdown =
  (constructUrl "history-counts" itemType isAdult) ++ "/" ++ (String.toLower breakdown)


fetchHistoryDetailData : String -> String -> Cmd Msg
fetchHistoryDetailData date breakdown =
  Http.get (fetchHistoryDetailUrl "anime" False breakdown date) historyDetailDataDecoder
      |> RemoteData.sendRequest
      |> Cmd.map Msgs.OnFetchHistoryDetail


fetchHistoryDetailUrl : String -> Bool -> String -> String -> String
fetchHistoryDetailUrl itemType isAdult breakdown date =
  (constructUrl "history-detail" itemType isAdult) ++ "/" ++ (String.toLower breakdown) ++ "/" ++ date


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


historyDetailDataDecoder : Decode.Decoder HistoryDetailData
historyDetailDataDecoder =
  Decode.list historyDetailDecoder


historyDetailDecoder : Decode.Decoder HistoryDetail
historyDetailDecoder =
  decode HistoryDetail
    |> required "_id" Decode.string
    |> required "title" Decode.string
    |> required "rating" Decode.int
