module Components.TableSortHeader exposing (view)

import Components.Button as Button
import Css exposing (..)
import Html.Styled exposing (Html, strong, text, th)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Models exposing (Sort, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Styles as Styles


view : Sort -> Theme -> String -> List Css.Style -> Html Msg
view sorting theme title styles =
    let
        icon =
            if sorting.field /= String.toUpper title then
                ""

            else if sorting.isDesc == True then
                "▼"

            else
                "▲"
    in
    th
        []
        [ Button.view { isPrimary = False, theme = theme }
            [ onClick (Msgs.UpdateSortField (String.toUpper title))
            , css styles
            ]
            [ strong
                [ Common.setIcon icon
                , css
                    [ position relative
                    , lineHeight (int 1)
                    , paddingRight (rem 1.25)
                    , Styles.iconAfter
                    ]
                ]
                [ text title ]
            ]
        ]
