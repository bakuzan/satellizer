module Utils.Styles exposing (breakdownBodyRow)

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
