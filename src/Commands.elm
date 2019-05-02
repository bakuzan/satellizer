module Commands exposing
    ( constructHistoryBreakdownUrl
    , constructUrl
    , fetchHistoryDetailData
    , fetchHistoryDetailUrl
    , fetchHistoryYearData
    , fetchHistoryYearUrl
    , sendAiringSeriesQuery
    , sendGraphqlQueryRequest
    , sendHistoryCountsRequest
    , sendRatingCountsRequest
    , sendRepeatedSeriesQuery
    , sendSeriesRatingsQuery
    , sendStatusCountsRequest
    )

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GraphQLBuilder
import Http
import Models exposing (Count, CountData, EpisodeStatistic, HistoryDetail, HistoryDetailData, HistoryYear, HistoryYearData, HistoryYearDetail, RepeatedSeriesData, SeriesData, Settings)
import Msgs exposing (Msg)
import RemoteData
import Task exposing (Task)
import Utils.Common as Common
import Utils.Decoders as Decoders
import Utils.Graphql as Graphql



-- History breakdown by partition


fetchHistoryDetailData : Settings -> Cmd Msg
fetchHistoryDetailData settings =
    Http.get (fetchHistoryDetailUrl settings) Decoders.historyDetailDataDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistoryDetail


fetchHistoryDetailUrl : Settings -> String
fetchHistoryDetailUrl settings =
    constructUrl "history-detail" settings ++ constructHistoryBreakdownUrl settings



-- History breakdown by year


fetchHistoryYearData : Settings -> Cmd Msg
fetchHistoryYearData settings =
    Http.get (fetchHistoryYearUrl settings) Decoders.historyYearDetailDecoder
        |> RemoteData.sendRequest
        |> Cmd.map Msgs.OnFetchHistoryYear


fetchHistoryYearUrl : Settings -> String
fetchHistoryYearUrl settings =
    constructUrl "history-years" settings ++ constructHistoryBreakdownUrl settings



-- Url helpers


constructHistoryBreakdownUrl : Settings -> String
constructHistoryBreakdownUrl settings =
    "/" ++ String.toLower settings.breakdownType ++ "/" ++ settings.detailGroup


constructUrl : String -> Settings -> String
constructUrl urlType settings =
    Common.replace ":type" settings.contentType ("/api/statistics/" ++ urlType ++ "/:type/:isAdult")
        |> Common.replace ":isAdult"
            (if settings.isAdult then
                "true"

             else
                "false"
            )



-- Graphql Queries


sendGraphqlQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query a -> Task GraphQLClient.Error a
sendGraphqlQueryRequest request =
    GraphQLClient.sendQuery "/graphql" request



-- Status Counts


statusCountsRequest : String -> Bool -> GraphQLBuilder.Request GraphQLBuilder.Query CountData
statusCountsRequest contentType isAdult =
    Graphql.statusCountQuery
        |> GraphQLBuilder.request { contentType = contentType, isAdult = isAdult }


sendStatusCountsRequest : String -> Bool -> Cmd Msg
sendStatusCountsRequest contentType isAdult =
    sendGraphqlQueryRequest (statusCountsRequest contentType isAdult)
        |> Task.attempt Msgs.ReceiveStatusCountsResponse



-- Rating Counts


ratingCountsRequest : String -> Bool -> GraphQLBuilder.Request GraphQLBuilder.Query CountData
ratingCountsRequest contentType isAdult =
    Graphql.ratingCountQuery
        |> GraphQLBuilder.request { contentType = contentType, isAdult = isAdult }


sendRatingCountsRequest : String -> Bool -> Cmd Msg
sendRatingCountsRequest contentType isAdult =
    sendGraphqlQueryRequest (ratingCountsRequest contentType isAdult)
        |> Task.attempt Msgs.ReceiveRatingCountsResponse



-- History Counts


historyCountsRequest : Settings -> GraphQLBuilder.Request GraphQLBuilder.Query CountData
historyCountsRequest props =
    Graphql.historyCountQuery
        |> GraphQLBuilder.request
            { contentType = props.contentType
            , isAdult = props.isAdult
            , breakdown = props.breakdownType
            }


sendHistoryCountsRequest : Settings -> Cmd Msg
sendHistoryCountsRequest props =
    sendGraphqlQueryRequest (historyCountsRequest props)
        |> Task.attempt Msgs.ReceiveHistoryCountsResponse



-- Ratings Series


seriesQueryRequest : String -> Bool -> String -> List Int -> GraphQLBuilder.Request GraphQLBuilder.Query SeriesData
seriesQueryRequest contentType isAdult searchText selectedRatings =
    Graphql.ratingItemQuery contentType
        |> GraphQLBuilder.request { isAdult = isAdult, search = searchText, ratings = selectedRatings }


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



-- Airing series


airingSeriesQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query HistoryDetailData
airingSeriesQueryRequest =
    Graphql.airingItemQuery
        |> GraphQLBuilder.request {}


sendAiringSeriesQuery : Cmd Msg
sendAiringSeriesQuery =
    sendGraphqlQueryRequest airingSeriesQueryRequest
        |> Task.attempt Msgs.ReceiveAiringSeriesResponse
