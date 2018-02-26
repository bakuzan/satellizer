module General.ClearableInput exposing (view)


import Html exposing (Html, div, label, span, input, button, text)
import Html.Attributes exposing (class, type_, name, placeholder, maxlength, value, autocomplete)
import Html.Events exposing (onInput, onClick)

import Msgs exposing (Msg)


view : String -> String -> String -> Html Msg
view fieldName fieldLabel fieldValue =
    div [class "has-float-label input-container clearable-input"]
        [ input [ type_ "text", name fieldName, placeholder " ", maxlength 100, value fieldValue, autocomplete False, onInput (Msgs.UpdateTextInput fieldName)] []
        , label [] [ text fieldLabel ]
        , viewClearButton fieldName fieldValue
        , span [class "clearable-input-count"]
               [ text ((toString (String.length fieldValue)) ++ "/100")
               ]
        ]


viewClearButton : String -> String -> Html Msg
viewClearButton fieldName str =
  if (String.length str) == 0
    then text ""
    else button [type_ "button", class "button-icon small clear-input", onClick (Msgs.UpdateTextInput fieldName "")] []
