module Statistics.Repeated exposing (view)

import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h4, span, strong, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (class, classList, css, href, id, title)
import Models exposing (Model, RepeatedFilters, RepeatedSeries, RepeatedSeriesData, Settings, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles


leftAlign : List Css.Style
leftAlign =
    [ textAlign left ]


rightAlign : List Css.Style
rightAlign =
    [ textAlign right ]


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
                h4 [ id "series-title" ] [ text seriesCountTitle ]
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
            , maxWidth (pct 75)
            ]
        ]
        [ thead []
            [ tr []
                [ th [ class "left-align", css leftAlign ]
                    [ strong []
                        [ text "Title" ]
                    ]
                , th [ class "right-align", css rightAlign ]
                    [ strong []
                        [ text "Rating" ]
                    ]
                , th [ class "right-align", css rightAlign ]
                    [ strong []
                        [ text "Repeats" ]
                    ]
                , th [ class "right-align date-column", css (rightAlign ++ [ minWidth (px 105) ]) ]
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
        , css (Styles.breakdownBodyRow theme)
        ]
        [ td [ class "left-align", css leftAlign ]
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
            , Components.NewTabLink.view theme
                [ href seriesLink, title ("View " ++ entry.title ++ " details") ]
                [ text entry.title ]
            ]
        , td [ class "right-align", css rightAlign ]
            [ span [] [ text (String.fromInt entry.rating) ]
            ]
        , td [ class "right-align", css rightAlign ]
            [ span [] [ text (String.fromInt entry.timesCompleted) ]
            ]
        , td [ class "right-align date-column", css (rightAlign ++ [ minWidth (px 105) ]) ]
            [ span [] [ text lastRepeatDate ]
            ]
        ]
