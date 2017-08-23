module Msgs exposing (..)

-- import Http
import Models exposing (CountData, HistoryDetailData, HistoryYearData)
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
    | OnFetchHistoryYear (WebData HistoryYearData)
    | UpdateIsAdult Bool
    | UpdateContentType String
