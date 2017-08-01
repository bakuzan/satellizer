module Statistics.Core exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Msgs exposing (Msg)
import General.ProgressBar
import General.Tabs exposing (..)
import Statistics.Filter
import Statistics.HistoryTable
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
              , viewTabContainer activeTab [("History", viewRender history |> Statistics.HistoryTable.view breakdownType)
                                           ,("Ratings", viewRender ratings |> viewRatings)
                                           ]
              ]
        ]


calculateTotalOfValues : CountData -> Int
calculateTotalOfValues list =
  List.map (\x -> x.value) list
    |> List.foldr (+) 0


viewStatus : CountData -> Html Msg
viewStatus list =
  let
    total =
      calculateTotalOfValues list

  in
    div [id "status-container"]
        [General.ProgressBar.viewProgressBar total list
        ]


viewRatings : CountData -> Html Msg
viewRatings list =
  let
    total =
      calculateTotalOfValues list

    ratings =
      Common.splitList 1 list

    viewRatingBar =
      viewSingleRating total

  in
    div [id "status-container"]
        ([]
        ++ List.map viewRatingBar ratings)



viewSingleRating : Int -> CountData -> Html Msg
viewSingleRating total rating =
  General.ProgressBar.viewProgressBar total rating
