module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model, emptyHistoryYearDetail)
import Commands
import RemoteData

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
    settings =
      model.settings

    sorting =
      settings.sorting

    ratingsFilters =
      model.ratingsFilters


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
          if name == "History"
            then (Commands.fetchHistoryData settings)
            else
              if name == "Ratings"
                then (Commands.fetchRatingData settings)
                else Cmd.none

      in
      ( { model
        | status = response
        , seriesList = []
        , ratingsFilters =
          { searchText = ""
          , ratings = []
          }
        }, callApi )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )

    Msgs.OnFetchHistoryDetail response ->
      ( { model | historyDetail = response }, Cmd.none )

    Msgs.OnFetchHistoryYear response ->
      let
        extractData data =
          case data of
            RemoteData.NotAsked -> emptyHistoryYearDetail
            RemoteData.Loading -> emptyHistoryYearDetail
            RemoteData.Failure err -> emptyHistoryYearDetail
            RemoteData.Success data -> data

        counts =
          (extractData response)
            |> .counts
            |> RemoteData.succeed

        detail =
          (extractData response)
            |> .detail
            |> RemoteData.succeed

      in
      ( { model | historyYear = counts
                , historyDetail = detail
                }, Cmd.none )

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
         }, Commands.fetchStatusData updatedSettings)

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
        }, (Commands.fetchHistoryData updatedSettings))

    Msgs.DisplayHistoryDetail datePart ->
      let
        updatedSettings =
          { settings
          | detailGroup = datePart
          }

        fetchHistoryPartition =
          if (String.contains "-" datePart) == True
            then (Commands.fetchHistoryDetailData updatedSettings)
            else (Commands.fetchHistoryYearData updatedSettings)

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
        } , Commands.fetchStatusData updatedSettings)

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
        } , Commands.fetchStatusData updatedSettings)

    Msgs.UpdateRequireKey required ->
      let
        updatedSettings =
          { settings
          | requireKey = required
          }

      in
      ( { model
        | settings = updatedSettings
        }, Cmd.none)

    Msgs.UpdateRatingSearch txt ->
      let
          updatedFilters =
            { ratingsFilters
            | searchText = txt
            }

          fetchSeriesRatings =
            Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult txt ratingsFilters.ratings

      in
      ( { model
        | ratingsFilters = updatedFilters
        }, fetchSeriesRatings)

    Msgs.ClearSelectedRatings ->
      let
          updatedFilters =
            { ratingsFilters
            | ratings = []
            }

          shouldFetch =
            (String.length model.ratingsFilters.searchText) > 0

          updatedSeriesList =
            if shouldFetch
              then model.seriesList
              else []
            
          maybeFetchSeriesRatings =
            if shouldFetch
              then Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText []
              else Cmd.none

      in
      ( { model
        | seriesList = updatedSeriesList
        , ratingsFilters = updatedFilters
        }, maybeFetchSeriesRatings)

    Msgs.ToggleRatingFilter rating ->
      let
          updatedRatings =
            if List.member rating ratingsFilters.ratings
              then List.filter (\x -> x /= rating) ratingsFilters.ratings
              else List.append ratingsFilters.ratings [rating]

          updatedFilters =
            { ratingsFilters
            | ratings = updatedRatings
            }

          fetchSeriesRatings =
            Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText updatedRatings

      in
      ( { model
        | ratingsFilters = updatedFilters
        }, fetchSeriesRatings)

    Msgs.ReceiveSeriesRatingsResponse seriesList ->
      let
        extractedSeriesList =
            Result.withDefault [] seriesList

      in
        ( { model
          | seriesList = extractedSeriesList
          }, Cmd.none )

    _ ->
      ( model, Cmd.none )
