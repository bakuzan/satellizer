module Statistics.Ratings exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList, style)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import General.ProgressBar
import Statistics.SeriesList
import Models exposing (Model, Settings, RatingFilters, SeriesData, CountData, Count, emptyCount)
import Utils.Common as Common
import Utils.Constants as Constants
import Round


tempSeriesList : SeriesData
tempSeriesList =
    [
    { id = "1"
    , name = "Baccano"
    , rating = 8
    },
    { id = "2"
    , name = "snow queen"
    , rating = 7
    },
    { id = "3"
    , name = "durarara"
    , rating = 9
    }
    ]


view : Settings -> RatingFilters -> CountData -> SeriesData -> Html Msg
view settings filters ratingList seriesList =
  let
    total =
      Common.calculateTotalOfValues ratingList

    ratings =
      Common.splitList 1 ratingList

    viewRatingBar =
      viewSingleRating filters.ratings total

  in
    div [id "ratings-tab"]
        [ div [id "rating-container"]
             ([ viewTotalAverageRating total ratingList
              ]
              ++ List.map viewRatingBar ratings)
        , Statistics.SeriesList.view settings filters tempSeriesList
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


viewSingleRating : List Int -> Int -> CountData -> Html Msg
viewSingleRating selectedRatings total rating =
  let
    getRatingText obj =
      if obj.key == "0" then "-" else obj.key

    numberObj =
      List.head rating
        |> Maybe.withDefault { key = "-", value = 0 }

    number =
      numberObj
        |> .value

    numberString =
      numberObj
        |> getRatingText

    isSelected =
      List.member number selectedRatings

    updatedRating =
      List.map (\x -> { x | key = (setRatingKey x) }) rating

  in
  div []
      [ button [class "button ripple rating-label", classList [("selected", isSelected)], onClick (Msgs.ToggleRatingFilter number)]
               [text numberString]
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
