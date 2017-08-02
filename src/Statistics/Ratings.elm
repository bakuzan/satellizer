module Statistics.Ratings exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Msgs exposing (Msg)
import General.ProgressBar
import Models exposing (Model, CountData)
import Utils.Common as Common



view : CountData -> Html Msg
view list =
  let
    total =
      Common.calculateTotalOfValues list

    ratings =
      Common.splitList 1 list

    viewRatingBar =
      viewSingleRating total

  in
    div [id "rating-container"]
        ([]
        ++ List.map viewRatingBar ratings)



viewSingleRating : Int -> CountData -> Html Msg
viewSingleRating total rating =
  let
    getRatingText obj =
      if obj.key == "0" then "-" else obj.key
    
    number =
      List.head rating
        |> Maybe.withDefault { key = "-", value = 0 }
        |> getRatingText
  
  in
  div []
      [ span [] [text number]
      , General.ProgressBar.viewProgressBar total rating
      ]
      
