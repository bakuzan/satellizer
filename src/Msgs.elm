module Msgs exposing (Msg(..))

import Debounce
import GraphQL.Client.Http as GraphQLClient
import Models exposing (CountData, HistoryDetailData, HistoryYearDetail, RepeatedSeriesData, SeriesData, TagData, Theme)


type Msg
    = NoOp
    | DebounceMsg Debounce.Msg
    | SaveTextInput String String
    | UpdateActiveTab String
    | UpdateBreakdownType String
    | UpdateSortField String
    | UpdateSortDirection Bool
    | DisplayHistoryDetail String
    | UpdateIsAdult Bool
    | UpdateContentType String
    | UpdateRequireKey Bool
    | UpdateTheme Theme
    | UpdateTextInput String String
    | ClearSelectedRatings
    | ToggleRatingFilter Int
    | ToggleTagsFilter Int
    | ReceiveStatusCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveRatingCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveHistoryCountsResponse (Result GraphQLClient.Error CountData)
    | ReceiveHistorySeriesResponse (Result GraphQLClient.Error HistoryDetailData)
    | ReceiveHistoryYearSeriesResponse (Result GraphQLClient.Error HistoryYearDetail)
    | ReceiveRatingsSeriesResponse (Result GraphQLClient.Error SeriesData)
    | ReceiveRepeatedSeriesResponse (Result GraphQLClient.Error RepeatedSeriesData)
    | ReceiveTagsResponse (Result GraphQLClient.Error TagData)
    | ReceiveAiringSeriesResponse (Result GraphQLClient.Error HistoryDetailData)
