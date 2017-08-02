module Statistics.Core exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Msgs exposing (Msg)
import General.ProgressBar
import General.Tabs exposing (..)
import Statistics.Filter
import Statistics.HistoryTable
import Statistics.Ratings
import Models exposing (Model, CountData)
import RemoteData exposing (WebData)
import Utils.Common as Common


viewRender : WebData CountData -> CountData
viewRender model =
  case model of
    RemoteData.NotAsked -> []
    RemoteData.Loading -> []
    RemoteData.Failure err -> []

    RemoteData.Success model -> model


view : Model -> Html Msg
view model =
  let
    breakdownType =
      model.breakdownType

    activeTab =
      model.activeTab

    status =
      model.status

    history =
      model.history

    ratings =
      model.rating

  in
    div [class "flex-row"]
        [ Statistics.Filter.view
        , div [ class "flex-column flex-grow" ]
              [ viewRender status |> viewStatus
              , viewTabContainer activeTab [("History", [viewRender history |> Statistics.HistoryTable.view breakdownType])
                                           ,("Ratings", [viewRender ratings |> Statistics.Ratings.view])
                                           ]
              ]
        ]



viewStatus : CountData -> Html Msg
viewStatus list =
  let
    total =
      Common.calculateTotalOfValues list

  in
    div [id "status-container"]
        [General.ProgressBar.viewProgressBar total list
        ]


