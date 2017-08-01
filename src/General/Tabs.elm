module General.Tabs exposing (viewTabContainer)

import Html exposing (..)
import Html.Attributes exposing (type_, class)



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
      li [classList [("active", (first tab) == "history")]] 
         [ button [type_ "button", class "button"] 
                  [text (first tab)]
         ]
    --, role "tab"
  in
  ul [class "tab-controls row", role "tablist"]
     ([] ++ List.map generateTabButton tabList)
     
     
viewTabBodys : List (String, List (Html Msg)) -> Html Msg
viewTabBodys tabList = 
  let
    generateTabBody tab = 
      div [class "tab"]
          [(second tab)]
    --, role "tabpanel"
  in
  div [class "tabs"] 
      ([] ++ List.map generateTabBody tabList)
