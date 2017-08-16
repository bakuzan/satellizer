module General.ProgressBar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, title, attribute)
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
      else (segments ++ [ span [] [text (singleSegmentPercentage values total)]
                        ])
in
  div [ class "percentage-breakdown" ]
      ([] ++ progressItems)


viewProgressSegment : Int -> Count -> Html Msg
viewProgressSegment total pair =
  div [ class ("percentage-breakdown__bar tooltip-bottom" ++ " " ++ pair.key)
      , style [("width", (getPercentage pair.value total))]
      , attribute "hover-data" ((toString pair.value) ++ " series " ++ pair.key)
      ]
      []

getPercentage : Int -> Int -> String
getPercentage value total =
  (toString ((divide value total) * 100)) ++ "%"


singleSegmentPercentage : CountData -> Int -> String
singleSegmentPercentage values total = 
  let
    returnPercentage num = 
      Round.round 2 (toFloat (getPercentage num total))
      
  in
  List.head values
    |> Maybe.withDefault { key = "", value = 0 }
    |> .value
    |> returnPercentage
  
