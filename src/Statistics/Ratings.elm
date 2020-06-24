module Statistics.Ratings exposing (view)

import Components.Button as Button
import Components.ProgressBar
import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import Html.Styled exposing (Html, div, span, strong, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (class, classList, css, id)
import Html.Styled.Events exposing (onClick)
import Models exposing (Count, CountData, Model, RatingFilters, RatingSeriesPage, SeriesTypes, Theme, emptyCount)
import Msgs exposing (Msg)
import Round
import Statistics.SeriesList
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Styles as Styles


view : Model -> RatingFilters -> CountData -> SeriesTypes -> RatingSeriesPage -> Html Msg
view model filters ratingList seriesTypes seriesPage =
    let
        total =
            Common.calculateTotalOfValues ratingList

        ratings =
            Common.splitList 1 ratingList

        viewRatingBar =
            viewSingleRating model.theme filters.ratings total

        hasSelected =
            List.length filters.ratings > 0
    in
    div [ id "ratings-tab", css Styles.listTabStyles ]
        [ div [ css Styles.containerStyles ]
            [ div
                [ id "rating-container"
                , css
                    [ displayFlex
                    , flexDirection column
                    , marginBottom (px 15)
                    , children
                        [ typeSelector "div"
                            [ display inlineFlex
                            , flexDirection row
                            ]
                        ]
                    ]
                ]
                (div [ css [ margin2 (px 2) (px 0) ] ]
                    [ Button.view { isPrimary = False, theme = model.theme }
                        [ class "rating-label"
                        , classList [ ( "selected", hasSelected ) ]
                        , css
                            ([ position relative
                             , displayFlex
                             , alignItems center
                             , justifyContent center
                             , important (minWidth (rem 3))
                             , height (rem 2)
                             , margin2 (px 0) (px 5)
                             ]
                                ++ Styles.selectedStyle model.theme hasSelected
                            )
                        , Common.setCustomAttr "title" "Click to clear all selected ratings"
                        , Common.setCustomAttr "aria-label" "Click to clear all selected ratings"
                        , onClick Msgs.ClearSelectedRatings
                        ]
                        [ span
                            [ css
                                [ position absolute
                                , top (px 2)
                                , displayFlex
                                , alignItems center
                                , fontSize (rem 2)
                                , height (px 24)
                                ]
                            , Common.setCustomAttr "aria-hidden" "true"
                            ]
                            [ text (Common.selectionIcon hasSelected) ]
                        ]
                    , viewTotalAverageRating total ratingList
                    ]
                    :: List.map viewRatingBar ratings
                )
            , viewSeriesTypes model.theme seriesTypes filters.seriesTypes
            ]
        , div [ css Styles.containerStyles ]
            [ Statistics.SeriesList.view model filters seriesPage
            , if seriesPage.hasMore then
                Button.view { isPrimary = False, theme = model.theme }
                    [ css [ width (pct 100) ]
                    , onClick Msgs.NextRatingSeriesPage
                    ]
                    [ text "Load more..."
                    ]

              else
                text ""
            ]
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
    div [ id "total-average-rating", css [ displayFlex, alignItems center, whiteSpace pre ] ]
        [ span [ css [ fontWeight bold ] ] [ text "Average rating: " ]
        , text totalAverage
        ]


viewSingleRating : Theme -> List Int -> Int -> CountData -> Html Msg
viewSingleRating theme selectedRatings total rating =
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
        [ Button.view { isPrimary = False, theme = theme }
            [ class "rating-label"
            , classList [ ( "selected", isSelected ) ]
            , css
                ([ position relative
                 , displayFlex
                 , alignItems center
                 , justifyContent center
                 , important (minWidth (rem 3))
                 , height (rem 2)
                 , margin2 (px 0) (px 5)
                 ]
                    ++ Styles.selectedStyle theme isSelected
                )
            , onClick (Msgs.ToggleRatingFilter number)
            ]
            [ text numberString ]
        , Components.ProgressBar.viewProgressBar total updatedRating
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


viewSeriesTypes : Theme -> SeriesTypes -> SeriesTypes -> Html Msg
viewSeriesTypes theme seriesTypes selectedTypes =
    let
        hasSelected =
            List.length selectedTypes == List.length seriesTypes
    in
    div
        [ id "series-type-container"
        , css
            [ displayFlex
            , flexDirection column
            , marginBottom (px 15)
            ]
        ]
        [ table [ css [ width (pct 100) ] ]
            [ thead []
                [ tr []
                    [ th [ css [ padding2 (px 0) (px 4), width (px 50) ] ]
                        [ Button.view { isPrimary = False, theme = theme }
                            [ class "series-type-label"
                            , classList [ ( "selected", hasSelected ) ]
                            , css
                                ([ position relative
                                 , displayFlex
                                 , alignItems center
                                 , justifyContent center
                                 , important (minWidth (rem 2))
                                 , height (rem 2)
                                 , margin2 (px 0) (px 10)
                                 ]
                                    ++ Styles.selectedStyle theme hasSelected
                                )
                            , onClick Msgs.ResetSeriesTypeFilter
                            , Common.setCustomAttr "aria-label" "Click to reselect all"
                            , Common.setCustomAttr "title" "Click to reselect all"
                            ]
                            [ span
                                [ css
                                    [ position absolute
                                    , top (px 2)
                                    , displayFlex
                                    , alignItems center
                                    , fontSize (rem 2)
                                    , height (px 24)
                                    ]
                                , Common.setCustomAttr "aria-hidden" "true"
                                ]
                                [ text (Common.selectionIcon hasSelected) ]
                            ]
                        ]
                    , th
                        [ css [ textAlign left ] ]
                        [ strong
                            [ css
                                [ position relative
                                , lineHeight (int 1)
                                , paddingRight (rem 1.25)
                                ]
                            ]
                            [ text "Series Type" ]
                        ]
                    ]
                ]
            , tbody [] (List.map (viewSeriesTypeRow theme selectedTypes) seriesTypes)
            ]
        ]


viewSeriesTypeRow : Theme -> SeriesTypes -> String -> Html Msg
viewSeriesTypeRow theme selectedTypes data =
    let
        isSelected =
            List.member data selectedTypes

        ariaLabel =
            if isSelected then
                data ++ ": selected"

            else
                data ++ ": not selected"
    in
    tr [ css (Styles.entryHoverHighlight theme) ]
        [ td [ css [ padding2 (px 0) (px 4) ] ]
            [ Button.view { isPrimary = False, theme = theme }
                [ class "series-type-label"
                , classList [ ( "selected", isSelected ) ]
                , css
                    ([ position relative
                     , displayFlex
                     , alignItems center
                     , justifyContent center
                     , important (minWidth (rem 2))
                     , height (rem 2)
                     , margin2 (px 0) (px 10)
                     ]
                        ++ Styles.selectedStyle theme isSelected
                    )
                , onClick (Msgs.ToggleSeriesTypeFilter data)
                , Common.setCustomAttr "aria-label" ariaLabel
                ]
                [ span
                    [ css
                        [ position absolute
                        , top (px 2)
                        , displayFlex
                        , alignItems center
                        , fontSize (rem 2)
                        , height (px 24)
                        ]
                    , Common.setCustomAttr "aria-hidden" "true"
                    ]
                    [ text (Common.selectionIcon isSelected) ]
                ]
            ]
        , td [ css [ padding2 (px 0) (px 4) ] ]
            [ text data
            ]
        ]
