module Commands exposing (..)

import Http
import RemoteData
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GraphQLBuilder
import Task exposing (Task)

import Msgs exposing (Msg)
import Models exposing (Settings, CountData, Count, HistoryDetailData, HistoryDetail, EpisodeStatistic, HistoryYearDetail, HistoryYearData, HistoryYear, SeriesData, RepeatedSeriesData)

import Utils.Decoders as Decoders
import Utils.Common as Common
import Utils.Graphql as Graphql

-- Status counts

fetchStatusData : Settings -> Cmd Msg
fetchStatusData settings =
    Http.get (fetchStatusUrl settings) Decoders.countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchStatus


fetchStatusUrl : Settings -> String
fetchStatusUrl settings =
  constructUrl "status-counts" settings


-- Rating counts

fetchRatingData : Settings -> Cmd Msg
fetchRatingData settings =
    Http.get (fetchRatingUrl  settings) Decoders.countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchRating


fetchRatingUrl : Settings -> String
fetchRatingUrl settings =
  constructUrl "rating-counts" settings


-- History table counts

fetchHistoryData : Settings -> Cmd Msg
fetchHistoryData settings =
    Http.get (fetchHistoryUrl settings) Decoders.countDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistory


fetchHistoryUrl : Settings -> String
fetchHistoryUrl settings =
  (constructUrl "history-counts" settings) ++ "/" ++ (String.toLower settings.breakdownType)


-- History breakdown by partition

fetchHistoryDetailData : Settings -> Cmd Msg
fetchHistoryDetailData settings =
  Http.get (fetchHistoryDetailUrl settings) Decoders.historyDetailDataDecoder
      |> RemoteData.sendRequest
      |> Cmd.map Msgs.OnFetchHistoryDetail


fetchHistoryDetailUrl : Settings -> String
fetchHistoryDetailUrl settings =
  (constructUrl "history-detail" settings) ++ (constructHistoryBreakdownUrl settings)


-- History breakdown by year

fetchHistoryYearData : Settings -> Cmd Msg
fetchHistoryYearData settings =
  Http.get (fetchHistoryYearUrl settings) Decoders.historyYearDetailDecoder
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


-- Graphql Queries

sendGraphqlQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query a -> Task GraphQLClient.Error a
sendGraphqlQueryRequest request =
    GraphQLClient.sendQuery "/graphql" request

-- Ratings Series
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


-- Repeated series
repeatedSeriesQueryRequest : String -> Bool -> String -> GraphQLBuilder.Request GraphQLBuilder.Query RepeatedSeriesData
repeatedSeriesQueryRequest contentType isAdult searchText =
    Graphql.repeatedItemQuery contentType
        |> GraphQLBuilder.request { isAdult = isAdult, search = searchText }

sendRepeatedSeriesQuery : String -> Bool -> String -> Cmd Msg
sendRepeatedSeriesQuery contentType isAdult searchText =
    sendGraphqlQueryRequest (repeatedSeriesQueryRequest contentType isAdult searchText)
        |> Task.attempt Msgs.ReceiveRepeatedSeriesResponse
