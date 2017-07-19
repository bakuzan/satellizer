module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
-- import RemoteData
import Debug


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Msgs.OnLocationChange location ->
      let
        newRoute =
          parseLocation location

        test =
          Debug.log "ROUTE TEST" newRoute

      in
      ( model, Cmd.none )

    _ ->
      ( model, Cmd.none )
