module General.ClearableInput exposing (view)

import Html.Styled exposing (Html, button, div, input, label, span, text)
import Html.Styled.Attributes exposing (autocomplete, class, maxlength, name, placeholder, type_, value)
import Html.Styled.Events exposing (onClick, onInput)
import Msgs exposing (Msg)
import Utils.Common as Common


view : String -> String -> String -> Html Msg
view fieldName fieldLabel fieldValue =
    div [ class "has-float-label input-container clearable-input" ]
        [ input [ type_ "text", name fieldName, placeholder " ", maxlength 100, value fieldValue, autocomplete False, onInput (Msgs.UpdateTextInput fieldName) ] []
        , label [] [ text fieldLabel ]
        , viewClearButton fieldName fieldValue
        , span [ class "clearable-input-count" ]
            [ text (String.fromInt (String.length fieldValue) ++ "/100")
            ]
        ]


viewClearButton : String -> String -> Html Msg
viewClearButton fieldName str =
    if String.length str == 0 then
        text ""

    else
        button
            [ type_ "button"
            , class "button-icon small clear-input"
            , Common.setIcon "╳"
            , Common.setCustomAttr "aria-label" "Clear input"
            , onClick (Msgs.UpdateTextInput fieldName "")
            ]
            []
