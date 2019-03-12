module Statistics.Ratings exposing (view)

import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import General.ProgressBar
import Html.Styled exposing (Html, button, div, text)
import Html.Styled.Attributes exposing (class, classList, css, id, style)
import Html.Styled.Events exposing (onClick)
import Models exposing (Count, CountData, Model, RatingFilters, SeriesData, Settings, emptyCount)
import Msgs exposing (Msg)
import Round
import Statistics.SeriesList
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Styles as Styles


view : Settings -> RatingFilters -> CountData -> SeriesData -> Html Msg
view settings filters ratingList seriesList =
    let
        total =
            Common.calculateTotalOfValues ratingList

        ratings =
            Common.splitList 1 ratingList

        viewRatingBar =
            viewSingleRating filters.ratings total
    in
    div [ id "ratings-tab", css Styles.listTabStyles ]
        [ div
            [ id "rating-container"
            , css
                (Styles.containerStyles
                    ++ [ children
                            [ typeSelector "div"
                                [ display inlineFlex
                                , flexDirection row
                                ]
                            ]
                       ]
                )
            ]
            ([ viewTotalAverageRating total ratingList
             ]
                ++ List.map viewRatingBar ratings
            )
        , Statistics.SeriesList.view settings filters seriesList
        ]


viewTotalAverageRating : Int -> CountData -> Html Msg
viewTotalAverageRating total list =
    let
        unratedCount =
            List.reverse list
                |> List.head
                |> Maybe.withDefault emptyCount
                |> .value

        divideIt num =
            Common.divide num (total - unratedCount)
                |> Round.round 2

        weight obj =
            obj.value
                * (String.toInt obj.key
                    |> Maybe.withDefault 0
                  )

        totalAverage =
            List.map weight list
                |> List.sum
                |> divideIt
    in
    div [ id "total-average-rating", css [ position absolute, top (px 0), right (px 0) ] ]
        [ text ("Average rating: " ++ totalAverage)
        ]


viewSingleRating : List Int -> Int -> CountData -> Html Msg
viewSingleRating selectedRatings total rating =
    let
        getRatingText obj =
            if obj.key == "0" then
                "-"

            else
                obj.key

        numberObj =
            List.head rating
                |> Maybe.withDefault { key = "-", value = 0 }

        numberString =
            numberObj
                |> getRatingText

        number =
            if numberString == "-" then
                0

            else
                numberString
                    |> String.toInt
                    |> Maybe.withDefault 0

        isSelected =
            List.member number selectedRatings

        updatedRating =
            List.map (\x -> { x | key = setRatingKey x }) rating
    in
    div []
        [ button
            [ class "button ripple rating-label"
            , classList [ ( "selected", isSelected ) ]
            , css
                [ displayFlex
                , alignItems center
                , justifyContent center
                , width (px 25)
                ]
            , onClick (Msgs.ToggleRatingFilter number)
            ]
            [ text numberString ]
        , General.ProgressBar.viewProgressBar total updatedRating
        ]


setRatingKey : Count -> String
setRatingKey obj =
    if obj.key == "0" then
        "unrated"

    else
        getNumberName obj.key


getNumberName : String -> String
getNumberName str =
    String.toInt str
        |> Maybe.withDefault 0
        |> (\x -> List.drop (x - 1) Constants.numberNames)
        |> List.head
        |> Maybe.withDefault "missing"
