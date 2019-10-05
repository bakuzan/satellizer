module Statistics.Airing exposing (view)

import Components.Accordion
import Components.Button as Button
import Components.NewTabLink
import Components.TableSortHeader as TSH
import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import Html.Styled exposing (Html, button, div, h2, li, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id)
import Html.Styled.Events exposing (onClick)
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, Model, Settings, Sort, Theme, emptyHistoryDetail)
import Msgs exposing (Msg)
import Round
import Tuple
import Utils.Colours exposing (getSeasonColour)
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

        tupes =
            List.indexedMap Tuple.pair sortedList

        renderHeaderCell =
            TSH.view sorting model.theme
    in
    div
        [ id "airing-tab" ]
        [ div [ class "history-detail" ]
            [ h2 [ css [ fontSize (em 1.25) ] ] [ text detailSummary ]
            , div [ class "flex-column" ]
                [ table [ class "history-breakdown__table", css [ width (pct 100) ] ]
                    [ thead []
                        [ td
                            [ css
                                [ padding2 (px 0) (px 4)
                                , textAlign center
                                ]
                            ]
                            [ text "#" ]
                        , renderHeaderCell "Title" [ children [ typeSelector "button" [ justifyContent flexStart ] ] ]
                        , renderHeaderCell "Average" []
                        , renderHeaderCell "Highest" []
                        , renderHeaderCell "Lowest" []
                        , renderHeaderCell "Mode" []
                        ]
                    , tbody [ class "history-breakdown-body" ]
                        ([] ++ List.map (viewTableRow model.theme) tupes)
                    ]
                ]
            ]
        ]


viewTableRow : Theme -> ( Int, HistoryDetail ) -> Html Msg
viewTableRow theme tup =
    let
        ( idx, item ) =
            tup

        es =
            EpisodeStatistic item.average item.highest item.lowest item.mode

        indicate =
            if es.lowest == 0 then
                "* "

            else
                ""

        setTitleIndication =
            indicate ++ item.title

        seasonStr =
            String.toLower item.season

        seasonStyles =
            [ hover
                [ backgroundColor (hex (getSeasonColour seasonStr))
                , color (hex "fff")
                , children
                    [ typeSelector "td > a"
                        [ backgroundColor inherit
                        , color inherit
                        ]
                    ]
                ]
            ]
    in
    tr
        [ class "history-breakdown-body__row month-breakdown"
        , classList [ ( seasonStr, True ) ]
        , css (Styles.entryHoverHighlight theme ++ seasonStyles)
        ]
        ([ td
            [ css
                [ padding2 (px 0) (px 4)
                , textAlign center
                ]
            ]
            [ text (String.fromInt (idx + 1) |> String.padLeft 3 '0') ]
         , td
            [ class "history-breakdown-body__month-title"
            , css [ paddingLeft (px 5), textAlign left ]
            ]
            [ Components.NewTabLink.view theme
                [ href ("http://localhost:9003/erza/anime-view/" ++ String.fromInt item.id) ]
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
    [ renderCell (processFloat es.average)
    , renderCell (String.fromInt es.highest)
    , renderCell (String.fromInt es.lowest)
    , renderCell (String.fromInt es.mode)
    ]


renderCell : String -> Html Msg
renderCell str =
    td [ css [ textAlign center ] ]
        [ text str
        ]
