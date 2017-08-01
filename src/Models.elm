module Models exposing (..)
import RemoteData exposing (WebData)


type alias Model =
    { status : WebData CountData
    , history: WebData CountData
    , rating: WebData CountData
    , route: Route
    , activeTab: String
    , breakdownType: String
    }


initialModel : Route -> Model
initialModel route =
    { status = RemoteData.Loading
    , history = RemoteData.Loading
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


-- Constant models

type alias Header = 
  { name: String
  , number: Int
  }

type alias RadioOption =
  { label: String
  , optionValue: String
  }


-- Routing

type Route
    = StatisticsRoute
    | NotFoundRoute
