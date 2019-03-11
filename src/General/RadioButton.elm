module General.RadioButton exposing (RadioOption, viewRadioGroup, viewRadioOption)

import Css exposing (..)
import Html.Styled exposing (Html, div, input, label, span, text)
import Html.Styled.Attributes exposing (checked, class, css, disabled, id, name, type_, value)
import Html.Styled.Events exposing (onClick)
import Msgs exposing (Msg)
import Utils.Common as Common


type alias RadioOption =
    { label : String
    , optionValue : String
    , action : Msg
    , disabled : Bool
    }


viewRadioGroup : String -> String -> List RadioOption -> Html Msg
viewRadioGroup groupName groupValue options =
    let
        radioOption =
            viewRadioOption groupName groupValue
    in
    div [ class "radio-group", Common.setRole "radiogroup", css [ width (pct 25) ] ]
        ([] ++ List.map radioOption options)


viewRadioOption : String -> String -> RadioOption -> Html Msg
viewRadioOption groupName groupValue option =
    let
        action =
            option.action

        optionValue =
            option.optionValue
    in
    label [ class "radio", Common.setRole "radio" ]
        [ input
            [ type_ "radio"
            , name groupName
            , value optionValue
            , checked (optionValue == groupValue)
            , disabled option.disabled
            , onClick action
            ]
            []
        , span [] [ text option.label ]
        ]
