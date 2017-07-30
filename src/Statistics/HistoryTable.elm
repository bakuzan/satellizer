module Statistics.HistoryTable exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)
import Models exposing (Count, CountData)
import Utils.Constants as Constants
import Utils.Common as Common


view : CountData -> Html Msg
view data =
    div [ class "history-breakdown" ]
        [ viewTable data
        ]

viewTable : CountData -> Html Msg
viewTable countData =
  let
    total =
     List.map (\x -> x.value) data
      |> List.foldr (+) 0

    data =
      List.sortBy .key countData
       |> List.reverse


  in
  table [ class "history-breakdown__table" ]
          [ viewHeader Constants.months
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
   td [ title ((toString obj.value) ++ " of " ++ (toString total) ++ " series")
      , class "history-breakdown-body__data-cell"
      , style [("opacity", toString (Common.divide obj.value total))]
      ]
      [ text ""
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
