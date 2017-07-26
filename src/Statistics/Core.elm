module Statistics.Core exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
-- import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Statistics.Filter
import Models exposing (Counts, CountData)
import RemoteData exposing (WebData)


view : WebData CountData -> Html Msg
view status =
    div []
        [ Statistics.Filter.view
		, viewStatusBreakdown status.data
        , viewHistoryTable status.data
        ]

viewStatusBreakdown : Counts -> Html Msg
viewStatusBreakdown data =
    let
      counts =
        [1,2,3,4,5]

      progressSegment num =
        div [ class "percentage-breakdown__bar" ]
            [ div [ style [("width", (toString num) ++ "%")] ] []
            ]

    in
      div [ class "percentage-breakdown" ]
          (List.map progressSegment counts)

viewHistoryTable : WebData CountData -> Html Msg
viewHistoryTable data =
    div [ class "history-breakdown" ]
        [ table [ class "history-breakdown__table" ]
                [
                ]
        ]
