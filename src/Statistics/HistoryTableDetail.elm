module Statistics.HistoryTableDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryDetailData, HistoryDetail)
import Utils.TableFunctions exposing (getBreakdownName, getYear)


view : String -> String -> HistoryDetailData -> Html Msg
view breakdown detailGroup data =
  if detailGroup == ""
    then div [] []
    else viewHistoryDetail breakdown detailGroup data


viewHistoryDetail : String -> String -> HistoryDetailData -> Html Msg
viewHistoryDetail breakdown detailGroup data =
  let
    detailSummary =
      (toString (List.length data)) ++ " series for " ++ (getBreakdownName breakdown detailGroup) ++ " " ++ (getYear detailGroup)

  in
  div [ class "history-detail" ]
      [ h2 [] [text detailSummary]
      , viewDetailList data
      ]


viewDetailList : HistoryDetailData -> Html Msg
viewDetailList list =
  let
    sortedByTitle =
      List.sortBy .title list

  in
  ul [class "list column one"]
     ([ li [class "flex-row"]
           [ button [class "button ripple"] [text "sort by title"]
           , button [class "button ripple"] [text "sort by rating"]
           ]
      ] ++ List.map viewListItem sortedByTitle)


viewListItem : HistoryDetail -> Html Msg
viewListItem item =
  li [class "flex-row"]
     [ a [class "label", href ("http://localhost:9003/erza/anime-view/" ++ item.id), target "_blank"] [text item.title]
     , span [class "value"] [text (toString item.rating)]
     ]
