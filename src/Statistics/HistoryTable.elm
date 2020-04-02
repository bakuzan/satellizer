module Statistics.HistoryTable exposing (view)

import Components.Button as Button
import Components.RadioButton exposing (radioGroup)
import Components.SeasonKey as SeasonKey
import Css exposing (..)
import Html.Styled exposing (Html, button, div, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (attribute, class, classList, css, id, style)
import Html.Styled.Events exposing (onClick)
import Models exposing (Count, CountData, Header, HistoryDetailData, HistoryYearData, Model, Settings, Theme, emptyCount)
import Msgs exposing (Msg)
import Statistics.HistoryTableDetail
import Statistics.HistoryTableDetailYear
import Utils.Colours exposing (getSeasonColour)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.TableFunctions exposing (getBreakdownName)


type alias TableProps =
    { theme : Theme
    , breakdown : String
    , isYearBreakdown : Bool
    }


view : Model -> CountData -> HistoryDetailData -> HistoryYearData -> Html Msg
view model data detail yearDetail =
    let
        settings =
            model.settings

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
        [ viewBreakdownToggle model.theme settings
        , viewTable
            { theme = model.theme
            , breakdown = breakdownType
            , isYearBreakdown = isYearBreakdown
            }
            data
        , viewTableDetail model detail yearDetail
        , SeasonKey.view model.theme (isYearBreakdown && breakdownType /= "MONTH" && settings.requireKey)
        ]


viewBreakdownToggle : Theme -> Settings -> Html Msg
viewBreakdownToggle theme settings =
    let
        blockInteraction =
            settings.contentType == "manga" || settings.isAdult == True

        radioOptions =
            List.map (\x -> { x | disabled = blockInteraction }) Constants.breakdownOptions
    in
    radioGroup theme "breakdown" settings.breakdownType radioOptions


viewTableDetail : Model -> HistoryDetailData -> HistoryYearData -> Html Msg
viewTableDetail model detail yearDetail =
    if String.contains "-" model.settings.detailGroup == True then
        Statistics.HistoryTableDetail.view model detail

    else
        div [ id "history-breakdown-detail" ]
            [ Statistics.HistoryTableDetailYear.view model yearDetail
            , Statistics.HistoryTableDetail.view model detail
            ]


viewTable : TableProps -> CountData -> Html Msg
viewTable props countData =
    let
        total =
            Common.maxOfField .value data
                |> Maybe.withDefault { key = "Empty", value = 0 }
                |> .value

        data =
            List.sortBy .key countData
                |> List.reverse

        isMonths =
            props.breakdown == "MONTH"

        headers =
            if isMonths then
                Constants.months

            else
                Constants.seasons
    in
    table
        [ class "history-breakdown__table"
        , classList [ ( String.toLower props.breakdown, True ), ( "year", props.isYearBreakdown ) ]
        , css
            [ width (pct 100)
            ]
        ]
        [ viewHeader { isSeason = not isMonths, isYear = props.isYearBreakdown } headers
        , viewBody props.theme props.breakdown total data
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
        (th [] []
            :: List.map displayHeader headers
        )


viewBody : Theme -> String -> Int -> CountData -> Html Msg
viewBody theme breakdown total data =
    let
        displayRow =
            viewRow theme breakdown total
    in
    tbody [ class "history-breakdown-body" ]
        ([] ++ List.map displayRow (split data))


viewRow : Theme -> String -> Int -> List Count -> Html Msg
viewRow theme breakdown total data =
    let
        fixValue =
            if breakdown == "MONTH" then
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
            if breakdown == "MONTH" then
                Constants.months

            else
                Constants.seasons

        cells =
            List.sortBy .key fixedData

        rowYear =
            Common.getYear (Common.getListFirst data)
    in
    tr [ class "history-breakdown-body__row" ]
        (th []
            [ Button.view { isPrimary = False, theme = theme }
                [ onClick (Msgs.DisplayHistoryDetail rowYear) ]
                [ text rowYear
                ]
            ]
            :: List.map (viewCell theme breakdown total) cells
        )


viewCell : Theme -> String -> Int -> Count -> Html Msg
viewCell theme breakdown total obj =
    let
        viewDate str =
            getBreakdownName breakdown str ++ " " ++ Common.getYear str

        isDisabled =
            obj.value == 0

        info =
            String.fromInt obj.value ++ " in " ++ viewDate obj.key
    in
    td
        [ attribute "hover-data" info
        , class "history-breakdown-body__data-cell tooltip"
        , classList [ ( "disabled", isDisabled ) ]
        , css
            [ width (pct 8.3334) -- 100/12
            , border3 (px 1) solid (hex "000")
            , cursor pointer
            , textAlign center
            ]
        ]
        [ button
            [ attribute "aria-label" info
            , onClick (Msgs.DisplayHistoryDetail obj.key)
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
                    , backgroundColor (hex theme.contrast)
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
