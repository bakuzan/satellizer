module Msgs exposing (Msg(..))

import Debounce
import GraphQL.Client.Http as GraphQLClient
import Models
    exposing
        ( CountData
        , HistoryDetailData
        , HistoryYearDetail
        , RatingSeriesPage
        , RepeatedSeriesData
        , SeriesTypes
        , TagData
        , TagsSeriesPage
        , Theme
        )


type Msg
    = NoOp
    | DebounceMsg Debounce.Msg
    | SaveTextInput String String
    | UpdateActiveTab String
    | UpdateBreakdownType String
    | UpdateSortField String
    | UpdateSortDirection Bool
    | DisplayHistoryDetail String
    | MoveTableRowDisplay Int
    | UpdateIsAdult Bool
    | UpdateContentType String
    | UpdateRequireKey Bool
    | UpdateTheme Theme
    | UpdateTextInput String String
    | ClearSelectedRatings
    | ToggleRatingFilter Int
    | ToggleTagsFilter Int
    | ClearAllTagsFilter
    | ToggleSeriesTypeFilter String
    | ResetSeriesTypeFilter
    | NextTagsSeriesPage
    | NextRatingSeriesPage
    | ReceiveStatusCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveRatingCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveHistoryCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveHistorySeriesResponse (Result GraphQLClient.Error HistoryDetailData)
    | ReceiveHistoryYearSeriesResponse (Result GraphQLClient.Error HistoryYearDetail)
    | ReceiveRatingsSeriesResponse (Result GraphQLClient.Error RatingSeriesPage)
    | ReceiveRepeatedSeriesResponse (Result GraphQLClient.Error RepeatedSeriesData)
    | ReceiveTagsResponse (Result GraphQLClient.Error TagData)
    | ReceiveTagsSeriesResponse (Result GraphQLClient.Error TagsSeriesPage)
    | ReceiveAiringSeriesResponse (Result GraphQLClient.Error HistoryDetailData)
    | ReceiveSeriesTypesResponse (Result GraphQLClient.Error SeriesTypes)
