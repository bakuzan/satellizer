module Statistics.Repeated exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, href)
import Ordering exposing (Ordering)
import Msgs exposing (Msg)
import Models exposing (Model, Settings, RepeatedFilters, RepeatedSeriesData, RepeatedSeries)

import General.ClearableInput
import General.NewTabLink


view : Settings -> RepeatedFilters -> RepeatedSeriesData -> Html Msg
view settings filters repeatedList =
  let
    seriesCount =
      List.length repeatedList

    seriesCountTitle =
      "Showing " ++ (toString seriesCount) ++ " series"

    renderTitle =
      if seriesCount < 1
        then text ""
        else h4 [id "series-title"] [text seriesCountTitle]

  in
    div [id "repeated-tab"]
        [ General.ClearableInput.view "repeatedSearch" "search" filters.searchText
        , renderTitle
        , viewSeriesList settings repeatedList
        ]


seriesOrdering : Ordering RepeatedSeries
seriesOrdering =
  Ordering.byField .timesCompleted
    |> Ordering.reverse
    |> Ordering.breakTiesWith (Ordering.byField .name)

viewSeriesList : Settings -> RepeatedSeriesData -> Html Msg
viewSeriesList settings seriesList =
  let
    sortedSeriesList =
      List.sortWith seriesOrdering seriesList

  in
  ul [id "repeated-series-list", class "list column one"]
    ([] ++
     List.map (viewSeriesEntry settings.contentType) sortedSeriesList)

viewSeriesEntry : String -> RepeatedSeries -> Html Msg
viewSeriesEntry contentType entry =
  let
    seriesLink =
      "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ entry.id
  in
  li []
     [ General.NewTabLink.view [href seriesLink] [text entry.name]
     , span [] [text (toString entry.timesCompleted)]
     , span [] [text (toString entry.isOwned)]
     , span [] [text (toString entry.lastRepeatDate)]
     ]
