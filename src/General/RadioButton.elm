module General.RadioButton exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Msgs exposing (Msg)



viewRadioOption : String -> String -> String -> Html Msg
viewRadioOption label option val =
  label [class "radio", role "radio"]
        [ input [type_ "radio", name label, value option, checked (option == val) ] []
        , span [] [text label]
        ]
