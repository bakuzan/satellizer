module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Models exposing (Count, CountData, HistoryDetailData, HistoryYearData, Header, Settings, emptyCount)
import General.RadioButton exposing (viewRadioGroup)
import Statistics.HistoryTableDetail
import Statistics.HistoryTableDetailYear
import Utils.Constants as Constants
import Utils.Common as Common
import Utils.TableFunctions exposing (getBreakdownName)


view : Settings -> CountData -> HistoryDetailData -> HistoryYearData -> Html Msg
view settings data detail yearDetail =
  let
    breakdownType =
      settings.breakdownType

  in
    div [ class "history-breakdown" ]
        [ viewBreakdownToggle breakdownType
        , viewTable data breakdownType
        , viewTableDetail settings detail yearDetail
        ]


viewBreakdownToggle : String -> Html Msg
viewBreakdownToggle state =
  viewRadioGroup "breakdown" state Constants.breakdownOptions


viewTableDetail : Settings -> HistoryDetailData -> HistoryYearData -> Html Msg
viewTableDetail settings detail yearDetail =
  if (String.contains "-" settings.detailGroup) == True
    then Statistics.HistoryTableDetail.view settings detail
    else Statistics.HistoryTableDetailYear.view settings yearDetail


viewTable : CountData -> String -> Html Msg
viewTable countData breakdown =
  let
    total =
      Common.maxOfField .value data
        |> Maybe.withDefault { key = "Empty", value = 0 }
        |> .value

    data =
      List.sortBy .key countData
       |> List.reverse

    headers =
      if breakdown == "MONTHS" then Constants.months else Constants.seasons

  in
  table [ class ("history-breakdown__table " ++ (String.toLower breakdown)) ]
          [ viewHeader headers
          , viewBody breakdown total data
          ]


viewHeader : List Header -> Html Msg
viewHeader headers =
    let
      displayHeader obj =
        th [] [text obj.name]

    in
    thead [class "history-breakdown-header"]
          ([ th [] []
          ] ++ List.map displayHeader headers)


viewBody : String -> Int -> CountData -> Html Msg
viewBody breakdown total data =
  let
    displayRow =
      viewRow breakdown total

  in
  tbody [class "history-breakdown-body"]
        ([] ++ List.map displayRow (split data))


viewRow : String -> Int -> List Count -> Html Msg
viewRow breakdown total data =
 let
   fixValue =
     if breakdown == "MONTHS" then 1 else -2
     
   getKey x =
     String.right 2 ("0" ++ (toString (x.number + fixValue)))

   fixedData =
     let
       values =
         List.map (\x -> (Common.getMonth x.key)) data

     in
     List.filter (\x -> not (List.member (getKey x) values)) headers
       |> List.map (\x -> { emptyCount | key = (rowYear ++ "-" ++ (getKey x)) })
       |> List.append data

   headers =
     if breakdown == "MONTHS" then Constants.months else Constants.seasons

   cells =
    List.sortBy .key fixedData

   rowYear =
    Common.getYear (Common.getListFirst data)

 in
 tr [class "history-breakdown-body__row"]
    ([ th []
          [ button [class "button", onClick (Msgs.DisplayHistoryDetail rowYear)]
                   [text rowYear
                   ]
          ]
     ]
    ++ List.map (viewCell breakdown total) cells
    )


viewCell : String -> Int -> Count -> Html Msg
viewCell breakdown total obj =
  let
    viewDate str =
      (getBreakdownName breakdown str) ++ " " ++ (Common.getYear str)
      
    isDisabled = 
      obj.value == 0

  in
   td [ attribute "hover-data" ((toString obj.value) ++ " in " ++ (viewDate obj.key))
      , class "history-breakdown-body__data-cell"
      , classList [("disabled", isDisabled)]
      ]
      [ button [onClick (Msgs.DisplayHistoryDetail obj.key), disabled isDisabled]
               [ div [ class"history-breakdown-body__data-cell__background"
                     , style [("opacity", toString (Common.divide obj.value total))]
                     ]
                     []
               ]
      ]


split : CountData -> List CountData
split list =
  case Common.getListFirst list of
    "" -> []
    listHead -> (List.filter (matchHead listHead) list) :: split (List.filter (notMatchHead listHead) list)


matchHead : String -> Count -> Bool
matchHead head obj =
 (Common.getYear obj.key) == (Common.getYear head)


notMatchHead : String -> Count -> Bool
notMatchHead head obj =
 not (matchHead head obj)
