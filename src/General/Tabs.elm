module General.Tabs exposing (..)

import Html exposing (..)
import Html.Attributes exposing (type_, class, role)



viewTabContainer : List (String, List (Html Msg)) -> Html Msg
viewTabContainer tabList = 
  div [ class "tab-container" ] 
      [ viewTabControls tabList
      , viewTabBodys tabList
      ]
      
viewTabControls : List (String, List (Html Msg)) -> Html Msg
viewTabControls tabList = 
  let
    generateTabButton tab = 
      li [classList [("active", (first tab) == "history")], role "tab"] 
         [ button [type_ "button", class "button"] 
                  [text (first tab)]
         ]
    
  in
  ul [class "tab-controls row", role "tablist"]
     ([] ++ List.map generateTabButton tabList)
     
     
viewTabBodys : List (String, List (Html Msg)) -> Html Msg
viewTabBodys tabList = 
  let
    generateTabBody tab = 
      div [class "tab", role "tabpanel"]
          [(second tab)]
          
  in
  div [class "tabs"] 
      ([] ++ List.map generateTabBody tabList)
