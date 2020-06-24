module View exposing (view)

import Components.ProgressBar
import Components.Tabs as Tabs
import Css
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

        disabledTabs =
            if model.settings.isAdult || model.settings.contentType /= "anime" then
                [ "Airing" ]

            else
                []
    in
    div
        [ css
            [ Css.displayFlex
            , Css.flexDirection Css.column
            , Css.flexGrow (Css.int 1)
            ]
        ]
        [ hoverDataStyles
        , viewStatus status
        , Tabs.viewTabContainer model.theme
            activeTab
            disabledTabs
            [ ( "Airing", [ Statistics.Airing.view model model.airingList ] )
            , ( "History", [ Statistics.HistoryTable.view model history detail yearDetail ] )
            , ( "Ratings", [ Statistics.Ratings.view model model.ratingsFilters model.rating model.seriesTypes model.ratingSeriesPage ] )
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
    div [ id "status-container", css [ Css.margin (Css.px 15) ] ]
        [ Components.ProgressBar.viewProgressBar total list
        ]


hoverDataStyles : Html msg
hoverDataStyles =
    let
        fallbackColour =
            Css.hex "000"

        tooltipColour =
            Css.rgba 51 51 51 0.9

        coreBandA =
            [ Css.position Css.absolute
            , Css.visibility Css.hidden
            , Css.opacity (Css.int 0)
            , Css.property "transition" "opacity 0.2s ease-in-out, visibility 0.2s ease-in-out, transform 0.2s cubic-bezier(0.71, 1.7, 0.77, 1.24)"
            , Css.transform (Css.translate3d (Css.px 0) (Css.px 0) (Css.px 0))
            , Css.pointerEvents Css.none
            , Css.property "-ms-filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=0)"
            , Css.property "filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=0)"
            ]

        hoverBandA =
            [ Css.visibility Css.visible
            , Css.property "-ms-filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"
            , Css.property "filter" "progid:DXImageTransform.Microsoft.Alpha(Opacity=100)"
            , Css.opacity (Css.int 1)
            , Css.textAlign Css.center
            ]

        onlyB =
            [ Css.zIndex (Css.int 1001)
            , Css.border3 (Css.px 6) Css.solid Css.transparent
            , Css.backgroundColor Css.transparent
            , Css.property "content" "''"
            ]

        onlyA =
            [ Css.zIndex (Css.int 1000)
            , Css.padding (Css.px 8)
            , Css.width (Css.px 160)
            , Css.backgroundColor fallbackColour
            , Css.backgroundColor tooltipColour
            , Css.color (Css.hex "fff")
            , Css.fontSize (Css.px 14)
            , Css.lineHeight (Css.num 1.2)
            , Css.property "content" "attr(hover-data)"
            ]

        defaultOrTopBandA =
            [ Css.bottom (Css.pct 100)
            , Css.left (Css.pct 50)
            ]

        defaultOrTopOnlyB =
            [ Css.marginLeft (Css.px -6)
            , Css.marginBottom (Css.px -12)
            , Css.borderTopColor fallbackColour
            , Css.borderTopColor tooltipColour
            ]

        defaultOrTopOnlyA =
            [ Css.marginLeft (Css.px -80)
            ]

        defaultOrTopHoverOrFocusBandA =
            [ Css.transform (Css.translateY (Css.px -12))
            ]

        leftBandA =
            [ Css.right (Css.pct 100)
            , Css.bottom (Css.pct 50)
            , Css.left Css.auto
            ]

        leftOnlyB =
            [ Css.marginLeft (Css.px 0)
            , Css.marginRight (Css.px -12)
            , Css.marginBottom (Css.px 0)
            , Css.borderTopColor Css.transparent
            , Css.borderLeftColor fallbackColour
            , Css.borderLeftColor tooltipColour
            ]

        leftHoverOrFocusBandA =
            [ Css.transform (Css.translateX (Css.px -12))
            ]

        bottomBandA =
            [ Css.top (Css.pct 100)
            , Css.bottom Css.auto
            , Css.left (Css.pct 50)
            ]

        bottomOnlyB =
            [ Css.marginTop (Css.px -12)
            , Css.marginBottom (Css.px 0)
            , Css.borderTopColor Css.transparent
            , Css.borderBottomColor fallbackColour
            , Css.borderBottomColor tooltipColour
            ]

        bottomHoverOrFocusBandA =
            [ Css.transform (Css.translateY (Css.px 12))
            ]

        rightBandA =
            [ Css.bottom (Css.pct 50)
            , Css.left (Css.pct 100)
            ]

        rightOnlyB =
            [ Css.marginBottom (Css.px 0)
            , Css.marginLeft (Css.px -12)
            , Css.borderTopColor Css.transparent
            , Css.borderRightColor fallbackColour
            , Css.borderRightColor tooltipColour
            ]

        rightHoverOrFocusBandA =
            [ Css.transform (Css.translateX (Css.px 12))
            ]

        leftOrRightOnlyB =
            [ Css.top (Css.px 3)
            ]

        leftOrRightOnlyA =
            [ Css.marginLeft (Css.px 0)
            , Css.marginBottom (Css.px -16)
            ]

        defaultAndTopStyles =
            [ Css.before (defaultOrTopBandA ++ defaultOrTopOnlyB)
            , Css.after (defaultOrTopBandA ++ defaultOrTopOnlyA)
            , Css.hover
                [ Css.before defaultOrTopHoverOrFocusBandA
                , Css.after defaultOrTopHoverOrFocusBandA
                ]
            ]
    in
    global
        [ typeSelector "[hover-data]"
            [ Css.position Css.relative
            , Css.cursor Css.pointer
            ]
        , typeSelector ".tooltip"
            [ Css.before (coreBandA ++ onlyB)
            , Css.after (coreBandA ++ onlyA)
            , Css.hover
                [ Css.before hoverBandA
                , Css.after hoverBandA
                ]
            ]
        , typeSelector ".tooltip" defaultAndTopStyles
        , typeSelector ".tooltip-top" defaultAndTopStyles
        , typeSelector ".tooltip-left"
            [ Css.before (leftBandA ++ leftOnlyB)
            , Css.after leftBandA
            , Css.hover
                [ Css.before leftHoverOrFocusBandA
                , Css.after leftHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-bottom"
            [ Css.before (bottomBandA ++ bottomOnlyB)
            , Css.after bottomBandA
            , Css.hover
                [ Css.before bottomHoverOrFocusBandA
                , Css.after bottomHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-right"
            [ Css.before (rightBandA ++ rightOnlyB)
            , Css.after rightBandA
            , Css.hover
                [ Css.before rightHoverOrFocusBandA
                , Css.after rightHoverOrFocusBandA
                ]
            ]
        , typeSelector ".tooltip-left"
            [ Css.before leftOrRightOnlyB
            , Css.after leftOrRightOnlyA
            ]
        , typeSelector ".tooltip-right"
            [ Css.before leftOrRightOnlyB
            , Css.after leftOrRightOnlyA
            ]
        ]
