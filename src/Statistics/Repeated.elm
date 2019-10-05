module Statistics.Repeated exposing (view)

import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h2, span, strong, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (class, classList, css, href, id, title)
import Models exposing (Model, RepeatedFilters, RepeatedSeries, RepeatedSeriesData, Settings, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> RepeatedFilters -> RepeatedSeriesData -> Html Msg
view model filters repeatedList =
    let
        settings =
            model.settings

        seriesCount =
            List.length repeatedList

        seriesCountTitle =
            "Showing " ++ String.fromInt seriesCount ++ " series"

        renderTitle =
            if seriesCount < 1 then
                text ""

            else
                h2 [ id "series-title", css [ fontSize (rem 1) ] ] [ text seriesCountTitle ]
    in
    div [ id "repeated-tab", css (Styles.listTabStyles ++ [ flexDirection column ]) ]
        [ Components.ClearableInput.view model.theme "repeatedSearch" "search" filters.searchText []
        , renderTitle
        , viewSeriesList model repeatedList
        ]


viewSeriesList : Model -> RepeatedSeriesData -> Html Msg
viewSeriesList model seriesList =
    let
        sortedSeriesList =
            List.sortWith Sorters.repeatedSeriesOrdering seriesList
    in
    table
        [ id "repeated-series-table"
        , css
            [ minWidth (px 400)
            , maxWidth (pct 80)
            ]
        ]
        [ thead []
            [ tr []
                [ th [] []
                , th [ class "left-align", css Styles.leftAlign ]
                    [ strong []
                        [ text "Title" ]
                    ]
                , th [ class "right-align", css Styles.rightAlign ]
                    [ strong []
                        [ text "Rating" ]
                    ]
                , th [ class "right-align", css Styles.rightAlign ]
                    [ strong []
                        [ text "Repeats" ]
                    ]
                , th [ class "right-align date-column", css (Styles.rightAlign ++ [ minWidth (px 105) ]) ]
                    [ strong []
                        [ text "Last repeat" ]
                    ]
                ]
            ]
        , tbody []
            ([]
                ++ List.map (viewSeriesEntry model.theme model.settings.contentType) sortedSeriesList
            )
        ]


viewSeriesEntry : Theme -> String -> RepeatedSeries -> Html Msg
viewSeriesEntry theme contentType entry =
    let
        seriesLink =
            "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ String.fromInt entry.id

        lastRepeatDate =
            if entry.lastRepeatDate == "" then
                "Unknown"

            else
                entry.lastRepeatDate

        isOwnedTitle =
            if entry.isOwned then
                "Owned"

            else
                "Not owned"

        icon =
            if entry.isOwned then
                "✓"

            else
                "❌︎"
    in
    tr
        [ id (String.fromInt entry.id)
        , class "repeated-series-table-row"
        , css (Styles.entryHoverHighlight theme)
        ]
        [ td [ css [ padding2 (px 0) (px 4), textAlign center ] ]
            [ div
                [ class "is-owned"
                , classList [ ( "owned", entry.isOwned ), ( "not-owned", not entry.isOwned ) ]
                , title isOwnedTitle
                , Common.setCustomAttr "aria-label" isOwnedTitle
                , Common.setIcon icon
                , css
                    [ Styles.icon
                    , display inlineBlock
                    , width (px 20)
                    , height (pct 100)
                    , lineHeight (int 1)
                    , before
                        [ fontSize (em 0.8)
                        , fontWeight bold
                        ]
                    ]
                ]
                []
            ]
        , td [ class "left-align", css (Styles.leftAlign ++ [ padding2 (px 0) (px 4) ]) ]
            [ Components.NewTabLink.view theme
                [ href seriesLink, title ("View " ++ entry.title ++ " details") ]
                [ text entry.title ]
            ]
        , td [ class "right-align", css (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ]) ]
            [ span [] [ text (String.fromInt entry.rating) ]
            ]
        , td [ class "right-align", css (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ]) ]
            [ span [] [ text (String.fromInt entry.timesCompleted) ]
            ]
        , td [ class "right-align date-column", css (Styles.rightAlign ++ [ minWidth (px 105), padding2 (px 0) (px 4) ]) ]
            [ span [] [ text lastRepeatDate ]
            ]
        ]
