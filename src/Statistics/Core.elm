module Statistics.Core exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Msgs exposing (Msg)
import General.ProgressBar
import Statistics.Filter
import Statistics.HistoryTable
import Models exposing (Model, CountData)
import RemoteData exposing (WebData)


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
    status =
      model.status

    history =
      model.history

  in
    div [class "flex-row"]
        [ Statistics.Filter.view
        , div [ class "flex-column flex-grow" ]
              [ viewRender status |> viewStatus
              , viewRender history |> Statistics.HistoryTable.view
              ]
        ]


viewStatus : CountData -> Html Msg
viewStatus list =
  let
    total =
     List.map (\x -> x.value) list
      |> List.foldr (+) 0

  in
    div [id "status-container"]
        [General.ProgressBar.viewProgressBar total list
        ]
