module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { status : WebData CountData
    , history: WebData CountData
    , historyDetail: WebData HistoryDetailData
    , rating: WebData CountData
    , route: Route
    , activeTab: String
    , breakdownType: String
    }


initialModel : Route -> Model
initialModel route =
    { status = RemoteData.Loading
    , history = RemoteData.Loading
    , historyDetail = RemoteData.Loading
    , rating = RemoteData.Loading
    , route = route
    , activeTab = "History"
    , breakdownType = "MONTHS"
    }


type alias CountData =
  List Count


type alias Count =
  { key: String
  , value: Int
  }


type alias HistoryDetailData =
  List HistoryDetail


type alias HistoryDetail =
  { _id: String
  , title: String
  , rating: Int
  }


-- Constant models

type alias Header =
  { name: String
  , number: Int
  }




-- Routing

type Route
    = StatisticsRoute
    | NotFoundRoute
