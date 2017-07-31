module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Msgs.OnLocationChange location ->
      let
        newRoute =
          parseLocation location

      in
        ( { model | route = newRoute }, Cmd.none )

    Msgs.OnFetchStatus response ->
      ( { model | status = response }, fetchHistoryData )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )
      
    Msgs.OnFetchRating response ->
      ( { model | rating = response }, Cmd.none )

    _ ->
      ( model, Cmd.none )
