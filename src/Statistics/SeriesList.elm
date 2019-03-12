module Statistics.SeriesList exposing (view)

import Css exposing (..)
import General.ClearableInput
import General.NewTabLink
import Html.Styled exposing (Html, button, div, h4, li, span, text, ul)
import Html.Styled.Attributes exposing (class, css, href, id, title, type_)
import Html.Styled.Events exposing (onClick)
import Models exposing (Model, RatingFilters, Series, SeriesData, Settings)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Settings -> RatingFilters -> SeriesData -> Html Msg
view settings filters seriesList =
    let
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
        [ General.ClearableInput.view "search" "search" filters.searchText
        , div [ class "ratings-filters", css [ displayFlex, marginTop (px 5) ] ]
            [ viewSelectedRatings filters.ratings
            , viewClearRatings ratingCount
            ]
        , renderTitle
        , viewSeriesList settings seriesList
        ]


viewClearRatings : Int -> Html Msg
viewClearRatings ratingCount =
    if ratingCount < 1 then
        text ""

    else
        button
            [ type_ "button"
            , id "ckear-selected"
            , class "button ripple"
            , onClick Msgs.ClearSelectedRatings
            ]
            [ text "Clear all ratings" ]


viewSelectedRatings : List Int -> Html Msg
viewSelectedRatings selectedRatings =
    ul
        [ id "selected-ratings"
        , class "list"
        , css
            [ flex3 (int 1) (int 1) (pct 75)
            , minWidth (px 200)
            , maxWidth (pct 75)
            ]
        ]
        ([]
            ++ List.map viewSelectedRating selectedRatings
        )


viewSelectedRating : Int -> Html Msg
viewSelectedRating rating =
    li [ class "input-chip input-chip-deleteable" ]
        [ span [ class "input-chip-text" ] [ text (String.fromInt rating) ]
        , button
            [ type_ "button"
            , class "button-icon small input-chip-delete"
            , title "Remove"
            , Common.setIcon "╳"
            , Common.setCustomAttr "aria-label" "Remove"
            , onClick (Msgs.ToggleRatingFilter rating)
            ]
            []
        ]


viewSeriesList : Settings -> SeriesData -> Html Msg
viewSeriesList settings seriesList =
    let
        sortedSeriesList =
            List.sortWith Sorters.seriesOrdering seriesList
    in
    ul [ id "series-by-ratings-list", class "list column one", css [ minWidth (px 200), maxWidth (pct 75) ] ]
        ([]
            ++ List.map (viewSeriesEntry settings.contentType) sortedSeriesList
        )


viewSeriesEntry : String -> Series -> Html Msg
viewSeriesEntry contentType entry =
    let
        seriesLink =
            "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ entry.id
    in
    li [ css [ displayFlex, justifyContent spaceBetween, padding2 (px 0) (px 10) ] ]
        [ General.NewTabLink.view [ href seriesLink ] [ text entry.name ]
        , span [] [ text (String.fromInt entry.rating) ]
        ]
