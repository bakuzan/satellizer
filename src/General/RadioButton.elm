module General.RadioButton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Models exposing (RadioOption)
import Msgs exposing (Msg)
import Utils.Common as Common


viewRadioGroup : String -> String -> Msg -> List RadioOption -> Html Msg
viewRadioGroup groupName groupValue message options =
  let
    radioOption =
      viewRadioOption groupName groupValue message

  in
  div [class "radio-group", Common.setRole "radiogroup"]
      ([] ++ List.map radioOption options)


viewRadioOption : String -> String -> Msg -> RadioOption -> Html Msg
viewRadioOption groupName groupValue message option =
  let
    optionValue = 
      option.optionValue
      
  in
  label [class "radio", Common.setRole "radio"]
        [ input [type_ "radio", name groupName, value optionValue, checked (optionValue == groupValue), onClick (message optionValue) ] []
        , span [] [text option.label]
        ]
