module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Route(..))
import UrlParser as Url exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map StatisticsRoute top
        ]

-- Need a way to route the url from "/" to "/statistics" OR "/statistics/:type" so the below will work
-- map StatisticsRoute (s "statistics" </> string) , for "/anime" OR "/manga"

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
