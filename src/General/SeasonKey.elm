module General.SeasonKey exposing(view)


import Html exposing(Html, div, text)
import Html.Attributes exposing (id, class, classList)


import Msgs exposing (Msg)


view : Bool -> Html Msg
view shouldDisplay =
  if shouldDisplay
    then viewKey
    else text ""


viewKey : Html Msg
viewKey =
  div [id "season-key"]
      [ viewKeyEntry "winter"
      , viewKeyEntry "spring"
      , viewKeyEntry "summer"
      , viewKeyEntry "fall"
      ]


viewKeyEntry : String -> Html Msg
viewKeyEntry season =
    div [class "key-entry", classList [(season, True)]]
        [ div [class "colour-block"]
              []
        , div [class "label"]
              [ text (String.left 1 season |> String.toUpper)
              ]
        ]
