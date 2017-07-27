module Statistics.Core exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
-- import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Statistics.Filter
import Models exposing (Counts, CountData)
import RemoteData exposing (WebData)
import Utils.Constants as Constants


view : WebData CountData -> Html Msg
view status =
    div []
        [ Statistics.Filter.view
        , div [ class "flex-column flex-grow" ]
              [ viewStatusBreakdown status.data
              , viewHistoryTable status.data
              ]
        ]

viewStatusBreakdown : Counts -> Html Msg
viewStatusBreakdown data =
    let
      counts =
        [1,2,3,4,5]

    in
      viewProgressBar counts


-- Progress bar

viewProgressBar : List Int -> Html Msg
viewProgressBar values =
  div [ class "percentage-breakdown" ]
      (List.map viewProgressSegment values)  


viewProgressSegment : Int -> Html Msg
viewProgressSegment num =
  div [ class "percentage-breakdown__bar", style [("width", (toString num) ++ "%")] ]
      []


-- History breakdown

viewHistoryTable : WebData CountData -> Html Msg
viewHistoryTable data =
    div [ class "history-breakdown" ]
        [ table [ class "history-breakdown__table" ]
                [ viewHistoryTableHeader Constants.months
                , viewHistoryTableBody
                ]
        ]
        
        
viewHistoryTableHeader : List Constants.Header -> Html Msg
viewHistoryTableHeader headers =
    let
      displayHeader obj =
        th [] [text obj.name]
      
    in
    thead []
          [ th [] []
          , List.map displayHeader headers
          ]
    
    
viewHistoryTableBody : Html Msg
viewHistoryTableBody =
  tbody [] 
        [
        ]
        
