module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData, fetchStatusData, fetchRatingData, fetchHistoryDetailData)
import RemoteData

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
          model.settings.breakdownType

        name =
          model.settings.activeTab

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
      let
        settings =
          model.settings
      in
      ( { model
         | historyDetail = RemoteData.Loading
         , settings =
           { settings
           | activeTab = name
           , detailGroup = ""
           }
         }, fetchStatusData )

    Msgs.UpdateBreakdownType breakdown ->
      let
        settings =
          model.settings
      in
      ( { model
        | historyDetail = RemoteData.Loading
        , settings =
          { settings
          | breakdownType = breakdown
          , detailGroup = ""
          }
        }, (fetchHistoryData breakdown))

    Msgs.DisplayHistoryDetail datePart ->
      let
        settings =
          model.settings
      in
      ( { model
        | settings =
          { settings
          | detailGroup = datePart
          }
      }, (fetchHistoryDetailData datePart model.settings.breakdownType) )


    Msgs.UpdateSortField field ->
      let
        settings =
          model.settings

        sorting =
          model.settings.sorting

      in
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | field = field
            }
          }
      }, Cmd.none)


    Msgs.UpdateSortDirection direction ->
      let
        settings =
          model.settings

        sorting =
          model.settings.sorting

      in
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | isDesc = direction
            }
          }
      }, Cmd.none)

    _ ->
      ( model, Cmd.none )
