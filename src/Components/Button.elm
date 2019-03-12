module Components.Button exposing (view, viewIcon, viewLink)

import Css exposing (..)
import Html.Styled exposing (Html, button)
import Html.Styled.Attributes exposing (class, css, type_)
import Html.Styled.Events exposing (onClick)
import Models exposing (Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Styles as Styles


type alias ButtonTheme =
    { theme : Theme
    , isPrimary : Bool
    }


view : ButtonTheme -> List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
view btnTheme attrs children =
    button
        ([ class "slz-button ripple"
         , type_ "button"
         , css
            (btnStyle
                ++ [ minWidth (px 100)
                   , minHeight (px 25)
                   , textDecoration none
                   ]
                ++ themeing btnTheme
            )
         ]
            ++ attrs
        )
        children


viewLink : Theme -> List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
viewLink theme attrs children =
    let
        baseColour =
            color (hex theme.anchorColour)

        linkTheme =
            [ baseColour
            , active [ baseColour ]
            , focus [ baseColour ]
            , visited [ baseColour ]
            , hover [ color (hex theme.anchorColourHover) ]
            ]
    in
    button
        ([ class "slz-button button-link"
         , type_ "button"
         , css (btnStyle ++ [ textDecoration underline ] ++ linkTheme)
         ]
            ++ attrs
        )
        children


viewIcon : String -> ButtonTheme -> List (Html.Styled.Attribute msg) -> List (Html.Styled.Html msg) -> Html.Styled.Html msg
viewIcon icon btnTheme attrs children =
    button
        ([ class "slz-button"
         , type_ "button"
         , Common.setCustomAttr "icon" icon
         , css
            (btnStyle
                ++ [ Styles.icon
                   , flexGrow (int 0)
                   , flexShrink (int 1)
                   , flexBasis (pct 0)
                   , padding2 (px 3) (px 6)
                   , margin2 (px 2) (px 5)
                   , textDecoration none
                   , before
                        [ fontSize (em 1.25)
                        ]
                   , pseudoClass "not:disabled" [ cursor pointer ]
                   ]
                ++ themeing btnTheme
            )
         ]
            ++ attrs
        )
        children


btnStyle : List Css.Style
btnStyle =
    [ Styles.appearance "none"
    , displayFlex
    , justifyContent center
    , alignItems center
    , backgroundColor inherit
    , color inherit
    , padding (px 5)
    , property "border" "none"
    , whiteSpace noWrap
    , cursor pointer
    , disabled
        [ important (backgroundColor (hex "ccc"))
        , color (hex "666")
        , cursor default
        ]
    ]


themeing : ButtonTheme -> List Css.Style
themeing btnTheme =
    if btnTheme.isPrimary then
        [ backgroundColor (hex btnTheme.theme.primaryBackground)
        , color (hex btnTheme.theme.primaryColour)
        , hover [ backgroundColor (hex btnTheme.theme.primaryBackgroundHover) ]
        ]

    else
        [ backgroundColor (hex btnTheme.theme.baseBackground)
        , color (hex btnTheme.theme.baseColour)
        , hover [ backgroundColor (hex btnTheme.theme.baseBackgroundHover) ]
        ]
