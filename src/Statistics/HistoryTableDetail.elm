module Statistics.HistoryTableDetail exposing (view)

import Components.Accordion
import Components.Button as Button
import Components.NewTabLink
import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import Html.Styled exposing (Html, button, div, h2, li, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id, style)
import Html.Styled.Events exposing (onClick)
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, Model, Settings, Sort, Theme, emptyHistoryDetail)
import Msgs exposing (Msg)
import Round
import Utils.Colours exposing (getSeasonColour)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles
import Utils.TableFunctions exposing (getBreakdownName)


type alias DetailTableProps =
    { isYearBreakdown : Bool
    , contentType : String
    , breakdown : String
    , theme : Theme
    , sorting : Sort
    }


type alias HeaderProps =
    { hide : Bool
    , title : String
    , style : List Css.Style
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
            props.breakdown == "MONTHS"

        renderHeaderCell =
            viewHeaderCell props.sorting props.theme
    in
    thead []
        [ renderHeaderCell { hide = False, title = "Title", style = [ paddingLeft (px 5), textAlign left ] }
        , renderHeaderCell { hide = False, title = "Rating", style = [] }
        , renderHeaderCell { hide = hideHeader, title = "Average", style = [] }
        , renderHeaderCell { hide = hideHeader, title = "Highest", style = [] }
        , renderHeaderCell { hide = hideHeader, title = "Lowest", style = [] }
        , renderHeaderCell { hide = hideHeader, title = "Mode", style = [] }
        ]


viewHeaderCell : Sort -> Theme -> HeaderProps -> Html Msg
viewHeaderCell sorting theme props =
    let
        icon =
            if sorting.field /= String.toUpper props.title then
                ""

            else if sorting.isDesc == True then
                "▼"

            else
                "▲"
    in
    th
        [ css
            (if props.hide then
                [ display none ]

             else
                props.style
            )
        ]
        [ Button.view { isPrimary = False, theme = theme }
            [ onClick (Msgs.UpdateSortField (String.toUpper props.title)) ]
            [ strong
                [ Common.setIcon icon
                , css
                    [ lineHeight (int 1)
                    , Styles.icon
                    ]
                ]
                [ text props.title ]
            ]
        ]


viewTableBody : DetailTableProps -> HistoryDetailData -> Html Msg
viewTableBody props list =
    tbody [ class "history-breakdown-body" ]
        ([] ++ List.map (viewTableRow props) list)


viewTableRow : DetailTableProps -> HistoryDetail -> Html Msg
viewTableRow props item =
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

        seasonStr =
            String.toLower item.season

        additonalStyles =
            if props.isYearBreakdown then
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

            else
                []
    in
    tr
        [ class "history-breakdown-body__row month-breakdown"
        , classList [ ( seasonStr, True ) ]
        , css (Styles.breakdownBodyRow props.theme ++ additonalStyles)
        ]
        ([ td
            [ class "history-breakdown-body__month-title"
            , css [ paddingLeft (px 5), textAlign left ]
            ]
            [ Components.NewTabLink.view props.theme
                [ href ("http://localhost:9003/erza/" ++ props.contentType ++ "-view/" ++ item.id)
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
    div [ class "history-detail-breakdown", css [ margin (px 10), marginLeft auto ] ]
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
    [ li [ class "label", css [ displayFlex, justifyContent spaceBetween, margin (px 2) ] ]
        [ text name
        ]
    , li [ class "value", css [ displayFlex, justifyContent spaceBetween ] ]
        [ text statistic
        ]
    ]
