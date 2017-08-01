module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData, fetchStatusData, fetchRatingData)


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
      let
        name =
          model.activeTab

        callApi =
          if name == "History" then fetchHistoryData else
          if name == "Ratings" then fetchRatingData else Cmd.none

      in
      ( { model | status = response }, callApi )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )

    Msgs.OnFetchRating response ->
      ( { model | rating = response }, Cmd.none )

    Msgs.UpdateActiveTab name ->
      ( { model | activeTab = name }, fetchStatusData )

    Msgs.UpdateBreakdownType breakdown ->
      ( { model | breakdownType = breakdown }, fetchHistoryData )

    _ ->
      ( model, Cmd.none )
