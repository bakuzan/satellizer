module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData, fetchStatusData, fetchRatingData, fetchHistoryDetailData, fetchHistoryYearData)
import RemoteData

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
    settings =
      model.settings

    sorting =
      settings.sorting

    getBreakdownType contentType =
      if contentType == "anime"
        then settings.breakdownType
        else "MONTHS"

    ensureValidSortField breakdown =
      if breakdown == "SEASON" || sorting.field == "TITLE" || sorting.field == "RATING"
        then sorting.field
        else "TITLE"

  in
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
          settings.activeTab

        callApi =
          if name == "History" then (fetchHistoryData settings) else
          if name == "Ratings" then (fetchRatingData settings) else Cmd.none

      in
      ( { model | status = response }, callApi )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )

    Msgs.OnFetchHistoryDetail response ->
      ( { model | historyDetail = response }, Cmd.none )

    Msgs.OnFetchHistoryYear response ->
      ( { model | historyYear = response }, Cmd.none )

    Msgs.OnFetchRating response ->
      ( { model | rating = response }, Cmd.none )

    Msgs.UpdateActiveTab name ->
      let
        updatedSettings =
          { settings
          | activeTab = name
          , detailGroup = ""
          }

      in
      ( { model
         | historyDetail = RemoteData.Loading
         , historyYear = RemoteData.Loading
         , settings = updatedSettings
         }, fetchStatusData updatedSettings)

    Msgs.UpdateBreakdownType breakdown ->
      let
        updatedSettings =
          { settings
          | breakdownType = breakdown
          , detailGroup = ""
          , sorting =
            { sorting
            | field = (ensureValidSortField breakdown)
            }
          }

      in
      ( { model
        | historyDetail = RemoteData.Loading
        , historyYear = RemoteData.Loading
        , settings = updatedSettings
        }, (fetchHistoryData updatedSettings))

    Msgs.DisplayHistoryDetail datePart ->
      let
        updatedSettings =
          { settings
          | detailGroup = datePart
          }

        fetchHistoryPartition =
          if (String.contains "-" datePart) == True
            then (fetchHistoryDetailData updatedSettings)
            else (fetchHistoryYearData updatedSettings)

      in
      ( { model
        | settings = updatedSettings
      }, (fetchHistoryPartition) )


    Msgs.UpdateSortField field ->
      let
        setSortDirection =
          if field == sorting.field
            then (not sorting.isDesc)
            else sorting.isDesc

      in
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | field = field
            , isDesc = setSortDirection
            }
          }
      }, Cmd.none)


    Msgs.UpdateSortDirection direction ->
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | isDesc = direction
            }
          }
      }, Cmd.none)

    Msgs.UpdateIsAdult isAdult ->
      let
        ensureValidDetailGroup breakdown =
          if isAdult == True
            then "MONTHS"
            else breakdown

        breakdownType =
          getBreakdownType settings.contentType
            |> ensureValidDetailGroup

        updatedSettings =
          { settings
          | isAdult = isAdult
          , breakdownType = breakdownType
          , detailGroup = ""
          , sorting =
            { sorting
            | field = (ensureValidSortField breakdownType)
            }
          }

      in
      ( { model
        | settings = updatedSettings
        } , fetchStatusData updatedSettings)

    Msgs.UpdateContentType contentType ->
      let
        breakdownType =
          getBreakdownType contentType

        updatedSettings =
          { settings
          | contentType = contentType
          , breakdownType = breakdownType
          , detailGroup = ""
          , sorting =
            { sorting
            | field = (ensureValidSortField breakdownType)
            }
          }

      in
      ( { model
        | settings = updatedSettings
        } , fetchStatusData updatedSettings)

    _ ->
      ( model, Cmd.none )
