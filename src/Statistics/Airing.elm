module Statistics.Airing exposing (view)

import Css exposing (..)
import General.Accordion
import General.NewTabLink
import Html.Styled exposing (Html, button, div, h2, li, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id)
import Html.Styled.Events exposing (onClick)
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, Settings, Sort, emptyHistoryDetail)
import Msgs exposing (Msg)
import Round
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles
import Utils.TableFunctions exposing (getBreakdownName)


view : Settings -> HistoryDetailData -> Html Msg
view settings seriesList =
    let
        contentType =
            "anime"

        breakdown =
            "seasonal"

        detailSummary =
            String.fromInt (List.length seriesList) ++ " seasonal series airing"
    in
    div
        [ id "airing-tab" ]
        [ viewDetailBreakdowns seriesList
        , div [ class "history-detail" ]
            [ h2 [] [ text detailSummary ]
            , div [ class "flex-column" ]
                [ viewDetailTable contentType breakdown settings.sorting seriesList
                ]
            ]
        ]


viewDetailTable : String -> String -> Sort -> HistoryDetailData -> Html Msg
viewDetailTable contentType breakdown sorting list =
    let
        isDesc =
            sorting.isDesc

        sortedList =
            case sorting.field of
                "TITLE" ->
                    List.sortWith (Sorters.historyDetailOrderByTitle isDesc) list

                "RATING" ->
                    List.sortWith (Sorters.historyDetailOrderByRating isDesc) list

                "AVERAGE" ->
                    List.sortWith (Sorters.historyDetailOrderByAverage isDesc) list

                "HIGHEST" ->
                    List.sortWith (Sorters.historyDetailOrderByHighest isDesc) list

                "LOWEST" ->
                    List.sortWith (Sorters.historyDetailOrderByLowest isDesc) list

                "MODE" ->
                    List.sortWith (Sorters.historyDetailOrderByMode isDesc) list

                _ ->
                    list
    in
    table [ class "history-breakdown__table", css [ width (pct 100) ] ]
        [ viewTableHeader breakdown sorting
        , viewTableBody contentType sortedList
        ]


viewTableHeader : String -> Sort -> Html Msg
viewTableHeader breakdown sorting =
    thead []
        [ viewHeaderCell "Title" sorting [ paddingLeft (px 5), textAlign left ]
        , viewHeaderCell "Rating" sorting []
        , viewHeaderCell "Average" sorting []
        , viewHeaderCell "Highest" sorting []
        , viewHeaderCell "Lowest" sorting []
        , viewHeaderCell "Mode" sorting []
        ]


viewHeaderCell : String -> Sort -> List Css.Style -> Html Msg
viewHeaderCell title sorting style =
    let
        icon =
            if sorting.field /= String.toUpper title then
                ""

            else if sorting.isDesc == True then
                " sort--desc"

            else
                " sort--asc"
    in
    th [ css style ]
        [ button [ class "button", onClick (Msgs.UpdateSortField (String.toUpper title)) ]
            [ strong [ class ("sort" ++ icon) ]
                [ text title ]
            ]
        ]


viewTableBody : String -> HistoryDetailData -> Html Msg
viewTableBody contentType list =
    tbody [ class "history-breakdown-body" ]
        ([] ++ List.map (viewTableRow contentType) list)


viewTableRow : String -> HistoryDetail -> Html Msg
viewTableRow contentType item =
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
        , css Styles.breakdownBodyRow
        ]
        ([ td
            [ class "history-breakdown-body__month-title"
            , css [ paddingLeft (px 5), textAlign left ]
            ]
            [ General.NewTabLink.view [ href ("http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ item.id) ]
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


viewDetailBreakdowns : HistoryDetailData -> Html Msg
viewDetailBreakdowns list =
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
        [ General.Accordion.view "Overall"
            [ ul [ class "list column two" ]
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
