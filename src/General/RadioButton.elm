module General.RadioButton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)


type alias RadioOption =
  { label: String
  , optionValue: String
  }


viewRadioGroup : String -> String -> List RadioOption -> Html Msg
viewRadioGroup groupName groupValue options =
  let
    radioOption =
      viewRadioOption groupName groupValue

  in
  div [class "radio-group"]
      ([] ++ List.map radioOption options)


viewRadioOption : String -> String -> RadioOption -> Html Msg
viewRadioOption groupName groupValue option =
  label [class "radio"]
        [ input [type_ "radio", name groupName, value option.optionValue, checked (option.optionValue == groupValue) ] []
        , span [] [text option.label]
        ]
