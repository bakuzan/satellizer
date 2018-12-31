module Statistics.Repeated exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList, href, title)
import Msgs exposing (Msg)
import Models exposing (Model, Settings, RepeatedFilters, RepeatedSeriesData, RepeatedSeries)

import General.ClearableInput
import General.NewTabLink
import Utils.Sorters as Sorters


view : Settings -> RepeatedFilters -> RepeatedSeriesData -> Html Msg
view settings filters repeatedList =
  let
    seriesCount =
      List.length repeatedList

    seriesCountTitle =
      "Showing " ++ (String.fromInt seriesCount) ++ " series"

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


viewSeriesList : Settings -> RepeatedSeriesData -> Html Msg
viewSeriesList settings seriesList =
  let
    sortedSeriesList =
      List.sortWith Sorters.repeatedSeriesOrdering seriesList

  in
  table [id "repeated-series-table"]
        [ thead []
                [ tr [] [ th [class "left-align"]
                             [ strong []
                                      [text "Title"]
                             ]
                        , th [class "right-align"]
                             [ strong []
                                      [text "Rating"]
                             ]
                        , th [class "right-align"]
                             [ strong []
                                      [text "Repeats"]
                             ]
                        , th [class "right-align date-column"]
                             [ strong []
                                      [text "Last repeat"]
                             ]
                        ]
                ]
        , tbody []
               ([] ++
               List.map (viewSeriesEntry settings.contentType) sortedSeriesList)
        ]

viewSeriesEntry : String -> RepeatedSeries -> Html Msg
viewSeriesEntry contentType entry =
  let
    seriesLink =
      "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ entry.id

    lastRepeatDate =
      List.head entry.lastRepeatDate
        |> Maybe.withDefault "Unknown"

    isOwnedTitle =
      if entry.isOwned then "Owned" else "Not owned"

  in
  tr [id entry.id, class "repeated-series-table-row"]
     [ td [class "left-align"]
          [ div [ class "is-owned"
                , classList [("owned", entry.isOwned), ("not-owned", not entry.isOwned)]
                , title isOwnedTitle
                ]
                []
          , General.NewTabLink.view [href seriesLink, title ("View " ++ entry.name ++ " details")]
                                    [text entry.name]
          ]
     , td [class "right-align"]
          [ span [] [text (String.fromInt entry.rating)]
          ]
     , td [class "right-align"]
          [ span [] [text (String.fromInt entry.timesCompleted)]
          ]
     , td [class "right-align date-column"]
          [ span [] [text lastRepeatDate]
          ]
     ]
