module Components.ProgressBar exposing (getPercentage, singleSegmentPercentage, viewProgressBar, viewProgressSegment)

import Css exposing (..)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (attribute, class, classList, css, style, title)
import Models exposing (Count, CountData)
import Msgs exposing (Msg)
import Round
import Utils.Colours exposing (ratingColours)
import Utils.Common exposing (divide)


viewProgressBar : Int -> CountData -> Html Msg
viewProgressBar total values =
    let
        segments =
            List.map (viewProgressSegment total) values

        progressItems =
            if List.length values > 1 then
                segments

            else
                segments
                    ++ [ div
                            [ css [ displayFlex, alignItems center, padding2 (px 0) (px 10) ]
                            ]
                            [ text (singleSegmentPercentage values total) ]
                       ]
    in
    div
        [ css
            [ displayFlex
            , flexDirection row
            , position relative
            , height (px 30)
            , width (pct 100)
            ]
        ]
        ([] ++ progressItems)


viewProgressSegment : Int -> Count -> Html Msg
viewProgressSegment total pair =
    let
        percentageString =
            String.fromFloat (getPercentage pair.value total) ++ "%"

        percentage =
            getPercentage pair.value total

        barColour =
            List.filter (\x -> Tuple.first x == pair.key) ratingColours
                |> List.head
                |> Maybe.withDefault ( "", "000" )
                |> Tuple.second

        dataMessage =
            String.fromInt pair.value ++ " series " ++ pair.key

        isComplete =
            pair.key == "completed"

        isInProgress =
            pair.key == "ongoing"
    in
    div
        [ class "tooltip"
        , classList
            [ ( pair.key, True )
            , ( "tooltip-left", not isComplete && not isInProgress )
            , ( "tooltip-bottom", isComplete )
            , ( "tooltip-right", isInProgress )
            ]
        , style "width" percentageString
        , attribute "hover-data" dataMessage
        , attribute "aria-label" dataMessage
        , css
            [ height (pct 100)
            , backgroundColor (hex barColour)
            ]
        ]
        []


getPercentage : Int -> Int -> Float
getPercentage value total =
    divide value total * 100


singleSegmentPercentage : CountData -> Int -> String
singleSegmentPercentage values total =
    let
        appendSign value =
            value ++ "%"

        returnPercentage num =
            getPercentage num total
                |> Round.round 2
                |> appendSign
    in
    List.head values
        |> Maybe.withDefault { key = "", value = 0 }
        |> .value
        |> returnPercentage
