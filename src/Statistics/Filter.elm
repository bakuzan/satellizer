module Statistics.Filter exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList, href, value)
import Html.Events exposing (onInput)
import Msgs exposing (Msg)
import Models exposing (Settings, Sort)
import General.RadioButton exposing(viewRadioGroup, RadioOption)
import Utils.Constants as Constants


view : Settings -> Html Msg
view settings =
    div [ class "list-filter" ]
        [ text "LIST FILTERS WILL GO HERE"
        , div [ class "button-group" ]
              [ viewFilterLink (Constants.itemType |> .anime)
              , viewFilterLink (Constants.itemType |> .manga)
              ]
        , viewSortingSettings settings
        ]


viewFilterLink : String -> Html Msg
viewFilterLink str =
    a [ class "button-link", classList [("active", False)], href ("" ++ str) ] [ text str ]


viewSortingSettings : Settings -> Html Msg
viewSortingSettings settings =
  if settings.detailGroup == "" || (not (String.contains "-" settings.detailGroup))
    then div [] []
    else
      div [class "sorting-controls"]
          [ h4 [] [text "History detail"]
          , div []
                [ viewSortingSelection settings.sorting settings.breakdownType
                , viewSortingDirection settings.sorting
                ]
          ]


viewSortingSelection : Sort -> String -> Html Msg
viewSortingSelection sorting breakdown =
  let
    additionalFields =
      if breakdown == "MONTHS"
        then []
        else [ viewSortingOption "Average"
             , viewSortingOption "Highest"
             , viewSortingOption "Lowest"
             , viewSortingOption "Mode"
             ]

  in
  div [class "has-float-label select-container"]
      [ select [class "select-box", value sorting.field, onInput Msgs.UpdateSortField]
         ([ viewSortingOption "Title"
          , viewSortingOption "Rating"
          ] ++ additionalFields)
      ]


viewSortingOption : String -> Html Msg
viewSortingOption txt =
  option [value (String.toUpper txt)] [text txt]


viewSortingDirection : Sort -> Html Msg
viewSortingDirection sorting =
  viewRadioGroup "direction" (toString sorting.isDesc) getSortingDirections


getSortingDirections : List RadioOption
getSortingDirections =
  [{ label = "ASC", optionValue = "False", action = Msgs.UpdateSortDirection False }
  ,{ label = "DESC", optionValue = "True", action = Msgs.UpdateSortDirection True }
  ]
