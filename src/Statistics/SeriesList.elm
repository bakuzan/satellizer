module Statistics.SeriesList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id)
import Msgs exposing (Msg)
import Models exposing (Model, RatingFilters, SeriesData, Series)

import General.ClearableInput


view : RatingFilters -> SeriesData -> Html Msg
view filters seriesList =
  div [id "series-by-ratings-container"]
      [ General.ClearableInput.view "search" "search" filters.searchText
      , viewSeriesList seriesList
      ]


viewSeriesList : SeriesData -> Html Msg
viewSeriesList seriesList =
  div []
      [ text "Placeholder"
      , ul [id "series-by-ratings-list"]
           ([] ++
           List.map viewSeriesEntry seriesList)
      ]

viewSeriesEntry : Series -> Html Msg
viewSeriesEntry entry =
  li []
     [ a [] [text entry.name]
     , span [] [text (toString entry.rating)]
     ]
