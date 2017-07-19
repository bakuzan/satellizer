module Models exposing (..)
import RemoteData exposing (WebData)


type alias Model =
    { data : WebData (List Count)
    , route: Route
    }


initialModel : Route -> Model
initialModel route =
    { data = RemoteData.Loading
    , route = route
    }

type alias Count =
    { name: String
    , count: Int
    }

type Route
    = StatisticsRoute
    | NotFoundRoute
