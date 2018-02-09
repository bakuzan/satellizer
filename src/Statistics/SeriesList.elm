module Statistics.SeriesList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, href, type_, title)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Models exposing (Model, Settings, RatingFilters, SeriesData, Series)
import Utils.Common as Common

import General.ClearableInput
import General.NewTabLink


view : Settings -> RatingFilters -> SeriesData -> Html Msg
view settings filters seriesList =
  div [id "series-by-ratings-container"]
      [ General.ClearableInput.view "search" "search" filters.searchText
      , viewSelectedRatings filters.ratings
      , viewSeriesList settings seriesList
      ]

viewSelectedRatings : List Int -> Html Msg
viewSelectedRatings selectedRatings =
    ul [id "selected-ratings"]
      ([] ++
        List.map viewSelectedRating selectedRatings

viewSelectedRating : Int -> Html Msg
viewSelectedRating rating =
    li [class "input-chip input-chip-deleteable"]
       [ span [class "input-chip-text"] [text (toString rating)]
       , button [ type_ "button"
                , class "button-icon small input-chip-delete"
                , title "Remove"
                , Common.setIcon "\u2573"
                , onClick (Msgs.ToggleRatingFilter rating)
                ] []
       ]

viewSeriesList : Settings -> SeriesData -> Html Msg
viewSeriesList settings seriesList =
  ul [id "series-by-ratings-list", class "list column one"]
    ([] ++
     List.map (viewSeriesEntry settings.contentType) seriesList)

viewSeriesEntry : String -> Series -> Html Msg
viewSeriesEntry contentType entry =
  let
    seriesLink =
      "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ entry.id
  in
  li []
     [ General.NewTabLink.view [href seriesLink] [text entry.name]
     , span [] [text (toString entry.rating)]
     ]
