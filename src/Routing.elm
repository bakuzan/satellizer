module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map StatisticsRoute top
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


-- app ui paths

basePath : String
basePath =
  "statistics/"

animePath : String
animePath =
  basePath ++ "anime"

mangaPath : String
mangaPath =
  basePath ++ "manga"
