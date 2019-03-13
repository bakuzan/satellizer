module Statistics.Airing exposing (view)

import Components.Accordion
import Components.Button as Button
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h2, li, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id)
import Html.Styled.Events exposing (onClick)
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, Model, Settings, Sort, Theme, emptyHistoryDetail)
import Msgs exposing (Msg)
import Round
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles
import Utils.TableFunctions exposing (getBreakdownName)


view : Model -> HistoryDetailData -> Html Msg
view model seriesList =
    let
        detailSummary =
            String.fromInt (List.length seriesList) ++ " seasonal series airing"

        sorting =
            model.settings.sorting

        isDesc =
            sorting.isDesc

        sortedList =
            Sorters.sortHistoryDetailList sorting.field sorting.isDesc seriesList

        renderHeaderCell =
            viewHeaderCell sorting model.theme
    in
    div
        [ id "airing-tab" ]
        [ div [ class "history-detail" ]
            [ h2 [ css [ fontSize (em 1.25) ] ] [ text detailSummary ]
            , div [ class "flex-column" ]
                [ table [ class "history-breakdown__table", css [ width (pct 100) ] ]
                    [ thead []
                        [ renderHeaderCell "Title" [ paddingLeft (px 5), textAlign left ]
                        , renderHeaderCell "Average" []
                        , renderHeaderCell "Highest" []
                        , renderHeaderCell "Lowest" []
                        , renderHeaderCell "Mode" []
                        ]
                    , tbody [ class "history-breakdown-body" ]
                        ([] ++ List.map (viewTableRow model.theme) sortedList)
                    ]
                ]
            ]
        ]


viewHeaderCell : Sort -> Theme -> String -> List Css.Style -> Html Msg
viewHeaderCell sorting theme title styles =
    let
        icon =
            if sorting.field /= String.toUpper title then
                ""

            else if sorting.isDesc == True then
                "▼"

            else
                "▲"
    in
    th
        [ css styles ]
        [ Button.view { isPrimary = False, theme = theme }
            [ onClick (Msgs.UpdateSortField (String.toUpper title)) ]
            [ strong
                [ Common.setIcon icon
                , css
                    [ lineHeight (int 1)
                    , Styles.iconAfter
                    ]
                ]
                [ text title ]
            ]
        ]


viewTableRow : Theme -> HistoryDetail -> Html Msg
viewTableRow theme item =
    let
        es =
            item.episodeStatistics

        indicate =
            if es.id /= "" && es.lowest == 0 then
                "* "

            else
                ""

        setTitleIndication =
            indicate ++ item.title
    in
    tr
        [ class "history-breakdown-body__row month-breakdown"
        , classList [ ( String.toLower item.season, True ) ]
        , css (Styles.breakdownBodyRow theme)
        ]
        ([ td
            [ class "history-breakdown-body__month-title"
            , css [ paddingLeft (px 5), textAlign left ]
            ]
            [ Components.NewTabLink.view theme
                [ href ("http://localhost:9003/erza/anime-view/" ++ item.id) ]
                [ text setTitleIndication ]
            ]
         ]
            ++ renderEpisodeStatistics es
        )


renderEpisodeStatistics : EpisodeStatistic -> List (Html Msg)
renderEpisodeStatistics es =
    let
        processFloat avg =
            Round.round 2 avg
    in
    if es.id /= "" then
        [ renderCell (processFloat es.average)
        , renderCell (String.fromInt es.highest)
        , renderCell (String.fromInt es.lowest)
        , renderCell (String.fromInt es.mode)
        ]

    else
        []


renderCell : String -> Html Msg
renderCell str =
    td [ css [ textAlign center ] ]
        [ text str
        ]
