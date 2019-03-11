module Msgs exposing (Msg(..))

-- import Navigation exposing (Location)

import Debounce
import GraphQL.Client.Http as GraphQLClient
import Models exposing (CountData, HistoryDetailData, HistoryYearDetail, RepeatedSeriesData, SeriesData, Theme)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | DebounceMsg Debounce.Msg
    | SaveTextInput String String
    | OnFetchStatus (WebData CountData)
    | OnFetchHistory (WebData CountData)
    | OnFetchRating (WebData CountData)
    | UpdateActiveTab String
    | UpdateBreakdownType String
    | UpdateSortField String
    | UpdateSortDirection Bool
    | DisplayHistoryDetail String
    | OnFetchHistoryDetail (WebData HistoryDetailData)
    | OnFetchHistoryYear (WebData HistoryYearDetail)
    | UpdateIsAdult Bool
    | UpdateContentType String
    | UpdateRequireKey Bool
    | UpdateTheme Theme
    | UpdateTextInput String String
    | ClearSelectedRatings
    | ToggleRatingFilter Int
    | ReceiveSeriesRatingsResponse (Result GraphQLClient.Error SeriesData)
    | ReceiveRepeatedSeriesResponse (Result GraphQLClient.Error RepeatedSeriesData)
    | ReceiveAiringSeriesResponse (Result GraphQLClient.Error HistoryDetailData)
