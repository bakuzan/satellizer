module Statistics.HistoryTableDetail exposing (view)

import Components.Accordion
import Components.NewTabLink
import Components.TableSortHeader as TSH
import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import Html.Styled exposing (Html, div, h2, li, table, tbody, td, text, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, title)
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, Model, Sort, Theme, emptyHistoryDetail)
import Msgs exposing (Msg)
import Round
import Tuple
import Utils.Colours exposing (getSeasonColour)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Sorters as Sorters
import Utils.Styles as Styles
import Utils.TableFunctions exposing (getBreakdownName)


type alias DetailTableProps =
    { isYearBreakdown : Bool
    , contentType : String
    , detailGroup : String
    , breakdown : String
    , theme : Theme
    , sorting : Sort
    }


view : Model -> HistoryDetailData -> Html Msg
view model data =
    if model.settings.detailGroup == "" then
        text ""

    else
        viewHistoryDetail model data


viewHistoryDetail : Model -> HistoryDetailData -> Html Msg
viewHistoryDetail model data =
    let
        settings =
            model.settings

        contentType =
            settings.contentType

        breakdown =
            settings.breakdownType

        detailGroup =
            settings.detailGroup

        isYearBreakdown =
            not (String.contains "-" settings.detailGroup)

        displayPartition =
            if isYearBreakdown then
                ""

            else
                getBreakdownName breakdown detailGroup

        detailSummary =
            String.fromInt (List.length data) ++ " series for " ++ displayPartition ++ " " ++ Common.getYear detailGroup
    in
    div []
        [ viewDetailBreakdowns model.theme data
        , div
            [ class "history-detail"
            , css
                [ margin2 (px 20) (px 10)
                ]
            ]
            [ h2
                [ css
                    [ fontSize (em 1.25)
                    , padding (px 5)
                    , margin2 (px 10) (px 5)
                    , textAlign left
                    ]
                ]
                [ text detailSummary ]
            , div
                [ classList [ ( "year-breakdown", isYearBreakdown ) ]
                , css
                    [ displayFlex
                    , flexDirection column
                    ]
                ]
                [ viewDetailTable
                    { contentType = contentType
                    , breakdown = breakdown
                    , sorting = settings.sorting
                    , detailGroup = settings.detailGroup
                    , isYearBreakdown = isYearBreakdown
                    , theme = model.theme
                    }
                    data
                ]
            ]
        ]


viewDetailTable : DetailTableProps -> HistoryDetailData -> Html Msg
viewDetailTable props list =
    let
        sorting =
            props.sorting

        sortedList =
            Sorters.sortHistoryDetailList sorting.field sorting.isDesc list
    in
    table
        [ class "history-breakdown__table"
        , css
            [ width (pct 100)
            ]
        ]
        [ viewTableHeader props
        , viewTableBody props sortedList
        ]


viewTableHeader : DetailTableProps -> Html Msg
viewTableHeader props =
    let
        hideHeader =
            props.breakdown == "MONTH"

        renderHeaderCell =
            TSH.view props.sorting props.theme
    in
    thead []
        ([ td
            [ css
                [ padding2 (px 0) (px 4)
                , textAlign center
                ]
            ]
            [ text "#" ]
         , renderHeaderCell "Title"
            [ justifyContent flexStart
            ]
         , renderHeaderCell "Rating"
            [ padding (px 2)
            , margin2 (px 0) auto
            ]
         ]
            ++ (if hideHeader then
                    []

                else
                    [ renderHeaderCell "Average"
                        [ padding (px 2)
                        ]
                    , renderHeaderCell "Highest"
                        [ padding (px 2)
                        ]
                    , renderHeaderCell "Lowest"
                        [ padding (px 2)
                        ]
                    , renderHeaderCell "Mode"
                        [ padding (px 2)
                        ]
                    ]
               )
        )


viewTableBody : DetailTableProps -> HistoryDetailData -> Html Msg
viewTableBody props list =
    let
        tuples =
            List.indexedMap Tuple.pair list
    in
    tbody [ class "history-breakdown-body" ]
        ([] ++ List.map (viewTableRow props) tuples)


viewTableRow : DetailTableProps -> ( Int, HistoryDetail ) -> Html Msg
viewTableRow props tup =
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

        includeSeasonIdentifiers =
            props.isYearBreakdown && props.breakdown /= "MONTH"

        additonalStyles =
            if includeSeasonIdentifiers then
                [ hover
                    (getSeasonColour seasonStr
                        ++ [ children
                                [ typeSelector "td > a"
                                    [ backgroundColor inherit
                                    , color inherit
                                    ]
                                ]
                           ]
                    )
                ]

            else
                []

        metaMessage =
            if includeSeasonIdentifiers then
                "Series started in " ++ seasonStr ++ " " ++ props.detailGroup

            else
                ""
    in
    tr
        [ class "history-breakdown-body__row month-breakdown"
        , classList [ ( seasonStr, True ) ]
        , css (Styles.entryHoverHighlight props.theme ++ additonalStyles)
        , Common.setCustomAttr "aria-label" metaMessage
        ]
        ([ td
            [ css
                [ padding2 (px 0) (px 4)
                , textAlign center
                ]
            , title metaMessage
            ]
            [ text (String.fromInt (idx + 1) |> String.padLeft 3 '0') ]
         , td
            [ class "history-breakdown-body__month-title"
            , css [ padding2 (px 0) (px 4), textAlign left ]
            ]
            [ Components.NewTabLink.view props.theme
                [ href (Constants.erzaSeriesLink props.contentType item.id)
                , css
                    [ width (pct 75)
                    , textAlign left
                    ]
                ]
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
    if es.lowest /= -1 then
        [ renderCell (processFloat es.average)
        , renderCell (String.fromInt es.highest)
        , renderCell (String.fromInt es.lowest)
        , renderCell (String.fromInt es.mode)
        ]

    else
        []


renderCell : String -> Html Msg
renderCell str =
    td [ css [ padding2 (px 0) (px 4), textAlign center ] ]
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
    div [ class "history-detail-breakdown", css [ margin2 (px 10) (px 0) ] ]
        [ Components.Accordion.view theme
            "Overall"
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
    [ li [ class "label", css [ displayFlex, justifyContent spaceBetween ] ]
        [ text name
        ]
    , li [ class "value", css [ displayFlex, justifyContent spaceBetween ] ]
        [ text statistic
        ]
    ]
