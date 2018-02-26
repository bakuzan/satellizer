module Msgs exposing (..)


import Models exposing (CountData, HistoryDetailData, HistoryYearDetail, SeriesData, RepeatedSeriesData)
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import GraphQL.Client.Http as GraphQLClient


type Msg
    = NoOp
    | OnLocationChange Location
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
    | UpdateRatingSearch String
    | ClearSelectedRatings
    | ToggleRatingFilter Int
    | ReceiveSeriesRatingsResponse (Result GraphQLClient.Error SeriesData)
    | UpdateRepeatedSearch String
    | ReceiveRepeatedSeriesResponse (Result GraphQLClient.Error RepeatedSeriesData)
