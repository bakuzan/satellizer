module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData, fetchStatusData, fetchRatingData, fetchHistoryDetailData)


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
        breakdown =
          model.breakdownType

        name =
          model.activeTab

        callApi =
          if name == "History" then (fetchHistoryData breakdown) else
          if name == "Ratings" then fetchRatingData else Cmd.none

      in
      ( { model | status = response }, callApi )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )

    Msgs.OnFetchHistoryDetail response ->
      ( { model | historyDetail = response }, Cmd.none )

    Msgs.OnFetchRating response ->
      ( { model | rating = response }, Cmd.none )

    Msgs.UpdateActiveTab name ->
      ( { model | activeTab = name }, fetchStatusData )

    Msgs.UpdateBreakdownType breakdown ->
      ( { model | breakdownType = breakdown }, (fetchHistoryData breakdown))

    Msgs.DisplayHistoryDetail datePart ->
      ( model, (fetchHistoryDetailData datePart model.breakdownType) )

    _ ->
      ( model, Cmd.none )
