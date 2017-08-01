module General.RadioButton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Utils.Common as Common


type alias RadioOption =
  { label: String
  , optionValue: String
  , action: Msg
  }


viewRadioGroup : String -> String -> List RadioOption -> Html Msg
viewRadioGroup groupName groupValue options =
  let
    radioOption =
      viewRadioOption groupName groupValue

  in
  div [class "radio-group", Common.setRole "radiogroup"]
      ([] ++ List.map radioOption options)


viewRadioOption : String -> String -> RadioOption -> Html Msg
viewRadioOption groupName groupValue option =
  let
    action =
      option.action

    optionValue =
      option.optionValue

  in
  label [class "radio", Common.setRole "radio"]
        [ input [type_ "radio", name groupName, value optionValue, checked (optionValue == groupValue), onClick action ] []
        , span [] [text option.label]
        ]
