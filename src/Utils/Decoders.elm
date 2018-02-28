module Utils.Decoders exposing (..)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)

import Models exposing (CountData, Count, HistoryDetailData, HistoryDetail, EpisodeStatistic, HistoryYearDetail, HistoryYearData, HistoryYear, SeriesData)


-- Decoding models

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
    |> required "episodeStatistics" episodeStatisticsDecoder
    |> required "rating" Decode.int
    |> required "season" Decode.string


episodeStatisticsDecoder : Decode.Decoder EpisodeStatistic
episodeStatisticsDecoder =
  decode EpisodeStatistic
    |> required "_id" Decode.string
    |> required "average" Decode.float
    |> required "highest" Decode.int
    |> required "lowest" Decode.int
    |> required "mode" Decode.int


historyYearDetailDecoder : Decode.Decoder HistoryYearDetail
historyYearDetailDecoder =
    decode HistoryYearDetail
      |> required "counts" historyYearDataDecoder
      |> required "detail" historyDetailDataDecoder


historyYearDataDecoder : Decode.Decoder HistoryYearData
historyYearDataDecoder =
  Decode.list historyYearDecoder


historyYearDecoder : Decode.Decoder HistoryYear
historyYearDecoder =
  decode HistoryYear
    |> required "_id" Decode.string
    |> required "value" Decode.int
    |> required "average" Decode.float
    |> required "highest" Decode.int
    |> required "lowest" Decode.int
    |> required "mode" Decode.int