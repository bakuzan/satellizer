module Statistics.HistoryTableDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryDetailData, HistoryDetail, emptyHistoryDetail, EpisodeStatistic, Settings, Sort)
import Utils.TableFunctions exposing (getBreakdownName)
import Utils.Common as Common
import Round


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
            [ viewDetailTable breakdown settings.sorting data
            ]
      ]


viewDetailTable : String -> Sort -> HistoryDetailData -> Html Msg
viewDetailTable breakdown sorting list =
  let
    isDesc =
      sorting.isDesc

    sortedList =
      if sorting.field == "TITLE"
        then sortedByTitle isDesc list
        else sortedByRating isDesc list

  in
  table [class "history-breakdown__table"]
        [ viewTableHeader breakdown
        , viewTableBody sortedList
        ]


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


viewTableHeader : String -> Html Msg
viewTableHeader breakdown =
  let
    hideHeader =
      breakdown == "MONTHS"

  in
  thead []
        [ th [class "history-breakdown-body__month-title"] [text "Title"]
        , viewHeaderCell False "Rating"
        , viewHeaderCell hideHeader "Average"
        , viewHeaderCell hideHeader "Highest"
        , viewHeaderCell hideHeader "Lowest"
        , viewHeaderCell hideHeader "Mode"
        ]


viewHeaderCell : Bool -> String -> Html Msg
viewHeaderCell hide title =
  th [classList [("hidden", hide)]] [text title]


viewTableBody : HistoryDetailData -> Html Msg
viewTableBody list =
  tbody [class "history-breakdown-body"]
        ([] ++ List.map viewTableRow list)


viewTableRow : HistoryDetail -> Html Msg
viewTableRow item =
  let
    es =
      item.episodeStatistics

  in
  tr [class "history-breakdown-body__row month-breakdown"]
     ([ td [class "history-breakdown-body__month-title"]
           [ a [href ("http://localhost:9003/erza/anime-view/" ++ item.id), target "_blank"]
               [text item.title]
           ]
      , renderCell (toString item.rating)
      ] ++ renderEpisodeStatistics es)


renderEpisodeStatistics : EpisodeStatistic -> List (Html Msg)
renderEpisodeStatistics es =
  let
    processFloat avg =
      Round.round 2 avg

  in
  if es.id /= ""
    then [ renderCell (processFloat es.average)
         , renderCell (toString es.highest)
         , renderCell (toString es.lowest)
         , renderCell (toString es.mode)
         ]
    else []


renderCell : String -> Html Msg
renderCell str =
  td []
     [ text str
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
