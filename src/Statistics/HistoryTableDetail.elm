module Statistics.HistoryTableDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryDetailData, HistoryDetail, emptyHistoryDetail, Settings, Sort)
import Utils.TableFunctions exposing (getBreakdownName)
import Utils.Common as Common


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
      (toString (List.length data)) ++ " series for " ++ (getBreakdownName breakdown detailGroup) ++ " " ++ (Common.getYear detailGroup)

  in
  div [ class "history-detail" ]
      [ h2 [] [text detailSummary]
      , div [class "flex-row"]
            [ viewDetailList settings.sorting data
            , viewDetailBreakdowns data
            ]
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
  ul [class "history-detail-list list column one"]
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


viewDetailBreakdowns : HistoryDetailData -> Html Msg
viewDetailBreakdowns list =
  let
    average =
      Common.calculateAverageOfRatings list

    highest =
      Common.maxOfField .rating list
        |> Maybe.withDefault emptyHistoryDetail
        |> .rating

    lowest =
      Common.minOfField .rating list
        |> Maybe.withDefault emptyHistoryDetail
        |> .rating

    getHead arr =
      List.head arr
       |> Maybe.withDefault emptyHistoryDetail
       |> .rating

    notMatchHead num obj =
      obj.rating /= num

    matchHead num obj =
      obj.rating == num

    buildNest arr =
      case getHead arr of
        0 -> []
        rating -> (List.filter (matchHead rating) arr) :: buildNest (List.filter (notMatchHead rating) arr)

    mode =
      buildNest list
        |> List.foldr (\x y -> if List.length x > List.length y then x else y) []
        |> getHead

  in
  div [class "history-detail-breakdown"]
      [ ul [class "list column one"]
           [ viewBreakdownPair "Average" average
           , viewBreakdownPair "Highest" highest
           , viewBreakdownPair "Lowest" lowest
           , viewBreakdownPair "Mode" mode
           ]
      ]


viewBreakdownPair : String -> a -> Html Msg
viewBreakdownPair name statistic =
  li []
     [ strong [] [text name]
     , span [] [text (toString statistic)]
     ]
