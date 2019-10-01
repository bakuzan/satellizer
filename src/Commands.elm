module Commands exposing
    ( sendAiringSeriesQuery
    , sendGraphqlQueryRequest
    , sendHistoryCountsRequest
    , sendHistorySeriesQuery
    , sendHistoryYearSeriesQuery
    , sendRatingCountsRequest
    , sendRatingsSeriesQuery
    , sendRepeatedSeriesQuery
    , sendStatusCountsRequest
    , sendTagsQuery
    )

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GraphQLBuilder
import Http
import Models exposing (Count, CountData, EpisodeStatistic, HistoryDetail, HistoryDetailData, HistoryYear, HistoryYearData, HistoryYearDetail, RepeatedSeriesData, SeriesData, Settings, TagData)
import Msgs exposing (Msg)
import Task exposing (Task)
import Utils.Common as Common
import Utils.Graphql as Graphql



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



-- History Series


historySeriesQueryRequest : Settings -> GraphQLBuilder.Request GraphQLBuilder.Query HistoryDetailData
historySeriesQueryRequest props =
    Graphql.historyItemQuery props.detailGroup
        |> GraphQLBuilder.request
            { contentType = props.contentType
            , isAdult = props.isAdult
            , breakdown = props.breakdownType
            , partition = props.detailGroup
            }


sendHistorySeriesQuery : Settings -> Cmd Msg
sendHistorySeriesQuery props =
    sendGraphqlQueryRequest (historySeriesQueryRequest props)
        |> Task.attempt Msgs.ReceiveHistorySeriesResponse


historyYearSeriesQueryRequest : Settings -> GraphQLBuilder.Request GraphQLBuilder.Query HistoryYearDetail
historyYearSeriesQueryRequest props =
    Graphql.historyYearItemQuery props.detailGroup
        |> GraphQLBuilder.request
            { contentType = props.contentType
            , isAdult = props.isAdult
            , breakdown = props.breakdownType
            , partition = props.detailGroup
            }


sendHistoryYearSeriesQuery : Settings -> Cmd Msg
sendHistoryYearSeriesQuery props =
    sendGraphqlQueryRequest (historyYearSeriesQueryRequest props)
        |> Task.attempt Msgs.ReceiveHistoryYearSeriesResponse



-- Ratings Series


ratingsSeriesQueryRequest : String -> Bool -> String -> List Int -> GraphQLBuilder.Request GraphQLBuilder.Query SeriesData
ratingsSeriesQueryRequest contentType isAdult searchText selectedRatings =
    Graphql.ratingItemQuery contentType
        |> GraphQLBuilder.request { isAdult = isAdult, search = searchText, ratings = selectedRatings }


sendRatingsSeriesQuery : String -> Bool -> String -> List Int -> Cmd Msg
sendRatingsSeriesQuery contentType isAdult searchText selectedRatings =
    sendGraphqlQueryRequest (ratingsSeriesQueryRequest contentType isAdult searchText selectedRatings)
        |> Task.attempt Msgs.ReceiveRatingsSeriesResponse



-- Repeated series


repeatedSeriesQueryRequest : String -> Bool -> String -> GraphQLBuilder.Request GraphQLBuilder.Query RepeatedSeriesData
repeatedSeriesQueryRequest contentType isAdult searchText =
    Graphql.repeatedItemQuery contentType
        |> GraphQLBuilder.request { isAdult = isAdult, search = searchText }


sendRepeatedSeriesQuery : String -> Bool -> String -> Cmd Msg
sendRepeatedSeriesQuery contentType isAdult searchText =
    sendGraphqlQueryRequest (repeatedSeriesQueryRequest contentType isAdult searchText)
        |> Task.attempt Msgs.ReceiveRepeatedSeriesResponse



-- Tags


tagsQueryRequest : String -> Bool -> GraphQLBuilder.Request GraphQLBuilder.Query TagData
tagsQueryRequest contentType isAdult =
    Graphql.tagsQuery
        |> GraphQLBuilder.request { isAdult = isAdult, contentType = contentType }


sendTagsQuery : String -> Bool -> Cmd Msg
sendTagsQuery contentType isAdult =
    sendGraphqlQueryRequest (tagsQueryRequest contentType isAdult)
        |> Task.attempt Msgs.ReceiveTagsResponse



-- Airing series


airingSeriesQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query HistoryDetailData
airingSeriesQueryRequest =
    Graphql.airingItemQuery
        |> GraphQLBuilder.request {}


sendAiringSeriesQuery : Cmd Msg
sendAiringSeriesQuery =
    sendGraphqlQueryRequest airingSeriesQueryRequest
        |> Task.attempt Msgs.ReceiveAiringSeriesResponse
