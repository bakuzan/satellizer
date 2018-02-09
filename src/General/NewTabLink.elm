module General.NewTabLink exposing (view)

import Html exposing (..)
import Html.Attributes exposing (target, rel)
import Msgs exposing(Msg)



view : List (Attribute Msg) -> List (Html Msg) -> Html Msg
view attributes children =
    a ([target "_blank", rel "noopener noreferrer"] ++ attributes)
      ([] ++
        children)