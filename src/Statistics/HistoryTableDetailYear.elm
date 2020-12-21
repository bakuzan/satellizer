module Statistics.HistoryTableDetailYear exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, div, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (class, classList, css, title)
import Models exposing (HistoryYear, HistoryYearData, Model, Settings, Theme)
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
    in
    div [ class "history-detail" ]
        [ div [ class "flex-row" ]
            [ table
                [ class "history-breakdown__table"
                , classList
                    [ ( String.toLower breakdown, True )
                    , ( "year", True )
                    ]
                , css [ width (pct 100), tableLayout fixed ]
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
                getSeasonColour season

            else
                []

        viewHeader obj =
            th
                [ class (String.toLower obj.name)
                , css
                    (colourised (String.toLower obj.name)
                        ++ [ padding2 (px 0) (px 4)
                           , width (calc (pct 25) minus (px (101 / 4)))
                           ]
                    )
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
        (th [ css [ width (px 101) ] ] []
            :: List.map viewHeader getHeaderList
        )


viewTableBody : Theme -> String -> HistoryYearData -> Html Msg
viewTableBody theme _ data =
    let
        cells =
            data

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
        , css (Styles.entryHoverHighlight theme)
        ]
        (th
            [ class "history-breakdown-body__year-statistic"
            , css
                [ padding2 (px 0) (px 4)
                , textAlign right
                ]
            ]
            [ text name ]
            :: List.map (\x -> fun x |> viewTableCell) data
        )


viewTableCell : String -> Html Msg
viewTableCell value =
    td
        [ css
            [ padding2 (px 0) (px 4)
            , textAlign center
            ]
        ]
        [ text value ]
