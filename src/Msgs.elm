module Msgs exposing (..)


import Models exposing (CountData, HistoryDetailData, HistoryYearDetail)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


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
