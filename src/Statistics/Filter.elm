module Statistics.Filter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList, href)
import Msgs exposing (Msg)
import Utils.Constants as Constants


view : Html Msg
view =
    div [ class "list-filter" ]
        [ text "LIST FILTERS WILL GO HERE"
        , div [ class "button-group" ]
              [ viewFilterLink Constants.type.anime
              , viewFilterLink Constants.type.manga
              ]
        ]

viewFilterLink : Html Msg
viewFilterLink str =
    a [ class "button-link", classList [("active", False)], href ("" ++ str) ] [ text str ]
