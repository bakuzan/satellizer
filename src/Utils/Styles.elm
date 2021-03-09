module Utils.Styles exposing
    ( appearance
    , containerStyles
    , containers
    , content
    , entryHoverHighlight
    , icon
    , iconAfter
    , leftAlign
    , list
    , listTabStyles
    , rightAlign
    , selectedStyle
    )

import Css exposing (..)
import Css.Global exposing (children, descendants, typeSelector)
import Models exposing (Theme)


entryHoverHighlight : Theme -> List Css.Style
entryHoverHighlight theme =
    [ borderSpacing (px 0)
    , hover
        [ backgroundColor (hex theme.primaryBackground)
        , color (hex theme.primaryColour)
        , descendants
            [ typeSelector ".slz-new-tab-link"
                [ color (hex theme.primaryColour)
                ]
            , typeSelector ".slz-times-completed"
                [ backgroundColor (hex theme.primaryBackground)
                , color (hex theme.primaryColour)
                ]
            ]
        ]
    ]


listTabStyles : List Css.Style
listTabStyles =
    [ displayFlex
    , width (pct 100)
    , padding2 (px 10) (px 5)
    ]


containerStyles : List Css.Style
containerStyles =
    [ displayFlex
    , flexDirection column
    , width (pct 50)
    ]



-- Generic styles


icon : Css.Style
icon =
    before
        [ property "content" "attr(icon)"
        ]


iconAfter : Css.Style
iconAfter =
    after
        [ property "content" "attr(icon)"
        , position absolute
        , margin2 (px 0) (px 2)
        ]


content : String -> Css.Style
content str =
    property "content" ("'" ++ str ++ "'")


appearance : String -> Css.Style
appearance str =
    Css.batch
        [ property "-webkit-appearance" str
        , property "appearance" str
        ]


containers : Theme -> List Css.Style
containers theme =
    floatLabel
        ++ [ position relative
           , displayFlex
           , alignItems center
           , padding (px 5)
           , minHeight (px 35)
           , boxSizing contentBox
           , focus
                [ important (borderBottomColor (hex theme.colour))
                ]
           ]


floatLabel : List Css.Style
floatLabel =
    [ displayFlex
    , position relative
    , children
        [ typeSelector "label"
            [ position absolute
            , left (px 5)
            , top (px 1)
            , cursor text_
            , fontSize (em 0.75)
            , opacity (int 1)
            , property "transition" "all 0.2s"
            ]
        , typeSelector "select" (controlFloatLabelStyle ++ [ appearance "none", marginBottom (px 0) ])
        , typeSelector "input" controlFloatLabelStyle
        ]
    ]


controlFloatLabelStyle : List Css.Style
controlFloatLabelStyle =
    [ fontSize inherit
    , paddingBottom (px 0)
    , paddingLeft (em 0.5)
    , paddingTop (em 1)
    , marginBottom (px 2)
    , property "border" "none"
    , borderRadius (px 0)
    , borderBottom3 (px 2) solid (rgba 0 0 0 0.1)
    , pseudoElement "-webkit-input-placeholder"
        [ opacity (int 1)
        , property "transition" "all 0.2s"
        ]
    , pseudoClass "placeholder-shown:not(:focus) + label"
        [ opacity (int 0)
        , fontSize (em 1.3)
        , property "opacity" "0.7"
        , pointerEvents none
        , top (em 0.6)
        , left (em 0.5)
        ]
    , focus
        [ outline none
        ]
    ]


list : Theme -> Bool -> Int -> List Css.Style
list theme isColumn columns =
    let
        isColumnStyle =
            if isColumn then
                [ flexDirection row
                , flexWrap wrap
                ]

            else
                []

        columnsStyle =
            let
                colVal =
                    pct (toFloat 100 / toFloat columns)
            in
            if columns == 0 then
                []

            else
                [ typeSelector "li" [ flexBasis colVal, width colVal, boxSizing borderBox ] ]
    in
    [ displayFlex
    , flexDirection row
    , padding (px 5)
    , margin2 (px 5) (px 0)
    , listStyleType none
    , children
        ([ typeSelector ".label"
            [ displayFlex
            , alignItems center
            , padding2 (px 2) (px 10)
            , fontWeight bold
            ]
         , typeSelector ".value"
            [ displayFlex
            , alignItems center
            , padding2 (px 2) (px 10)
            , before
                [ icon
                , fontWeight bold
                ]
            ]
         ]
            ++ columnsStyle
        )
    ]
        ++ isColumnStyle
        ++ (if isColumn then
                [ children
                    [ typeSelector ".label:nth-child(odd)"
                        [ hover
                            [ backgroundColor (hex theme.primaryBackground)
                            , color (hex theme.primaryColour)
                            ]
                        ]
                    , typeSelector ".label:nth-child(odd):hover + .value"
                        [ backgroundColor (hex theme.primaryBackground)
                        , color (hex theme.primaryColour)
                        ]
                    ]
                ]

            else
                []
           )


leftAlign : List Css.Style
leftAlign =
    [ textAlign left ]


rightAlign : List Css.Style
rightAlign =
    [ textAlign right ]


selectedStyle : Theme -> Bool -> List Css.Style
selectedStyle theme isSelected =
    if isSelected then
        [ important (backgroundColor (hex theme.primaryBackground))
        , important (color (hex theme.primaryColour))
        , hover [ backgroundColor (hex theme.primaryBackgroundHover) ]
        ]

    else
        []
