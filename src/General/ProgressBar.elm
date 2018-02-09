module General.ProgressBar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList, style, title, attribute)
import Msgs exposing(Msg)
import Models exposing(CountData, Count)
import Utils.Common exposing (divide)
import Round


viewProgressBar : Int -> CountData -> Html Msg
viewProgressBar total values =
  let
    segments =
      List.map (viewProgressSegment total) values

    progressItems =
      if (List.length values) > 1
        then segments
        else (segments ++ [ div [class "vertically-center", style [("padding", "0 10px")] ] [text (singleSegmentPercentage values total)]
                        ])
  in
    div [ class "percentage-breakdown" ]
        ([] ++ progressItems)


viewProgressSegment : Int -> Count -> Html Msg
viewProgressSegment total pair =
  let
    percentageString =
      (toString (getPercentage pair.value total)) ++ "%"

    percentage =
      getPercentage pair.value total

    isLongEnough =
      percentage > 11

  in
  div [ class "percentage-breakdown__bar"
      , classList [(pair.key, True), ("tooltip-bottom", isLongEnough), ("tooltip-right", not isLongEnough)]
      , style [("width", percentageString)]
      , attribute "hover-data" ((toString pair.value) ++ " series " ++ pair.key)
      ]
      []

getPercentage : Int -> Int -> Float
getPercentage value total =
  (divide value total) * 100

singleSegmentPercentage : CountData -> Int -> String
singleSegmentPercentage values total =
  let
    appendSign value =
      value ++ "%"

    returnPercentage num =
      getPercentage num total
       |> Round.round 2
       |> appendSign

  in
  List.head values
    |> Maybe.withDefault { key = "", value = 0 }
    |> .value
    |> returnPercentage
