module Statistics.SeriesList exposing (view)

import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, div, h2, li, span, text, ul)
import Html.Styled.Attributes exposing (css, href, id)
import Models exposing (Model, RatingFilters, RatingSeriesPage, Series, SeriesData, Theme)
import Msgs exposing (Msg)
import Utils.Constants as Constants
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> RatingFilters -> RatingSeriesPage -> Html Msg
view model filters seriesPage =
    let
        nodeCount =
            List.length seriesPage.nodes

        listCountHeading =
            "Showing " ++ String.fromInt nodeCount ++ " of " ++ String.fromInt seriesPage.total

        renderTitle =
            if nodeCount < 1 then
                text ""

            else
                h2
                    [ id "series-ratings-title"
                    , css
                        [ fontSize (em 1)
                        , marginBlockStart (em 1)
                        , marginBlockEnd (em 1)
                        , marginLeft (em 0.5)
                        ]
                    ]
                    [ text listCountHeading ]
    in
    div [ id "series-by-ratings-container" ]
        [ Components.ClearableInput.view model.theme "search" "search" filters.searchText []
        , renderTitle
        , viewSeriesList model seriesPage.nodes
        ]


viewSeriesList : Model -> SeriesData -> Html Msg
viewSeriesList model seriesList =
    let
        sortedSeriesList =
            List.sortWith Sorters.seriesOrdering seriesList
    in
    ul [ id "series-by-ratings-list", css (Styles.list model.theme True 1 ++ [ minWidth (px 200), maxWidth (pct 75) ]) ]
        ([]
            ++ List.map (viewSeriesEntry model.theme model.settings.contentType) sortedSeriesList
        )


viewSeriesEntry : Theme -> String -> Series -> Html Msg
viewSeriesEntry theme contentType entry =
    let
        seriesLink =
            Constants.erzaSeriesLink contentType entry.id
    in
    li
        [ css
            ([ displayFlex
             , justifyContent spaceBetween
             , padding2 (px 0) (px 4)
             ]
                ++ Styles.entryHoverHighlight theme
            )
        ]
        [ Components.NewTabLink.view theme [ href seriesLink ] [ text entry.name ]
        , span [] [ text (String.fromInt entry.rating) ]
        ]
