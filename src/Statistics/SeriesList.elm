module Statistics.SeriesList exposing (view)

import Components.Button as Button
import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h4, li, span, text, ul)
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
                h4 [ id "series-ratings-title" ] [ text seriesCountTitle ]
    in
    div [ id "series-by-ratings-container", css Styles.containerStyles ]
        [ Components.ClearableInput.view model.theme "search" "search" filters.searchText []
        , div [ class "ratings-filters", css [ displayFlex, marginTop (px 5) ] ]
            [ viewSelectedRatings model.theme filters.ratings
            , viewClearRatings model.theme ratingCount
            ]
        , renderTitle
        , viewSeriesList model seriesList
        ]


viewClearRatings : Theme -> Int -> Html Msg
viewClearRatings theme ratingCount =
    if ratingCount < 1 then
        text ""

    else
        Button.view { isPrimary = False, theme = theme }
            [ id "clear-selected"
            , onClick Msgs.ClearSelectedRatings
            ]
            [ text "Clear all ratings" ]


viewSelectedRatings : Theme -> List Int -> Html Msg
viewSelectedRatings theme selectedRatings =
    ul
        [ id "selected-ratings"
        , css
            (Styles.list theme True 0
                ++ [ flex3 (int 1) (int 1) (pct 75)
                   , minWidth (px 200)
                   , maxWidth (pct 75)
                   ]
            )
        ]
        ([]
            ++ List.map (viewSelectedRating theme) selectedRatings
        )


viewSelectedRating : Theme -> Int -> Html Msg
viewSelectedRating theme rating =
    li
        [ css
            [ displayFlex
            , alignItems center
            , height (px 32)
            , lineHeight (px 32)
            , backgroundColor (hex "ccc")
            , color (hex "555")
            , padding2 (px 0) (px 12)
            , paddingRight (px 2)
            , borderRadius (px 16)
            , margin2 (px 0) (px 2)
            ]
        ]
        [ span [ css [ fontSize (em 1.2) ] ] [ text (String.fromInt rating) ]
        , Button.viewIcon "❌︎"
            { isPrimary = False, theme = theme }
            [ css
                [ important (backgroundColor inherit)
                , color (hex "555")
                , fontSize (em 0.8)
                ]
            , title "Remove"
            , Common.setCustomAttr "aria-label" "Remove"
            , onClick (Msgs.ToggleRatingFilter rating)
            ]
            []
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
            "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ String.fromInt entry.id
    in
    li [ css [ displayFlex, justifyContent spaceBetween, padding2 (px 0) (px 10) ] ]
        [ Components.NewTabLink.view theme [ href seriesLink ] [ text entry.name ]
        , span [] [ text (String.fromInt entry.rating) ]
        ]
