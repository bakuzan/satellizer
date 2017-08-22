module Statistics.HistoryTableDetailYear exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (HistoryYearData, HistoryYear, Settings)
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

    detailSummary =
      (toString getYearCount) ++ " series for " ++ detailGroup

  in
  div [ class "history-detail" ]
      [ h2 [] [text detailSummary]
      , div [class "flex-row"]
            [ viewDetailTable breakdown data
            ]
      ]


viewDetailTable : String -> HistoryYearData -> Html Msg
viewDetailTable breakdown data =
  table [class ("history-breakdown__table " ++ (String.toLower breakdown))]
        [ viewTableHead breakdown
        , viewTableBody data
        ]


viewTableHead : String -> Html Msg
viewTableHead breakdown =
  let
    viewHeader obj =
      th []
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



viewTableBody : HistoryYearData -> Html Msg
viewTableBody data =
  tbody [class "history-breakdown-body"]
        [ viewTableRow "Average" .average data
        , viewTableRow "Highest" .highest data
        , viewTableRow "Lowest" .lowest data
        , viewTableRow "Mode" .mode data
        ]


viewTableRow : String -> (HistoryYear -> comparable) -> HistoryYearData -> Html Msg
viewTableRow name fun data =
  let
    processValue val isFloat =
      if isFloat == True
        then String.toFloat val
               |> Result.withDefault 0.0
               |> Round.round 2
        else val

    formatValue val =
      toString val
       |> String.contains "."
       |> (processValue (toString val))

    viewTableCell x =
      td [] [text (formatValue (fun x))]

  in
  tr [class "history-breakdown-body__row year-breakdown"]
     ([ th [class "history-breakdown-body__year-statistic"] [text name]
     ] ++ List.map viewTableCell data)
