module Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import RemoteData
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GraphQLBuilder
import Task exposing (Task)

import Msgs exposing (Msg)
import Models exposing (Settings, CountData, Count, HistoryDetailData, HistoryDetail, EpisodeStatistic, HistoryYearDetail, HistoryYearData, HistoryYear, SeriesData)

import Utils.Common as Common
import Utils.Graphql as Graphql

-- Status counts

fetchStatusData : Settings -> Cmd Msg
fetchStatusData settings =
    Http.get (fetchStatusUrl settings) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchStatus


fetchStatusUrl : Settings -> String
fetchStatusUrl settings =
  constructUrl "status-counts" settings


-- Rating counts

fetchRatingData : Settings -> Cmd Msg
fetchRatingData settings =
    Http.get (fetchRatingUrl  settings) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchRating


fetchRatingUrl : Settings -> String
fetchRatingUrl settings =
  constructUrl "rating-counts" settings


-- History table counts

fetchHistoryData : Settings -> Cmd Msg
fetchHistoryData settings =
    Http.get (fetchHistoryUrl settings) countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistory


fetchHistoryUrl : Settings -> String
fetchHistoryUrl settings =
  (constructUrl "history-counts" settings) ++ "/" ++ (String.toLower settings.breakdownType)


-- History breakdown by partition

fetchHistoryDetailData : Settings -> Cmd Msg
fetchHistoryDetailData settings =
  Http.get (fetchHistoryDetailUrl settings) historyDetailDataDecoder
      |> RemoteData.sendRequest
      |> Cmd.map Msgs.OnFetchHistoryDetail


fetchHistoryDetailUrl : Settings -> String
fetchHistoryDetailUrl settings =
  (constructUrl "history-detail" settings) ++ (constructHistoryBreakdownUrl settings)


-- History breakdown by year

fetchHistoryYearData : Settings -> Cmd Msg
fetchHistoryYearData settings =
  Http.get (fetchHistoryYearUrl settings) historyYearDetailDecoder
      |> RemoteData.sendRequest
      |> Cmd.map Msgs.OnFetchHistoryYear


fetchHistoryYearUrl : Settings -> String
fetchHistoryYearUrl settings =
  (constructUrl "history-years" settings) ++ (constructHistoryBreakdownUrl settings)


-- Url helpers

constructHistoryBreakdownUrl : Settings -> String
constructHistoryBreakdownUrl settings =
  "/" ++ (String.toLower settings.breakdownType) ++ "/" ++ settings.detailGroup


constructUrl : String -> Settings -> String
constructUrl urlType settings =
    Common.replace ":type" settings.contentType ("/api/statistics/" ++ urlType ++ "/:type/:isAdult")
      |> Common.replace ":isAdult" (toString settings.isAdult)


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


-- Graphql Queries

sendGraphqlQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query a -> Task GraphQLClient.Error a
sendGraphqlQueryRequest request =
    GraphQLClient.sendQuery "/graphql" request

seriesQueryRequest : String -> Bool -> String -> List Int -> GraphQLBuilder.Request GraphQLBuilder.Query SeriesData
seriesQueryRequest contentType isAdult searchText selectedRatings =
  let
    ratingsList =
      List.map toFloat selectedRatings

  in
    Graphql.itemQuery contentType
        |> GraphQLBuilder.request { isAdult = isAdult, search = searchText, ratings = ratingsList }

sendSeriesRatingsQuery : String -> Bool -> String -> List Int -> Cmd Msg
sendSeriesRatingsQuery contentType isAdult searchText selectedRatings =
    sendGraphqlQueryRequest (seriesQueryRequest contentType isAdult searchText selectedRatings)
        |> Task.attempt Msgs.ReceiveSeriesRatingsResponse
