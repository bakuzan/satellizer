module Statistics.SeriesList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, href)
import Msgs exposing (Msg)
import Models exposing (Model, Settings, RatingFilters, SeriesData, Series)

import General.ClearableInput
import General.NewTabLink


view : Settings -> RatingFilters -> SeriesData -> Html Msg
view settings filters seriesList =
  div [id "series-by-ratings-container"]
      [ General.ClearableInput.view "search" "search" filters.searchText
      , viewSeriesList settings seriesList
      ]


viewSeriesList : Settings -> SeriesData -> Html Msg
viewSeriesList settings seriesList =
  div []
      [ ul [id "series-by-ratings-list", class "list column one"]
           ([] ++
           List.map (viewSeriesEntry settings.contentType) seriesList)
      ]

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
