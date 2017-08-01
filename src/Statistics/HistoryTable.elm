module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (Count, CountData)
import General.RadioButton exposing (viewRadioGroup)
import Utils.Constants as Constants
import Utils.Common as Common


view : String -> CountData -> Html Msg
view breakdownType data =
    div [ class "history-breakdown" ]
        [ viewBreakdownToggle breakdownType
        , viewTable data breakdownType
        ]


viewBreakdownToggle : String -> Html Msg
viewBreakdownToggle state =
  viewRadioGroup "breakdown" state [{ label = "Months", optionValue = "MONTHS" }, { label = "Season", optionValue = "SEASON" }]


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
  table [ class "history-breakdown__table" ]
          [ viewHeader headers
          , viewBody total data
          ]


viewHeader : List Constants.Header -> Html Msg
viewHeader headers =
    let
      displayHeader obj =
        th [] [text obj.name]

    in
    thead [class "history-breakdown-header"]
          ([ th [] []
          ] ++ List.map displayHeader headers)


viewBody : Int -> CountData -> Html Msg
viewBody total data =
  let
    displayRow =
      viewRow total

  in
  tbody [class "history-breakdown-body"]
        ([] ++ List.map displayRow (split data))


viewRow : Int -> List Count -> Html Msg
viewRow total data =
 let
   cells =
    List.sortBy .key data

 in
 tr [class "history-breakdown-body__row"]
    ([ th []
          [text (getYear (getListFirst data))
          ]
     ]
    ++ List.map (viewCell total) cells
    )


viewCell : Int -> Count -> Html Msg
viewCell total obj =
  let
    viewDate str =
      (getMonthName str) ++ " " ++ (getYear str)

  in
   td [ attribute "hover-data" ((toString obj.value) ++ " in " ++ (viewDate obj.key))
      , class "history-breakdown-body__data-cell"
      ]
      [ div [style [("opacity", toString (Common.divide obj.value total))]]
            []
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


getYear : String -> String
getYear str =
  String.slice 0 4 str


getMonthName : String -> String
getMonthName str =
  getMonthHeader str
    |> .name


getMonthHeader : String -> Constants.Header
getMonthHeader str =
  let
    grabListItem num =
      List.drop (num - 1) Constants.months
        |> List.head
        |> Maybe.withDefault { name = "Invalid", number = 0 }

  in
  String.slice 5 (String.length str) str
    |> String.toInt
    |> Result.withDefault 0
    |> grabListItem
