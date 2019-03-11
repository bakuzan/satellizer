module Statistics.HistoryTable exposing (view)

import Css exposing (..)
import General.RadioButton exposing (viewRadioGroup)
import General.SeasonKey as SeasonKey
import Html.Styled exposing (Html, button, div, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (attribute, class, classList, css, id, style)
import Html.Styled.Events exposing (onClick)
import Models exposing (Count, CountData, Header, HistoryDetailData, HistoryYearData, Settings, emptyCount)
import Msgs exposing (Msg)
import Statistics.HistoryTableDetail
import Statistics.HistoryTableDetailYear
import Utils.Colours exposing (getSeasonColour)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.TableFunctions exposing (getBreakdownName)


view : Settings -> CountData -> HistoryDetailData -> HistoryYearData -> Html Msg
view settings data detail yearDetail =
    let
        breakdownType =
            settings.breakdownType

        isYearBreakdown =
            not (String.contains "-" settings.detailGroup) && settings.detailGroup /= ""
    in
    div
        [ class "history-breakdown"
        , css
            [ Css.width (pct 100)
            , margin2 (px 5) (px 0)
            ]
        ]
        [ viewBreakdownToggle settings
        , viewTable data breakdownType isYearBreakdown
        , viewTableDetail settings detail yearDetail
        , SeasonKey.view (isYearBreakdown && breakdownType /= "MONTHS" && settings.requireKey)
        ]


viewBreakdownToggle : Settings -> Html Msg
viewBreakdownToggle settings =
    let
        blockInteraction =
            if settings.contentType == "manga" || settings.isAdult == True then
                True

            else
                False

        radioOptions =
            List.map (\x -> { x | disabled = blockInteraction }) Constants.breakdownOptions
    in
    viewRadioGroup "breakdown" settings.breakdownType radioOptions


viewTableDetail : Settings -> HistoryDetailData -> HistoryYearData -> Html Msg
viewTableDetail settings detail yearDetail =
    if String.contains "-" settings.detailGroup == True then
        Statistics.HistoryTableDetail.view settings detail

    else
        div [ id "history-breakdown-detail" ]
            [ Statistics.HistoryTableDetailYear.view settings yearDetail
            , Statistics.HistoryTableDetail.view settings detail
            ]


viewTable : CountData -> String -> Bool -> Html Msg
viewTable countData breakdown isYearBreakdown =
    let
        total =
            Common.maxOfField .value data
                |> Maybe.withDefault { key = "Empty", value = 0 }
                |> .value

        data =
            List.sortBy .key countData
                |> List.reverse

        isMonths =
            breakdown == "MONTHS"

        headers =
            if isMonths then
                Constants.months

            else
                Constants.seasons
    in
    table
        [ class "history-breakdown__table"
        , classList [ ( String.toLower breakdown, True ), ( "year", isYearBreakdown ) ]
        , css
            [ width (pct 100)
            ]
        ]
        [ viewHeader { isSeason = not isMonths, isYear = isYearBreakdown } headers
        , viewBody breakdown total data
        ]


viewHeader : { isSeason : Bool, isYear : Bool } -> List Header -> Html Msg
viewHeader settings headers =
    let
        colourised season =
            if settings.isSeason && settings.isYear then
                [ backgroundColor (hex (getSeasonColour season))
                , color (hex "fff")
                ]

            else
                []

        displayHeader obj =
            th
                [ class (String.toLower obj.name)
                , css (styles ++ colourised (String.toLower obj.name))
                ]
                [ text obj.name ]

        styles =
            if settings.isSeason then
                [ width (pct 25) ]

            else
                []
    in
    thead [ class "history-breakdown-header" ]
        ([ th [] []
         ]
            ++ List.map displayHeader headers
        )


viewBody : String -> Int -> CountData -> Html Msg
viewBody breakdown total data =
    let
        displayRow =
            viewRow breakdown total
    in
    tbody [ class "history-breakdown-body" ]
        ([] ++ List.map displayRow (split data))


viewRow : String -> Int -> List Count -> Html Msg
viewRow breakdown total data =
    let
        fixValue =
            if breakdown == "MONTHS" then
                1

            else
                -2

        getKey x =
            String.right 2 ("0" ++ String.fromInt (x.number + fixValue))

        fixedData =
            let
                values =
                    List.map (\x -> Common.getMonth x.key) data
            in
            List.filter (\x -> not (List.member (getKey x) values)) headers
                |> List.map (\x -> { emptyCount | key = rowYear ++ "-" ++ getKey x })
                |> List.append data

        headers =
            if breakdown == "MONTHS" then
                Constants.months

            else
                Constants.seasons

        cells =
            List.sortBy .key fixedData

        rowYear =
            Common.getYear (Common.getListFirst data)
    in
    tr [ class "history-breakdown-body__row" ]
        ([ th []
            [ button [ class "button", onClick (Msgs.DisplayHistoryDetail rowYear) ]
                [ text rowYear
                ]
            ]
         ]
            ++ List.map (viewCell breakdown total) cells
        )


viewCell : String -> Int -> Count -> Html Msg
viewCell breakdown total obj =
    let
        viewDate str =
            getBreakdownName breakdown str ++ " " ++ Common.getYear str

        isDisabled =
            obj.value == 0
    in
    td
        [ attribute "hover-data" (String.fromInt obj.value ++ " in " ++ viewDate obj.key)
        , class "history-breakdown-body__data-cell"
        , classList [ ( "disabled", isDisabled ) ]
        , css
            [ width (pct 8.3334) -- 100/12
            , border3 (px 1) solid (hex "000")
            , cursor pointer
            , textAlign center
            ]
        ]
        [ button
            [ onClick (Msgs.DisplayHistoryDetail obj.key)
            , Html.Styled.Attributes.disabled isDisabled
            , css
                [ position absolute
                , top (px 0)
                , left (px 0)
                , width (pct 100)
                , height (pct 100)
                , property "background" "none"
                , padding (px 0)
                , property "border" "none"
                , property "appearance" "none"
                , cursor pointer
                ]
            ]
            [ div
                [ class "history-breakdown-body__data-cell__background"
                , style "opacity" (String.fromFloat (Common.divide obj.value total))
                , css
                    [ width (pct 100)
                    , height (pct 100)
                    , backgroundColor (hex "000")
                    ]
                ]
                []
            ]
        ]


split : CountData -> List CountData
split list =
    case Common.getListFirst list of
        "" ->
            []

        listHead ->
            List.filter (matchHead listHead) list :: split (List.filter (notMatchHead listHead) list)


matchHead : String -> Count -> Bool
matchHead head obj =
    Common.getYear obj.key == Common.getYear head


notMatchHead : String -> Count -> Bool
notMatchHead head obj =
    not (matchHead head obj)
