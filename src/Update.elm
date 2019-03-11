module Update exposing (update)

import Commands
import Debounce
import Debouncers
import Models exposing (Model, emptyHistoryYearDetail)
import Msgs exposing (Msg)
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

        repeatedFilters =
            model.repeatedFilters

        getBreakdownType contentType =
            if contentType == "anime" then
                settings.breakdownType

            else
                "MONTHS"

        ensureValidSortField breakdown =
            if breakdown == "SEASON" || sorting.field == "RATING" || sorting.field == "RATING" then
                sorting.field

            else
                "RATING"

        getHistoryPartitionCommand dateString params =
            if dateString == "" then
                Cmd.none

            else if String.contains "-" dateString == True then
                Commands.fetchHistoryDetailData params

            else
                Commands.fetchHistoryYearData params
    in
    case msg of
        Msgs.DebounceMsg debmsg ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        Debouncers.debounceConfig
                        (Debounce.takeLast Debouncers.saveSearchString)
                        debmsg
                        model.debounce
            in
            ( { model | debounce = debounce }, cmd )

        Msgs.OnFetchStatus response ->
            let
                name =
                    settings.activeTab

                callApi =
                    if name == "Airing" then
                        Commands.sendAiringSeriesQuery

                    else if name == "History" then
                        Commands.fetchHistoryData settings

                    else if name == "Ratings" then
                        Commands.fetchRatingData settings

                    else if name == "Repeated" then
                        Commands.sendRepeatedSeriesQuery settings.contentType settings.isAdult ""

                    else
                        Cmd.none
            in
            ( { model
                | status = response
                , seriesList = []
                , ratingsFilters =
                    { searchText = ""
                    , ratings = []
                    }
                , repeatedFilters =
                    { searchText = ""
                    }
              }
            , callApi
            )

        Msgs.OnFetchHistory response ->
            let
                datePart =
                    settings.detailGroup

                maybeDetailCommand =
                    getHistoryPartitionCommand datePart settings
            in
            ( { model | history = response }, maybeDetailCommand )

        Msgs.OnFetchHistoryDetail response ->
            ( { model | historyDetail = response }, Cmd.none )

        Msgs.OnFetchHistoryYear response ->
            let
                extractData data =
                    case data of
                        RemoteData.NotAsked ->
                            emptyHistoryYearDetail

                        RemoteData.Loading ->
                            emptyHistoryYearDetail

                        RemoteData.Failure err ->
                            emptyHistoryYearDetail

                        RemoteData.Success val ->
                            val

                counts =
                    extractData response
                        |> .counts
                        |> RemoteData.succeed

                detail =
                    extractData response
                        |> .detail
                        |> RemoteData.succeed
            in
            ( { model
                | historyYear = counts
                , historyDetail = detail
              }
            , Cmd.none
            )

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
              }
            , Commands.fetchStatusData updatedSettings
            )

        Msgs.UpdateBreakdownType breakdown ->
            let
                updatedSettings =
                    { settings
                        | breakdownType = breakdown
                        , detailGroup = ""
                        , sorting =
                            { sorting
                                | field = ensureValidSortField breakdown
                            }
                    }
            in
            ( { model
                | historyDetail = RemoteData.Loading
                , historyYear = RemoteData.Loading
                , settings = updatedSettings
              }
            , Commands.fetchHistoryData updatedSettings
            )

        Msgs.DisplayHistoryDetail datePart ->
            let
                updatedSettings =
                    { settings
                        | detailGroup = datePart
                    }

                fetchHistoryPartition =
                    getHistoryPartitionCommand datePart updatedSettings
            in
            ( { model
                | settings = updatedSettings
              }
            , fetchHistoryPartition
            )

        Msgs.UpdateSortField field ->
            let
                setSortDirection =
                    if field == sorting.field then
                        not sorting.isDesc

                    else
                        sorting.isDesc
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
              }
            , Cmd.none
            )

        Msgs.UpdateSortDirection direction ->
            ( { model
                | settings =
                    { settings
                        | sorting =
                            { sorting
                                | isDesc = direction
                            }
                    }
              }
            , Cmd.none
            )

        -- Port values
        Msgs.UpdateIsAdult isAdult ->
            let
                ensureValidDetailGroup breakdown =
                    if isAdult == True then
                        "MONTHS"

                    else
                        breakdown

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
                                | field = ensureValidSortField breakdownType
                            }
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Commands.fetchStatusData updatedSettings
            )

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
                                | field = ensureValidSortField breakdownType
                            }
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Commands.fetchStatusData updatedSettings
            )

        Msgs.UpdateRequireKey required ->
            let
                updatedSettings =
                    { settings
                        | requireKey = required
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Cmd.none
            )

        Msgs.UpdateTheme theme ->
            ( { model | theme = theme }, Cmd.none )

        Msgs.UpdateTextInput fieldName txt ->
            let
                ( debounce, cmd ) =
                    Debounce.push Debouncers.debounceConfig { name = fieldName, value = txt } model.debounce

                isRatingInput =
                    fieldName == "search"

                updatedRatingFilters =
                    { ratingsFilters
                        | searchText =
                            if isRatingInput then
                                txt

                            else
                                ratingsFilters.searchText
                    }

                updatedReaptedFilters =
                    { repeatedFilters
                        | searchText =
                            if not isRatingInput then
                                txt

                            else
                                repeatedFilters.searchText
                    }
            in
            ( { model
                | debounce = debounce
                , ratingsFilters = updatedRatingFilters
                , repeatedFilters = updatedReaptedFilters
              }
            , cmd
            )

        Msgs.SaveTextInput fieldName fieldValue ->
            let
                cmd =
                    if fieldName == "search" then
                        Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult fieldValue ratingsFilters.ratings

                    else
                        Commands.sendRepeatedSeriesQuery model.settings.contentType model.settings.isAdult fieldValue
            in
            ( model, cmd )

        Msgs.ClearSelectedRatings ->
            let
                updatedFilters =
                    { ratingsFilters
                        | ratings = []
                    }

                shouldFetch =
                    String.length model.ratingsFilters.searchText > 0

                updatedSeriesList =
                    if shouldFetch then
                        model.seriesList

                    else
                        []

                maybeFetchSeriesRatings =
                    if shouldFetch then
                        Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText []

                    else
                        Cmd.none
            in
            ( { model
                | seriesList = updatedSeriesList
                , ratingsFilters = updatedFilters
              }
            , maybeFetchSeriesRatings
            )

        Msgs.ToggleRatingFilter rating ->
            let
                updatedRatings =
                    if List.member rating ratingsFilters.ratings then
                        List.filter (\x -> x /= rating) ratingsFilters.ratings

                    else
                        List.append ratingsFilters.ratings [ rating ]

                updatedFilters =
                    { ratingsFilters
                        | ratings = updatedRatings
                    }

                fetchSeriesRatings =
                    Commands.sendSeriesRatingsQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText updatedRatings
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , fetchSeriesRatings
            )

        Msgs.ReceiveSeriesRatingsResponse seriesList ->
            let
                extractedSeriesList =
                    Result.withDefault [] seriesList
            in
            ( { model
                | seriesList = extractedSeriesList
              }
            , Cmd.none
            )

        Msgs.ReceiveRepeatedSeriesResponse repeatedSeriesList ->
            let
                extractedSeriesList =
                    Result.withDefault [] repeatedSeriesList
            in
            ( { model
                | repeatedList = extractedSeriesList
              }
            , Cmd.none
            )

        Msgs.ReceiveAiringSeriesResponse airingList ->
            let
                extractedList =
                    Result.withDefault [] airingList
            in
            ( { model
                | airingList = extractedList
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )
