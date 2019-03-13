module Components.Tabs exposing (viewTabContainer)

import Components.Button as Button
import Css exposing (..)
import Html.Styled exposing (Html, div, li, text, ul)
import Html.Styled.Attributes exposing (class, classList, css, type_)
import Html.Styled.Events exposing (onClick)
import Models exposing (Theme)
import Msgs exposing (Msg)
import Utils.Common as Common


viewTabContainer : Theme -> String -> List String -> List ( String, List (Html Msg) ) -> Html Msg
viewTabContainer theme activeTab disabledTabs tabList =
    div
        [ class "tab-container"
        , css
            [ position relative
            , width (pct 100)
            , height (pct 100)
            , margin2 (px 5) (px 0)
            ]
        ]
        [ viewTabControls theme activeTab disabledTabs tabList
        , viewTabBodys theme activeTab tabList
        ]


viewTabControls : Theme -> String -> List String -> List ( String, List (Html Msg) ) -> Html Msg
viewTabControls theme activeTab disabledTabs tabList =
    let
        hoverActiveStyles =
            [ backgroundColor inherit
            , borderColor (hex theme.primaryBackground)
            , borderBottomColor (hex theme.baseBackground)
            ]

        generateTabButton tab =
            let
                isActive =
                    getTabName tab == activeTab

                isDisabled =
                    List.any (\x -> x == getTabName tab) disabledTabs
            in
            li
                [ classList [ ( "active", isActive ) ]
                , css
                    ([ displayFlex
                     , padding (px 2)
                     , margin2 (px 0) (px 1)
                     , borderWidth (px 1)
                     , borderStyle solid
                     , borderColor (hex "ccc")
                     , borderBottomColor transparent
                     , zIndex (int 10)
                     , backgroundColor (hex "ccc")
                     , color (hex "555")
                     , hover
                        (if isDisabled then
                            []

                         else
                            hoverActiveStyles
                        )
                     ]
                        ++ (if isActive then
                                hoverActiveStyles ++ [ marginBottom (px -1) ]

                            else
                                []
                           )
                    )
                , Common.setRole "tab"
                ]
                [ Button.view { isPrimary = False, theme = theme }
                    [ css
                        [ important (backgroundColor inherit)
                        , important (color inherit)
                        , disabled
                            [ backgroundColor (hex "ccc")
                            , color (hex "555")
                            , hover
                                [ backgroundColor (hex "ccc")
                                , color (hex "555")
                                ]
                            ]
                        ]
                    , onClick (Msgs.UpdateActiveTab (getTabName tab))
                    , Html.Styled.Attributes.disabled isDisabled
                    ]
                    [ text (getTabName tab) ]
                ]
    in
    ul
        [ class "tab-controls row"
        , css
            [ displayFlex
            , height (px 31)
            , padding2 (px 0) (px 5)
            , paddingLeft (px 0)
            , margin (px 0)
            , whiteSpace noWrap
            , listStyleType none
            ]
        , Common.setRole "tablist"
        ]
        ([] ++ List.map generateTabButton tabList)


viewTabBodys : Theme -> String -> List ( String, List (Html Msg) ) -> Html Msg
viewTabBodys theme activeTab tabList =
    let
        activeTabStyle =
            [ position relative
            , opacity (int 1)
            , zIndex (int 10)
            , pointerEvents auto
            ]

        generateTabBody tab =
            let
                isActive =
                    getTabName tab == activeTab
            in
            div
                [ class "tab-view"
                , classList [ ( "active", isActive ) ]
                , css
                    ([ position absolute
                     , top (px 0)
                     , left (px 0)
                     , displayFlex
                     , width (pct 100)
                     , height (pct 100)
                     , padding (px 5)
                     , margin (px 0)
                     , opacity (int 0)
                     , property "transition" "all 1s ease-in-out"
                     , pointerEvents none
                     ]
                        ++ (if isActive then
                                activeTabStyle

                            else
                                []
                           )
                    )
                , Common.setRole "tabpanel"
                ]
                ([] ++ Tuple.second tab)
    in
    div
        [ class "tabs"
        , css
            [ position relative
            , height (calc (pct 100) minus (px 31))
            , borderTop3 (px 1) solid (hex theme.primaryBackground)
            ]
        ]
        ([] ++ List.map generateTabBody tabList)


getTabName : ( String, List (Html Msg) ) -> String
getTabName tab =
    Tuple.first tab
