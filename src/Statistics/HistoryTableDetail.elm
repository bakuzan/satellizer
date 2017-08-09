module Statistics.HistoryTableDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryDetailData, HistoryDetail, Settings, Sort)
import Utils.TableFunctions exposing (getBreakdownName, getYear)


view : Settings -> HistoryDetailData -> Html Msg
view settings data =
  if settings.detailGroup == ""
    then div [] []
    else viewHistoryDetail settings data


viewHistoryDetail : Settings -> HistoryDetailData -> Html Msg
viewHistoryDetail settings data =
  let
    breakdown =
      settings.breakdownType

    detailGroup =
      settings.detailGroup

    detailSummary =
      (toString (List.length data)) ++ " series for " ++ (getBreakdownName breakdown detailGroup) ++ " " ++ (getYear detailGroup)

  in
  div [ class "history-detail" ]
      [ h2 [] [text detailSummary]
      , viewDetailList settings.sorting data
      ]


viewDetailList : Sort -> HistoryDetailData -> Html Msg
viewDetailList sorting list =
  let
    isDesc =
      sorting.isDesc

    sortedList =
      if sorting.field == "TITLE"
        then sortedByTitle isDesc list
        else sortedByRating isDesc list

  in
  ul [class "list column one"]
     ([] ++ List.map viewListItem sortedList)


setDirection : Bool -> HistoryDetailData -> HistoryDetailData
setDirection isDesc arr =
  if isDesc == True
    then List.reverse arr
    else arr


sortedByTitle : Bool -> HistoryDetailData -> HistoryDetailData
sortedByTitle isDesc list =
  List.sortBy .title list
    |> setDirection isDesc


sortedByRating : Bool -> HistoryDetailData -> HistoryDetailData
sortedByRating isDesc list =
  List.sortBy .rating list
    |> setDirection isDesc


viewListItem : HistoryDetail -> Html Msg
viewListItem item =
  li [class "flex-row"]
     [ a [class "label", href ("http://localhost:9003/erza/anime-view/" ++ item.id), target "_blank"] [text item.title]
     , span [class "value"] [text (toString item.rating)]
     ]
