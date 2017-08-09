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


viewRender : WebData (List a) -> List a
viewRender model =
  case model of
    RemoteData.NotAsked -> []
    RemoteData.Loading -> []
    RemoteData.Failure err -> []

    RemoteData.Success model -> model


view : Model -> Html Msg
view model =
  let
    activeTab =
      model.settings.activeTab

    status =
      model.status

    history =
      viewRender model.history

    detail =
      viewRender model.historyDetail

    ratings =
      model.rating

  in
    div [class "flex-row"]
        [ Statistics.Filter.view model.settings
        , div [ class "flex-column flex-grow" ]
              [ viewRender status |> viewStatus
              , viewTabContainer activeTab [("History", [Statistics.HistoryTable.view model.settings history detail])
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
