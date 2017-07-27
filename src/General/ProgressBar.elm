module General.ProgressBar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, title)

{- TODO
   Make { key: String, value: Int } its own type
   Ensure styled
   Replace the progress bars with the app with references to this one
-}

viewProgressBar : List { key: String, value: Int } -> Html Msg
viewProgressBar values =
  div [ class "percentage-breakdown" ]
      (List.map viewProgressSegment values)  


viewProgressSegment : { key: String, value: Int } -> Html Msg
viewProgressSegment pair =
  div [ class "percentage-breakdown__bar", style [("width", (toString pair.value) ++ "%")], title pair.key ]
      []
