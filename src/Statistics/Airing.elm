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
        [ viewDetailBreakdowns model.theme seriesList
        , div [ class "history-detail" ]
            [ h2 [ css [ fontSize (em 1.25) ] ] [ text detailSummary ]
            , div [ class "flex-column" ]
                [ table [ class "history-breakdown__table", css [ width (pct 100) ] ]
                    [ thead []
                        [ renderHeaderCell "Title" [ paddingLeft (px 5), textAlign left ]
                        , renderHeaderCell "Rating" []
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
                    , Styles.icon
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
         , renderCell (String.fromInt item.rating)
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


viewDetailBreakdowns : Theme -> HistoryDetailData -> Html Msg
viewDetailBreakdowns theme list =
    let
        listNoZeroes =
            List.filter (\x -> x.rating /= 0) list

        average =
            Common.calculateAverageOfRatings list

        highest =
            Common.maxOfField .rating list
                |> Maybe.withDefault emptyHistoryDetail
                |> .rating

        lowest =
            Common.minOfField .rating listNoZeroes
                |> Maybe.withDefault emptyHistoryDetail
                |> .rating

        getHead arr =
            List.head arr
                |> Maybe.withDefault emptyHistoryDetail
                |> .rating

        notMatchHead num obj =
            obj.rating /= num

        matchHead num obj =
            obj.rating == num

        buildNest arr =
            case getHead arr of
                0 ->
                    []

                rating ->
                    List.filter (matchHead rating) arr :: buildNest (List.filter (notMatchHead rating) arr)

        mode =
            buildNest listNoZeroes
                |> List.foldr
                    (\x y ->
                        if List.length x > List.length y then
                            x

                        else
                            y
                    )
                    []
                |> getHead
    in
    div [ class "history-detail-breakdown" ]
        [ Components.Accordion.view theme
            "AiringOverall"
            "Overall"
            [ ul [ css (Styles.list theme True 2) ]
                ([]
                    ++ viewBreakdownPair "Average" (String.fromFloat average)
                    ++ viewBreakdownPair "Highest" (String.fromInt highest)
                    ++ viewBreakdownPair "Lowest" (String.fromInt lowest)
                    ++ viewBreakdownPair "Mode" (String.fromInt mode)
                )
            ]
        ]


viewBreakdownPair : String -> String -> List (Html Msg)
viewBreakdownPair name statistic =
    [ li [ class "label" ]
        [ text name
        ]
    , li [ class "value" ]
        [ text statistic
        ]
    ]
