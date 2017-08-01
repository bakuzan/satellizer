module General.Tabs exposing (viewTabContainer)

import Html exposing (..)
import Html.Attributes exposing (type_, class)
import Html.Events exposing (onClick)
import Msgs exposing (UpdateActiveTab)
import Utils.Common as Common



viewTabContainer : String -> List (String, List (Html Msg)) -> Html Msg
viewTabContainer activeTab tabList = 
  div [ class "tab-container" ] 
      [ viewTabControls activeTab tabList
      , viewTabBodys activeTab tabList
      ]
      
      
viewTabControls : String -> List (String, List (Html Msg)) -> Html Msg
viewTabControls activeTab tabList = 
  let
    generateTabButton tab = 
      li [classList [("active", (getTabName tab) == activeTab)], Common.setRole "tab"] 
         [ button [type_ "button", class "button", onClick (UpdateActiveTab (getTabName tab))] 
                  [text (getTabName tab)]
         ]

  in
  ul [class "tab-controls row", Common.setRole "tablist"]
     ([] ++ List.map generateTabButton tabList)
     
     
viewTabBodys : String -> List (String, List (Html Msg)) -> Html Msg
viewTabBodys activeTab tabList = 
  let
    generateTabBody tab = 
      div [class "tab", classList [("active", (getTabName tab) == activeTab)], Common.setRole "tabpanel"]
          ([] ++ Tuple.second tab)
    
  in
  div [class "tabs"] 
      ([] ++ List.map generateTabBody tabList)


getTabName : (String, List (Html Msg)) -> String
getTabName tab = 
  Tuple.first tab
