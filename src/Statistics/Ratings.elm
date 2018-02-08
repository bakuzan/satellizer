module Statistics.Ratings exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Msgs exposing (Msg)
import General.ProgressBar
import Statistics.SeriesList
import Models exposing (Model, SeriesData, CountData, Count, emptyCount)
import Utils.Common as Common
import Utils.Constants as Constants
import Round


view : String -> CountData -> SeriesData -> Html Msg
view searchText ratingList seriesList =
  let
    total =
      Common.calculateTotalOfValues ratingList

    ratings =
      Common.splitList 1 ratingList

    viewRatingBar =
      viewSingleRating total

  in
    div []
        [ div [id "rating-container"]
             ([ viewTotalAverageRating total ratingList
              ]
              ++ List.map viewRatingBar ratings)
        , Statistics.SeriesList.view searchText seriesList
        ]


viewTotalAverageRating : Int -> CountData -> Html Msg
viewTotalAverageRating total list =
  let
    unratedCount =
      List.reverse list
        |> List.head
        |> Maybe.withDefault emptyCount
        |> .value

    divideIt num =
      Common.divide num (total - unratedCount)
        |> Round.round 2

    weight obj =
      obj.value * (
        String.toInt obj.key
          |> Result.withDefault 0
      )

    totalAverage =
      List.map weight list
       |> List.sum
       |> divideIt

  in
  div [id "total-average-rating"]
      [ text ("Average rating: " ++ totalAverage)
      ]


viewSingleRating : Int -> CountData -> Html Msg
viewSingleRating total rating =
  let
    getRatingText obj =
      if obj.key == "0" then "-" else obj.key

    number =
      List.head rating
        |> Maybe.withDefault { key = "-", value = 0 }
        |> getRatingText

    updatedRating =
      List.map (\x -> { x | key = (setRatingKey x) }) rating

  in
  div []
      [ div [class "rating-label"] [text number]
      , General.ProgressBar.viewProgressBar total updatedRating
      ]


setRatingKey : Count -> String
setRatingKey obj =
  if obj.key == "0" then "unrated" else (getNumberName obj.key)


getNumberName : String -> String
getNumberName str =
  String.toInt str
    |> Result.withDefault 0
    |> (\x -> List.drop (x - 1) Constants.numberNames)
    |> List.head
    |> Maybe.withDefault "missing"
