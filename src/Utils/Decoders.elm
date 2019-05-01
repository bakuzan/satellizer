module Utils.Decoders exposing (countDataDecoder, countDecoder, episodeStatisticsDecoder, historyDetailDataDecoder, historyDetailDecoder, historyYearDataDecoder, historyYearDecoder, historyYearDetailDecoder)

import Json.Decode as Decode
import Json.Decode.Pipeline exposing (required)
import Models exposing (Count, CountData, EpisodeStatistic, HistoryDetail, HistoryDetailData, HistoryYear, HistoryYearData, HistoryYearDetail, SeriesData)



-- Decoding models


countDataDecoder : Decode.Decoder CountData
countDataDecoder =
    Decode.list countDecoder


countDecoder : Decode.Decoder Count
countDecoder =
    Decode.succeed Count
        |> required "key" Decode.string
        |> required "value" Decode.int


historyDetailDataDecoder : Decode.Decoder HistoryDetailData
historyDetailDataDecoder =
    Decode.list historyDetailDecoder


historyDetailDecoder : Decode.Decoder HistoryDetail
historyDetailDecoder =
    Decode.succeed HistoryDetail
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "rating" Decode.int
        |> required "season" Decode.string
        |> required "average" Decode.float
        |> required "highest" Decode.int
        |> required "lowest" Decode.int
        |> required "mode" Decode.int


episodeStatisticsDecoder : Decode.Decoder EpisodeStatistic
episodeStatisticsDecoder =
    Decode.succeed EpisodeStatistic
        |> required "average" Decode.float
        |> required "highest" Decode.int
        |> required "lowest" Decode.int
        |> required "mode" Decode.int


historyYearDetailDecoder : Decode.Decoder HistoryYearDetail
historyYearDetailDecoder =
    Decode.succeed HistoryYearDetail
        |> required "counts" historyYearDataDecoder
        |> required "detail" historyDetailDataDecoder


historyYearDataDecoder : Decode.Decoder HistoryYearData
historyYearDataDecoder =
    Decode.list historyYearDecoder


historyYearDecoder : Decode.Decoder HistoryYear
historyYearDecoder =
    Decode.succeed HistoryYear
        |> required "_id" Decode.string
        |> required "value" Decode.int
        |> required "average" Decode.float
        |> required "highest" Decode.int
        |> required "lowest" Decode.int
        |> required "mode" Decode.int
