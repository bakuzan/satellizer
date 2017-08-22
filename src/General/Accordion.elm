module General.Accordion exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, type_, id, name, for)
import Msgs exposing(Msg)



view : String -> List (Html Msg) -> Html Msg
view title children =
  let
    idLink = 
      title ++ "-accordion"

  in
  div [class "accordion"]
      [ input [type_ "checkbox", class "accordion-toggler", id idLink, name "accordion" ] []
      , label [for idLink] [text title]
      , div [class "accordion-content"]
           ([] ++ children)
      ]
