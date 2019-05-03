module Update exposing (update)

import Commands
import Debounce
import Debouncers
import Models exposing (Model, emptyHistoryYearDetail)
import Msgs exposing (Msg)


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
                "MONTH"

        ensureValidSortField breakdown activeTab =
            if activeTab == "Airing" || breakdown == "SEASON" then
                "AVERAGE"

            else
                "RATING"

        getHistoryPartitionCommand dateString params =
            if dateString == "" then
                Cmd.none

            else if String.contains "-" dateString == True then
                Commands.sendHistorySeriesQuery params

            else
                Commands.sendHistoryYearSeriesQuery params
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

        Msgs.UpdateActiveTab name ->
            let
                sortField =
                    case name of
                        "Airing" ->
                            "AVERAGE"

                        "History" ->
                            if settings.breakdownType == "SEASON" then
                                "AVERAGE"

                            else
                                "RATING"

                        _ ->
                            "RATING"

                updatedSettings =
                    { settings
                        | activeTab = name
                        , detailGroup = ""
                        , sorting =
                            { field = sortField
                            , isDesc = True
                            }
                    }
            in
            ( { model
                | historyDetail = []
                , historyYear = []
                , settings = updatedSettings
              }
            , Commands.sendStatusCountsRequest updatedSettings.contentType updatedSettings.isAdult
            )

        Msgs.UpdateBreakdownType breakdown ->
            let
                updatedSettings =
                    { settings
                        | breakdownType = breakdown
                        , detailGroup = ""
                        , sorting =
                            { sorting
                                | field = ensureValidSortField breakdown model.settings.activeTab
                            }
                    }
            in
            ( { model
                | historyDetail = []
                , historyYear = []
                , settings = updatedSettings
              }
            , Commands.sendHistoryCountsRequest updatedSettings
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
                        "MONTH"

                    else
                        breakdown

                activeTab =
                    if isAdult && settings.activeTab == "Airing" then
                        "History"

                    else
                        settings.activeTab

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
                                | field = ensureValidSortField breakdownType activeTab
                            }
                        , activeTab = activeTab
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Commands.sendStatusCountsRequest updatedSettings.contentType updatedSettings.isAdult
            )

        Msgs.UpdateContentType contentType ->
            let
                breakdownType =
                    getBreakdownType contentType

                activeTab =
                    if contentType /= "anime" && settings.activeTab == "Airing" then
                        "History"

                    else
                        settings.activeTab

                updatedSettings =
                    { settings
                        | contentType = contentType
                        , breakdownType = breakdownType
                        , detailGroup = ""
                        , sorting =
                            { sorting
                                | field = ensureValidSortField breakdownType activeTab
                            }
                        , activeTab = activeTab
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Commands.sendStatusCountsRequest updatedSettings.contentType updatedSettings.isAdult
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
                        Commands.sendRatingsSeriesQuery model.settings.contentType model.settings.isAdult fieldValue ratingsFilters.ratings

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
                        Commands.sendRatingsSeriesQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText []

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
                    Commands.sendRatingsSeriesQuery model.settings.contentType model.settings.isAdult ratingsFilters.searchText updatedRatings
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , fetchSeriesRatings
            )

        Msgs.ReceiveStatusCountsResponse counts ->
            let
                extractedCounts =
                    Result.withDefault [] counts

                name =
                    settings.activeTab

                callApi =
                    if name == "Airing" then
                        Commands.sendAiringSeriesQuery

                    else if name == "History" then
                        Commands.sendHistoryCountsRequest settings

                    else if name == "Ratings" then
                        Commands.sendRatingCountsRequest settings.contentType settings.isAdult

                    else if name == "Repeated" then
                        Commands.sendRepeatedSeriesQuery settings.contentType settings.isAdult ""

                    else
                        Cmd.none
            in
            ( { model
                | status = extractedCounts
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

        Msgs.ReceiveRatingCountsResponse ratings ->
            let
                extractedCounts =
                    Result.withDefault [] ratings
            in
            ( { model
                | rating = extractedCounts
              }
            , Cmd.none
            )

        Msgs.ReceiveHistoryCountsResponse historyCounts ->
            let
                datePart =
                    settings.detailGroup

                maybeDetailCommand =
                    getHistoryPartitionCommand datePart settings

                extractedCounts =
                    Result.withDefault [] historyCounts
            in
            ( { model | history = extractedCounts }, maybeDetailCommand )

        Msgs.ReceiveHistorySeriesResponse seriesList ->
            let
                extractedSeriesList =
                    Result.withDefault [] seriesList
            in
            ( { model | historyDetail = extractedSeriesList }, Cmd.none )

        Msgs.ReceiveHistoryYearSeriesResponse response ->
            let
                extractData =
                    Result.withDefault { counts = [], detail = [] } response

                counts =
                    extractData
                        |> .counts

                detail =
                    extractData
                        |> .detail
            in
            ( { model
                | historyYear = counts
                , historyDetail = detail
              }
            , Cmd.none
            )

        Msgs.ReceiveRatingsSeriesResponse seriesList ->
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
