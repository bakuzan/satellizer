module Models exposing (..)

import RemoteData exposing (WebData)


type alias Model =
    { status : WebData CountData
    , history: WebData CountData
    , historyDetail: WebData HistoryDetailData
    , rating: WebData CountData
    , route: Route
    , settings: Settings
    }


type alias Settings =
  { activeTab: String
  , breakdownType: String
  , detailGroup: String
  , sorting: Sort
  }


type alias Sort =
  { field: String
  , isDesc: Bool
  }


initialModel : Route -> Model
initialModel route =
    { status = RemoteData.Loading
    , history = RemoteData.Loading
    , historyDetail = RemoteData.Loading
    , rating = RemoteData.Loading
    , route = route
    , settings =
      { activeTab = "History"
      , breakdownType = "MONTHS"
      , detailGroup = ""
      , sorting =
        { field = "TITLE"
        , isDesc = False
        }
      }
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
  { id: String
  , title: String
  , rating: Int
  }


emptyHistoryDetail : HistoryDetail
emptyHistoryDetail =
  HistoryDetail "" "" 0


-- Constant models

type alias Header =
  { name: String
  , number: Int
  }




-- Routing

type Route
    = StatisticsRoute
    | NotFoundRoute
