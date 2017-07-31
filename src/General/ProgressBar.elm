module General.ProgressBar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, title, attribute)
import Msgs exposing(Msg)
import Models exposing(CountData, Count)
import Utils.Common exposing (divide)


viewProgressBar : Int -> CountData -> Html Msg
viewProgressBar total values =
  div [ class "percentage-breakdown" ]
      (List.map (viewProgressSegment total) values)


viewProgressSegment : Int -> Count -> Html Msg
viewProgressSegment total pair =
  div [ class ("percentage-breakdown__bar" ++ " " ++ pair.key)
      , style [("width", (getPercentage pair.value total))]
      , attribute "hover-data" ((toString pair.value) ++ " " ++ pair.key)
      ]
      []

getPercentage : Int -> Int -> String
getPercentage value total =
  (toString ((divide value total) * 100)) ++ "%"
