module Components.NewTabLink exposing (view)

import Css exposing (..)
import Html.Styled exposing (Attribute, Html, a)
import Html.Styled.Attributes exposing (class, css, rel, target)
import Models exposing (Theme)
import Msgs exposing (Msg)


view : Theme -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
view theme attributes children =
    a
        ([ target "_blank"
         , rel "noopener noreferrer"
         , class "slz-new-tab-link"
         , css
            [ color (hex theme.anchorColour)
            , hover [ color (hex theme.anchorColourHover) ]
            ]
         ]
            ++ attributes
        )
        ([]
            ++ children
        )
