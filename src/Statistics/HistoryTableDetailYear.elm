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
        , viewTableBody breakdown data
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



viewTableBody : String -> HistoryYearData -> Html Msg
viewTableBody breakdown data =
  let
   fixValue =
     if breakdown == "MONTHS" then 1 else -2

   getKey x =
     String.right 2 ("0" ++ (toString (x.number + fixValue)))

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
          [ viewTableRow "Average" .average cells
          , viewTableRow "Highest" .highest cells
          , viewTableRow "Lowest" .lowest cells
          , viewTableRow "Mode" .mode cells
          ]


viewTableRow : String -> (HistoryYear -> comparable) -> HistoryYearData -> Html Msg
viewTableRow name fun data =
  tr [class "history-breakdown-body__row year-breakdown"]
     ([ th [class "history-breakdown-body__year-statistic"] 
           [text name]
      ] ++ List.map (viewTableCell fun) data)


viewTableCell : (HistoryYear -> comparable) -> HistoryYear -> Html Msg
viewTableCell fun obj =
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
    
  in
    td [] 
       [text (formatValue (fun obj))]
