module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (WebData)
import Utils.Constants as Constants



view : WebData CountData -> Html Msg
view data =
    div [ class "history-breakdown" ]
        [ table [ class "history-breakdown__table" ]
                [ viewHeader Constants.months
                , viewBody
                ]
        ]
        
        
viewHeader : List Constants.Header -> Html Msg
viewHeader headers =
    let
      displayHeader obj =
        th [] [text obj.name]
      
    in
    thead []
          [ th [] []
          , List.map displayHeader headers
          ]
    
    
viewBody : Html Msg
viewBody =
  tbody [] 
        [
        ]
