module Utils.Styles exposing (breakdownBodyRow, containerStyles, listTabStyles)

import Css exposing (..)
import Css.Global exposing (children, typeSelector)


breakdownBodyRow : List Css.Style
breakdownBodyRow =
    [ borderSpacing (px 0)
    , hover
        [ backgroundColor (hex "1a1a1a")
        , color (hex "fff")
        , children
            [ typeSelector "a"
                [ color (hex "fff")
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
