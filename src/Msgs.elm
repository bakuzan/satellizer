module Msgs exposing (..)


import Models exposing (CountData, HistoryDetailData, HistoryYearDetail, SeriesData, RepeatedSeriesData)
import Debounce
-- import Navigation exposing (Location)
import RemoteData exposing (WebData)
import GraphQL.Client.Http as GraphQLClient


type Msg
    = NoOp
    -- | OnLocationChange Location
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
    | UpdateTextInput String String
    | ClearSelectedRatings
    | ToggleRatingFilter Int
    | ReceiveSeriesRatingsResponse (Result GraphQLClient.Error SeriesData)
    | ReceiveRepeatedSeriesResponse (Result GraphQLClient.Error RepeatedSeriesData)
