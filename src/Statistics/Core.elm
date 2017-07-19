module Statistics.Core exposing (..)

import Html exposing (..)
-- import Html.Attributes exposing (class, href)
-- import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Models exposing (Count)
import RemoteData exposing (WebData)


view : WebData (List Count) -> Html Msg
view data =
    div []
        [ text "Core Statistics view"
        ]
