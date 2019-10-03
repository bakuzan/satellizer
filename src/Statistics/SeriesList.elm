module Statistics.SeriesList exposing (view)

import Components.Button as Button
import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h2, li, span, text, ul)
import Html.Styled.Attributes exposing (class, css, href, id, title, type_)
import Html.Styled.Events exposing (onClick)
import Models exposing (Model, RatingFilters, Series, SeriesData, Settings, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> RatingFilters -> SeriesData -> Html Msg
view model filters seriesList =
    let
        settings =
            model.settings

        ratingCount =
            List.length filters.ratings

        seriesCount =
            List.length seriesList

        seriesCountTitle =
            "Showing " ++ String.fromInt seriesCount ++ " series"

        renderTitle =
            if seriesCount < 1 then
                text ""

            else
                h2
                    [ id "series-ratings-title"
                    , css
                        [ fontSize (em 1)
                        , marginBlockStart (em 1)
                        , marginBlockEnd (em 1)
                        ]
                    ]
                    [ text seriesCountTitle ]
    in
    div [ id "series-by-ratings-container", css Styles.containerStyles ]
        [ Components.ClearableInput.view model.theme "search" "search" filters.searchText []
        , viewInvalidFilterWarning filters
        , renderTitle
        , viewSeriesList model seriesList
        ]


viewInvalidFilterWarning : RatingFilters -> Html Msg
viewInvalidFilterWarning filters =
    if List.length filters.ratings == 0 && String.length filters.searchText > 0 then
        div [ css [ color (hex "f00"), fontSize (em 0.75), margin2 (px 0) (px 10) ] ]
            [ text "A rating must be selected for results to appear" ]

    else
        text ""


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
            "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ String.fromInt entry.id
    in
    li
        [ css
            ([ displayFlex
             , justifyContent spaceBetween
             , padding2 (px 0) (px 10)
             ]
                ++ Styles.entryHoverHighlight theme
            )
        ]
        [ Components.NewTabLink.view theme [ href seriesLink ] [ text entry.name ]
        , span [] [ text (String.fromInt entry.rating) ]
        ]
