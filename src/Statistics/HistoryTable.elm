module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Models exposing (Count, CountData, HistoryDetailData, Header)
import General.RadioButton exposing (viewRadioGroup)
import Statistics.HistoryTableDetail
import Utils.Constants as Constants
import Utils.Common as Common
import Utils.TableFunctions exposing (getBreakdownName, getYear)


view : String -> CountData -> String -> HistoryDetailData -> Html Msg
view breakdownType data detailGroup detail =
    div [ class "history-breakdown" ]
        [ viewBreakdownToggle breakdownType
        , viewTable data breakdownType
        , Statistics.HistoryTableDetail.view breakdownType detailGroup detail
        ]


viewBreakdownToggle : String -> Html Msg
viewBreakdownToggle state =
  viewRadioGroup "breakdown" state Constants.breakdownOptions


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
   cells =
    List.sortBy .key data

 in
 tr [class "history-breakdown-body__row"]
    ([ th []
          [text (getYear (getListFirst data))
          ]
     ]
    ++ List.map (viewCell breakdown total) cells
    )


viewCell : String -> Int -> Count -> Html Msg
viewCell breakdown total obj =
  let
    viewDate str =
      (getBreakdownName breakdown str) ++ " " ++ (getYear str)

  in
   td [ attribute "hover-data" ((toString obj.value) ++ " in " ++ (viewDate obj.key))
      , class "history-breakdown-body__data-cell"
      ]
      [ button [onClick (Msgs.DisplayHistoryDetail obj.key)]
               [ div [ class"history-breakdown-body__data-cell__background"
                     , style [("opacity", toString (Common.divide obj.value total))]
                     ]
                     []
               ]
      ]


getListFirst : List Count -> String
getListFirst list =
  List.head list
   |> Maybe.withDefault { key = "", value = 0 }
   |> .key


split : CountData -> List CountData
split list =
  case getListFirst list of
    "" -> []
    listHead -> (List.filter (matchHead listHead) list) :: split (List.filter (notMatchHead listHead) list)


matchHead : String -> Count -> Bool
matchHead head obj =
 (getYear obj.key) == (getYear head)


notMatchHead : String -> Count -> Bool
notMatchHead head obj =
 not (matchHead head obj)
