module Commands exposing
    ( sendAiringSeriesQuery
    , sendGraphqlQueryRequest
    , sendHistoryCountsRequest
    , sendHistorySeriesQuery
    , sendHistoryYearSeriesQuery
    , sendRatingCountsRequest
    , sendRatingsSeriesQuery
    , sendRepeatedSeriesQuery
    , sendSeriesTypesRequest
    , sendStatusCountsRequest
    , sendTagsQuery
    , sendTagsSeriesQuery
    )

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder as GraphQLBuilder
import Models exposing (CountData, HistoryDetailData, HistoryYearDetail, RatingFilters, RatingSeriesPage, RepeatedSeriesData, SeriesTypes, Settings, TagData, TagsFilters, TagsSeriesPage)
import Msgs exposing (Msg)
import Task exposing (Task)
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



-- Series Types


seriesTypesRequest : String -> GraphQLBuilder.Request GraphQLBuilder.Query SeriesTypes
seriesTypesRequest contentType =
    Graphql.seriesTypesQuery
        |> GraphQLBuilder.request { contentType = contentType }


sendSeriesTypesRequest : String -> Cmd Msg
sendSeriesTypesRequest contentType =
    sendGraphqlQueryRequest (seriesTypesRequest contentType)
        |> Task.attempt Msgs.ReceiveSeriesTypesResponse



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


ratingsSeriesQueryRequest : String -> Bool -> RatingFilters -> GraphQLBuilder.Request GraphQLBuilder.Query RatingSeriesPage
ratingsSeriesQueryRequest contentType isAdult filters =
    Graphql.ratingItemQuery contentType
        |> GraphQLBuilder.request
            { isAdult = isAdult
            , search = filters.searchText
            , ratings = filters.ratings
            , seriesTypes = filters.seriesTypes
            , paging = { page = filters.page, size = 20 }
            }


sendRatingsSeriesQuery : String -> Bool -> RatingFilters -> Cmd Msg
sendRatingsSeriesQuery contentType isAdult filters =
    sendGraphqlQueryRequest (ratingsSeriesQueryRequest contentType isAdult filters)
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



-- Tags series


tagsSeriesQueryRequest : String -> TagsFilters -> GraphQLBuilder.Request GraphQLBuilder.Query TagsSeriesPage
tagsSeriesQueryRequest contentType filters =
    Graphql.tagsSeriesQuery
        |> GraphQLBuilder.request
            { contentType = contentType
            , search = filters.searchText
            , tagIds = filters.tagIds
            , paging = { page = filters.page, size = 20 }
            }


sendTagsSeriesQuery : String -> TagsFilters -> Cmd Msg
sendTagsSeriesQuery contentType filters =
    sendGraphqlQueryRequest (tagsSeriesQueryRequest contentType filters)
        |> Task.attempt Msgs.ReceiveTagsSeriesResponse



-- Airing series


airingSeriesQueryRequest : GraphQLBuilder.Request GraphQLBuilder.Query HistoryDetailData
airingSeriesQueryRequest =
    Graphql.airingItemQuery
        |> GraphQLBuilder.request {}


sendAiringSeriesQuery : Cmd Msg
sendAiringSeriesQuery =
    sendGraphqlQueryRequest airingSeriesQueryRequest
        |> Task.attempt Msgs.ReceiveAiringSeriesResponse
