module Components.Button exposing (view, viewIcon, viewLink)

import Css
import Html.Styled exposing (button)
import Html.Styled.Attributes exposing (class, css, type_)
import Models exposing (Theme)
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
                ++ [ Css.minWidth (Css.px 100)
                   , Css.minHeight (Css.px 25)
                   , Css.textDecoration Css.none
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
            Css.color (Css.hex theme.anchorColour)

        linkTheme =
            [ baseColour
            , Css.active [ baseColour ]
            , Css.focus [ baseColour ]
            , Css.visited [ baseColour ]
            , Css.hover [ Css.color (Css.hex theme.anchorColourHover) ]
            ]
    in
    button
        ([ class "slz-button button-link"
         , type_ "button"
         , css (btnStyle ++ (Css.textDecoration Css.underline :: linkTheme))
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
                   , Css.flexGrow (Css.int 0)
                   , Css.flexShrink (Css.int 1)
                   , Css.flexBasis (Css.pct 0)
                   , Css.padding2 (Css.px 3) (Css.px 6)
                   , Css.margin2 (Css.px 2) (Css.px 5)
                   , Css.textDecoration Css.none
                   , Css.before
                        [ Css.fontSize (Css.em 1.25)
                        ]
                   , Css.pseudoClass "not:disabled" [ Css.cursor Css.pointer ]
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
    , Css.displayFlex
    , Css.justifyContent Css.center
    , Css.alignItems Css.center
    , Css.backgroundColor Css.inherit
    , Css.color Css.inherit
    , Css.padding (Css.px 5)
    , Css.property "border" "none"
    , Css.whiteSpace Css.noWrap
    , Css.cursor Css.pointer
    , Css.disabled
        [ Css.important (Css.backgroundColor (Css.hex "ccc"))
        , Css.color (Css.hex "666")
        , Css.cursor Css.default
        ]
    ]


themeing : ButtonTheme -> List Css.Style
themeing btnTheme =
    if btnTheme.isPrimary then
        [ Css.backgroundColor (Css.hex btnTheme.theme.primaryBackground)
        , Css.color (Css.hex btnTheme.theme.primaryColour)
        , Css.hover [ Css.backgroundColor (Css.hex btnTheme.theme.primaryBackgroundHover) ]
        ]

    else
        [ Css.backgroundColor (Css.hex btnTheme.theme.baseBackground)
        , Css.color (Css.hex btnTheme.theme.baseColour)
        , Css.hover [ Css.backgroundColor (Css.hex btnTheme.theme.baseBackgroundHover) ]
        ]
