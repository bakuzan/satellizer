module Statistics.HistoryTableDetailYear exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, button, div, li, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id, style)
import Models exposing (HistoryYear, HistoryYearData, Model, Settings, Theme, emptyHistoryYear)
import Msgs exposing (Msg)
import Round
import Utils.Colours exposing (getSeasonColour)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Styles as Styles


view : Model -> HistoryYearData -> Html Msg
view model data =
    if model.settings.detailGroup == "" then
        text ""

    else
        viewHistoryYearDetail model data


viewHistoryYearDetail : Model -> HistoryYearData -> Html Msg
viewHistoryYearDetail model data =
    let
        settings =
            model.settings

        breakdown =
            settings.breakdownType

        detailGroup =
            settings.detailGroup

        getYearCount =
            List.length model.historyDetail
    in
    div [ class "history-detail" ]
        [ div [ class "flex-row" ]
            [ table
                [ class "history-breakdown__table"
                , classList
                    [ ( String.toLower breakdown, True )
                    , ( "year", True )
                    ]
                , css [ width (pct 100) ]
                ]
                [ viewTableHead settings
                , viewTableBody model.theme breakdown data
                ]
            ]
        ]


viewTableHead : Settings -> Html Msg
viewTableHead settings =
    let
        isSeason =
            settings.breakdownType /= "MONTH"

        isYear =
            not (String.contains "-" settings.detailGroup) && settings.detailGroup /= ""

        colourised season =
            if isSeason && isYear then
                [ backgroundColor (hex (getSeasonColour season))
                , color (hex "fff")
                ]

            else
                []

        viewHeader obj =
            th
                [ class (String.toLower obj.name)
                , css (colourised (String.toLower obj.name))
                ]
                [ text obj.name
                ]

        getHeaderList =
            if isSeason then
                Constants.seasons

            else
                Constants.months
    in
    thead [ class "history-breakdown-header" ]
        ([ th [] []
         ]
            ++ List.map viewHeader getHeaderList
        )


viewTableBody : Theme -> String -> HistoryYearData -> Html Msg
viewTableBody theme breakdown data =
    let
        isMonth =
            breakdown == "MONTH"

        fixValue =
            if isMonth then
                1

            else
                -2

        headers =
            if isMonth then
                Constants.months

            else
                Constants.seasons

        getKey x =
            String.right 2 ("0" ++ String.fromInt (x.number + fixValue))

        fixedData =
            let
                values =
                    List.map .key data
            in
            List.filter (\x -> not (List.member (getKey x) values)) headers
                |> List.map (\x -> { emptyHistoryYear | key = getKey x })
                |> List.append data

        cells =
            List.sortBy .key fixedData

        renderRow =
            viewTableRow theme
    in
    tbody [ class "history-breakdown-body" ]
        [ renderRow "Average" (floatToString .average) cells
        , renderRow "Highest" (intToString .highest) cells
        , renderRow "Lowest" (intToString .lowest) cells
        , renderRow "Mode" (intToString .mode) cells
        ]


floatToString : (HistoryYear -> Float) -> HistoryYear -> String
floatToString fun v =
    Round.round 2 (fun v)


intToString : (HistoryYear -> Int) -> HistoryYear -> String
intToString fun v =
    String.fromInt (fun v)


viewTableRow : Theme -> String -> (HistoryYear -> String) -> HistoryYearData -> Html Msg
viewTableRow theme name fun data =
    tr
        [ class "history-breakdown-body__row year-breakdown"
        , css (Styles.breakdownBodyRow theme)
        ]
        ([ th [ class "history-breakdown-body__year-statistic", css [ paddingLeft (px 5), textAlign left ] ]
            [ text name ]
         ]
            ++ List.map (\x -> fun x |> viewTableCell) data
        )


viewTableCell : String -> Html Msg
viewTableCell value =
    td [ css [ textAlign center ] ]
        [ text value ]
