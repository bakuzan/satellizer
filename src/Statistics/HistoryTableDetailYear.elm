module Statistics.HistoryTableDetailYear exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryYearData, HistoryYear, Settings)
import Utils.Common as Common


view : Settings -> HistoryYearData -> Html Msg
view settings data =
  if settings.detailGroup == ""
    then div [] []
    else viewHistoryYearDetail settings data


viewHistoryYearDetail : Settings -> HistoryYearData -> Html Msg
viewHistoryYearDetail settings data =
  let
    breakdown =
      settings.breakdownType

    detailGroup =
      settings.detailGroup

    getYearCount = 
      Common.calculateTotalOfValuesTemp data
    
    detailSummary =
      (toString getYearCount) ++ " series for " ++ detailGroup

  in
  div [ class "history-detail" ]
      [ h2 [] [text detailSummary]
      , div [class "flex-row"]
            [ 
            ]
      ]

