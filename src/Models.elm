module Models exposing (..)
import RemoteData exposing (WebData)


type alias Model =
    { status : WebData Counts
    , route: Route
    }


initialModel : Route -> Model
initialModel route =
    { status = RemoteData.Loading
    , route = route
    }

type alias CountData =
  { data: Counts
  }

type alias Counts =
    { ongoing: Count
    , complete: Count
    , onhold: Count
    , total: Count
    }

type alias Count =
  { count: Int
  }

type Route
    = StatisticsRoute
    | NotFoundRoute
