module View exposing (view)

import Components.ProgressBar
import Components.Tabs exposing (..)
import Css exposing (..)
import Css.Global exposing (global, typeSelector)
import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css, id)
import Models exposing (CountData, Model)
import Msgs exposing (Msg)
import Statistics.Airing
import Statistics.HistoryTable
import Statistics.Ratings
import Statistics.Repeated
import Statistics.Tags
import Utils.Common as Common


view : Model -> Html Msg
view model =
    let
        activeTab =
            model.settings.activeTab

        status =
            model.status

        history =
            model.history

        detail =
            model.historyDetail

        yearDetail =
            model.historyYear

        seriesList =
            model.seriesList

        disabledTabs =
            if model.settings.isAdult || model.settings.contentType /= "anime" then
                [ "Airing" ]

            else
                []
    in
    div
        [ css
            [ displayFlex
            , flexDirection column
            , flexGrow (int 1)
            ]
        ]
        [ hoverDataStyles
        , viewStatus status
        , viewTabContainer model.theme
            activeTab
            disabledTabs
            [ ( "Airing", [ Statistics.Airing.view model model.airingList ] )
            , ( "History", [ Statistics.HistoryTable.view model history detail yearDetail ] )
            , ( "Ratings", [ Statistics.Ratings.view model model.ratingsFilters model.rating seriesList ] )
            , ( "Repeated", [ Statistics.Repeated.view model model.repeatedFilters model.repeatedList ] )
            , ( "Tags", [ Statistics.Tags.view model model.tagsFilters model.tags model.tagsSeriesPage ] )
            ]
        ]


viewStatus : CountData -> Html Msg
viewStatus list =
    let
        total =
            Common.calculateTotalOfValues list
    in
    div [ id "status-container", css [ margin (px 15) ] ]
        [ Components.ProgressBar.viewProgressBar total list
        ]


hoverDataStyles : Html msg
hoverDataStyles =
    let
        fallbackColour =
            hex "000"

        tooltipColour =
            rgba 51 51 51 0.9

        coreBandA =
            [ position absolute
            , visibility hidden
            , opacity (int 0)
            , property "transition" "opacity 0.2s ease-in-out, visibility 0.2s ease-in-out, transform 0.2s cubic-bezier(0.71, 1.7, 0.77, 1.24)"
            , transform (translate3d (px 0) (px 0) (px 0))
            , pointerEvents none
            , property "-ms-filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=0)"
            , property "filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=0)"
            ]

        hoverBandA =
            [ visibility visible
            , property "-ms-filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"
            , property "filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"
            , opacity (int 1)
            , textAlign center
            ]

        onlyB =
            [ zIndex (int 1001)
            , border3 (px 6) solid transparent
            , backgroundColor transparent
            , property "content" "''"
            ]

        onlyA =
            [ zIndex (int 1000)
            , padding (px 8)
            , width (px 160)
            , backgroundColor fallbackColour
            , backgroundColor tooltipColour
            , color (hex "fff")
            , fontSize (px 14)
            , lineHeight (num 1.2)
            , property "content" "attr(hover-data)"
            ]

        defaultOrTopBandA =
            [ bottom (pct 100)
            , left (pct 50)
            ]

        defaultOrTopOnlyB =
            [ marginLeft (px -6)
            , marginBottom (px -12)
            , borderTopColor fallbackColour
            , borderTopColor tooltipColour
            ]

        defaultOrTopOnlyA =
            [ marginLeft (px -80)
            ]

        defaultOrTopHoverOrFocusBandA =
            [ transform (translateY (px -12))
            ]

        leftBandA =
            [ right (pct 100)
            , bottom (pct 50)
            , left auto
            ]

        leftOnlyB =
            [ marginLeft (px 0)
            , marginRight (px -12)
            , marginBottom (px 0)
            , borderTopColor transparent
            , borderLeftColor fallbackColour
            , borderLeftColor tooltipColour
            ]

        leftHoverOrFocusBandA =
            [ transform (translateX (px -12))
            ]

        bottomBandA =
            [ top (pct 100)
            , bottom auto
            , left (pct 50)
            ]

        bottomOnlyB =
            [ marginTop (px -12)
            , marginBottom (px 0)
            , borderTopColor transparent
            , borderBottomColor fallbackColour
            , borderBottomColor tooltipColour
            ]

        bottomHoverOrFocusBandA =
            [ transform (translateY (px 12))
            ]

        rightBandA =
            [ bottom (pct 50)
            , left (pct 100)
            ]

        rightOnlyB =
            [ marginBottom (px 0)
            , marginLeft (px -12)
            , borderTopColor transparent
            , borderRightColor fallbackColour
            , borderRightColor tooltipColour
            ]

        rightHoverOrFocusBandA =
            [ transform (translateX (px 12))
            ]

        leftOrRightOnlyB =
            [ top (px 3)
            ]

        leftOrRightOnlyA =
            [ marginLeft (px 0)
            , marginBottom (px -16)
            ]

        defaultAndTopStyles =
            [ before (defaultOrTopBandA ++ defaultOrTopOnlyB)
            , after (defaultOrTopBandA ++ defaultOrTopOnlyA)
            , hover
                [ before defaultOrTopHoverOrFocusBandA
                , after defaultOrTopHoverOrFocusBandA
                ]
            ]
    in
    global
        [ typeSelector "[hover-data]"
            [ position relative
            , cursor pointer
            ]
        , typeSelector ".tooltip"
            [ before (coreBandA ++ onlyB)
            , after (coreBandA ++ onlyA)
            , hover
                [ before hoverBandA
                , after hoverBandA
                ]
            ]
        , typeSelector ".tooltip" defaultAndTopStyles
        , typeSelector ".tooltip-top" defaultAndTopStyles
        , typeSelector ".tooltip-left"
            [ before (leftBandA ++ leftOnlyB)
            , after leftBandA
            , hover
                [ before leftHoverOrFocusBandA
                , after leftHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-bottom"
            [ before (bottomBandA ++ bottomOnlyB)
            , after bottomBandA
            , hover
                [ before bottomHoverOrFocusBandA
                , after bottomHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-right"
            [ before (rightBandA ++ rightOnlyB)
            , after rightBandA
            , hover
                [ before rightHoverOrFocusBandA
                , after rightHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-left"
            [ before leftOrRightOnlyB
            , after leftOrRightOnlyA
            ]
        , typeSelector ".tooltip-right"
            [ before leftOrRightOnlyB
            , after leftOrRightOnlyA
            ]
        ]
