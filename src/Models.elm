module Models exposing (..)
import RemoteData exposing (WebData)


type alias Model =
    { status : WebData CountData
    , route: Route
    }


initialModel : Route -> Model
initialModel route =
    { status = RemoteData.Loading
    , route = route
    }

type alias CountData =
  List Count


type alias Count =
  { key: String
  , value: Int
  }

type Route
    = StatisticsRoute String
    | NotFoundRoute
