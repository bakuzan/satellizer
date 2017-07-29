module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (Count, CountData)
import Utils.Constants as Constants
import Utils.Common as Common


view : CountData -> Html Msg
view data =
    div [ class "history-breakdown" ]
        [ table [ class "history-breakdown__table" ]
                [ viewHeader Constants.months
                , viewBody data
                ]
        ]
        
        
viewHeader : List Constants.Header -> Html Msg
viewHeader headers =
    let
      displayHeader obj =
        th [] [text obj.name]
      
    in
    thead []
          ([ th [] []
          ] ++ List.map displayHeader headers)
    
    
viewBody : CountData -> Html Msg
viewBody data =
  let
    createRows = 
      Common.splitList 12 data
      
  in
  tbody [] 
        ([] ++ List.map viewRow createRows)


viewRow : List Count -> Html msg
viewRow cells = 
 tr []
    ([ th [] [text "YEAR"]
    ] ++ List.map viewCell cells)
 
 
viewCell : Count -> Html msg
viewCell cell = 
   td []
      [ text cell.key
      ]
