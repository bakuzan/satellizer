module Components.RadioButton exposing (RadioOption, radioGroup, radioOption)

import Css exposing (..)
import Css.Global exposing (children, typeSelector)
import Html.Styled exposing (Html, div, input, label, span, text)
import Html.Styled.Attributes exposing (checked, class, css, disabled, name, type_, value)
import Html.Styled.Events exposing (onClick)
import Models exposing (Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Styles as Styles


type alias RadioOption =
    { label : String
    , optionValue : String
    , action : Msg
    , disabled : Bool
    }


radioGroup : Theme -> String -> String -> List RadioOption -> Html Msg
radioGroup theme groupName groupValue options =
    let
        option =
            radioOption theme groupName groupValue
    in
    div
        [ class "slz-radio-group"
        , Common.setRole "radiogroup"
        , css [ children [ typeSelector "label" [ margin2 (px 0) (px 2) ] ] ]
        ]
        ([] ++ List.map option options)


radioOption : Theme -> String -> String -> RadioOption -> Html Msg
radioOption theme groupName groupValue option =
    let
        action =
            option.action

        optionValue =
            option.optionValue

        isChecked =
            optionValue == groupValue

        ifChecked =
            if isChecked then
                [ Styles.content "◉"
                , fontSize (rem 1.5)
                , color (hex theme.colour)
                ]

            else
                []

        ifDisabled =
            if option.disabled then
                [ color (hex "bbb") ]

            else
                []
    in
    label
        [ class "slz-radio"
        , Common.setRole "radio"
        , css
            [ display inlineFlex
            , alignItems center
            , cursor pointer
            ]
        ]
        [ input
            [ type_ "radio"
            , css
                [ Styles.appearance "none"
                , paddingRight (px 2)
                , margin (px 0)
                , pointerEvents none
                , after
                    ([ Styles.content "◯"
                     , color (hex "aaa")
                     , fontSize (rem 1.2)
                     , verticalAlign middle
                     , color (hex theme.contrast)
                     ]
                        ++ ifChecked
                        ++ ifDisabled
                    )
                ]
            , name groupName
            , value optionValue
            , checked isChecked
            , disabled option.disabled
            , onClick action
            ]
            []
        , span
            [ css
                (if option.disabled then
                    [ color (hex "bbb") ]

                 else
                    []
                )
            ]
            [ text option.label ]
        ]
