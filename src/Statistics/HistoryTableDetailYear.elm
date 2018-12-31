module Statistics.HistoryTableDetailYear exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryYearData, HistoryYear, emptyHistoryYear, Settings)
import Utils.Constants as Constants
import Utils.Common as Common
import Round


view : Settings -> HistoryYearData -> Html Msg
view settings data =
  if settings.detailGroup == ""
    then div [] []
    else viewHistoryYearDetail settings data


viewHistoryYearDetail : Settings -> HistoryYearData -> Html Msg
viewHistoryYearDetail settings data =
  let
    breakdown =
      settings.breakdownType

    detailGroup =
      settings.detailGroup

    getYearCount =
      Common.calculateTotalOfValuesTemp data

  in
  div [ class "history-detail" ]
      [ div [class "flex-row"]
            [ viewDetailTable breakdown data
            ]
      ]


viewDetailTable : String -> HistoryYearData -> Html Msg
viewDetailTable breakdown data =
  table [class "history-breakdown__table", classList [(String.toLower breakdown, True), ("year", True)] ]
        [ viewTableHead breakdown
        , viewTableBody breakdown data
        ]


viewTableHead : String -> Html Msg
viewTableHead breakdown =
  let
    viewHeader obj =
      th [class (String.toLower obj.name)]
         [ text obj.name
         ]

    getHeaderList =
      if breakdown == "MONTHS"
        then Constants.months
        else Constants.seasons

  in
  thead [class "history-breakdown-header"]
        ([ th [] []
        ] ++ List.map viewHeader getHeaderList)



viewTableBody : String -> HistoryYearData -> Html Msg
viewTableBody breakdown data =
  let
   fixValue =
     if breakdown == "MONTHS" then 1 else -2

   getKey x =
     String.right 2 ("0" ++ (String.fromInt (x.number + fixValue)))

   fixedData =
     let
       values =
         List.map .id data

     in
     List.filter (\x -> not (List.member (getKey x) values)) headers
       |> List.map (\x -> { emptyHistoryYear | id = (getKey x) })
       |> List.append data

   headers =
     if breakdown == "MONTHS" then Constants.months else Constants.seasons

   cells =
    List.sortBy .id fixedData

  in
    tbody [class "history-breakdown-body"]
          [ viewTableRow "Average" (floatToString .average) cells
          , viewTableRow "Highest" (intToString .highest) cells
          , viewTableRow "Lowest" (intToString .lowest) cells
          , viewTableRow "Mode" (intToString .mode) cells
          ]

floatToString : (HistoryYear -> Float) -> HistoryYear -> String
floatToString fun v =
  Round.round 2 (fun v)
  
intToString : (HistoryYear -> Int) -> HistoryYear -> String
intToString fun v =
  String.fromInt (fun v)

viewTableRow : String -> (HistoryYear -> String) -> HistoryYearData -> Html Msg
viewTableRow name fun data =
  tr [class "history-breakdown-body__row year-breakdown"]
    ([ th [class "history-breakdown-body__year-statistic"]
          [text name]
      ] ++ List.map (\x -> fun x |> viewTableCell) data)

viewTableCell : String -> Html Msg
viewTableCell value =
  td []
     [text value]

