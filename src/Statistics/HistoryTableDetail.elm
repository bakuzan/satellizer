module Statistics.HistoryTableDetail exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing(onClick)
import Msgs exposing (Msg)
import Models exposing (HistoryDetailData, HistoryDetail, emptyHistoryDetail, EpisodeStatistic, Settings, Sort)
import General.Accordion
import General.NewTabLink
import Utils.TableFunctions exposing (getBreakdownName)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Round


view : Settings -> HistoryDetailData -> Html Msg
view settings data =
  if settings.detailGroup == ""
    then div [] []
    else viewHistoryDetail settings data


viewHistoryDetail : Settings -> HistoryDetailData -> Html Msg
viewHistoryDetail settings data =
  let
    contentType =
      settings.contentType

    breakdown =
      settings.breakdownType

    detailGroup =
      settings.detailGroup

    isYearBreakdown =
      not (String.contains "-" settings.detailGroup)

    displayPartition =
      if isYearBreakdown
        then ""
        else getBreakdownName breakdown detailGroup

    detailSummary =
      (toString (List.length data)) ++ " series for " ++ displayPartition ++ " " ++ (Common.getYear detailGroup)

  in
  div []
      [ viewDetailBreakdowns data
      , div [ class "history-detail" ]
            [ h2 [] [text detailSummary]
            , div [class "flex-column", classList [("year-breakdown", isYearBreakdown)]]
                  [ viewDetailTable contentType breakdown settings.sorting data
                  ]
            ]
      ]


viewDetailTable : String -> String -> Sort -> HistoryDetailData -> Html Msg
viewDetailTable contentType breakdown sorting list =
  let
    isDesc =
      sorting.isDesc

    sortedList =
      case sorting.field of
        "TITLE" -> List.sortWith (Sorters.historyDetailOrderByTitle isDesc) list
        "RATING" -> List.sortWith (Sorters.historyDetailOrderByRating isDesc) list
        "AVERAGE" -> List.sortWith (Sorters.historyDetailOrderByAverage isDesc) list
        "HIGHEST" -> List.sortWith (Sorters.historyDetailOrderByHighest isDesc) list
        "LOWEST" -> List.sortWith (Sorters.historyDetailOrderByLowest isDesc) list
        "MODE" -> List.sortWith (Sorters.historyDetailOrderByMode isDesc) list
        _ -> list

  in
  table [class "history-breakdown__table"]
        [ viewTableHeader breakdown sorting
        , viewTableBody contentType sortedList
        ]


viewTableHeader : String -> Sort -> Html Msg
viewTableHeader breakdown sorting =
  let
    hideHeader =
      breakdown == "MONTHS"

  in
  thead []
        [ viewHeaderCell False "Title" sorting "history-breakdown-body__month-title"
        , viewHeaderCell False "Rating" sorting ""
        , viewHeaderCell hideHeader "Average" sorting ""
        , viewHeaderCell hideHeader "Highest" sorting ""
        , viewHeaderCell hideHeader "Lowest" sorting ""
        , viewHeaderCell hideHeader "Mode" sorting ""
        ]


viewHeaderCell : Bool -> String -> Sort -> String -> Html Msg
viewHeaderCell hide title sorting classes =
  let
    icon =
      if sorting.field /= (String.toUpper title)
        then ""
        else
          if sorting.isDesc == True
            then " sort--desc"
            else " sort--asc"

  in
  th [classList [("hidden", hide)], class classes]
     [ button [class "button", onClick (Msgs.UpdateSortField (String.toUpper title))]
              [ strong [class ("sort" ++ icon)]
                       [text title]
              ]
     ]


viewTableBody : String -> HistoryDetailData -> Html Msg
viewTableBody contentType list =
  tbody [class "history-breakdown-body"]
        ([] ++ List.map (viewTableRow contentType) list)


viewTableRow : String -> HistoryDetail -> Html Msg
viewTableRow contentType item =
  let
    es =
      item.episodeStatistics

    indicate =
      if es.id /= "" && es.lowest == 0
        then "* "
        else ""

    setTitleIndication =
      (indicate ++ item.title)

  in
  tr [class "history-breakdown-body__row month-breakdown", classList [(String.toLower item.season, True)]]
     ([ td [class "history-breakdown-body__month-title"]
           [ General.NewTabLink.view [href ("http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ item.id)]
                                     [text setTitleIndication]
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
      [ General.Accordion.view "Overall" [ ul [class "list column two"]
                                              ([]
                                              ++ viewBreakdownPair "Average" average
                                              ++ viewBreakdownPair "Highest" highest
                                              ++ viewBreakdownPair "Lowest" lowest
                                              ++ viewBreakdownPair "Mode" mode)
                                         ]
      ]


viewBreakdownPair : String -> a -> List (Html Msg)
viewBreakdownPair name statistic =
  [ li [class "label"]
       [ text name
       ]
  , li [class "value"]
       [ text (toString statistic)
       ]
  ]
