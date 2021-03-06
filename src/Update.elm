module Update exposing (update)

import Commands
import Debounce
import Debouncers
import List
import Models exposing (Model, Settings, emptyRatingSeriesPage, emptyRepeatHistoryResponse, emptyTagsSeriesPage, initialHistoryStartIndex)
import Msgs exposing (Msg)
import Utils.Common exposing (toCapital)


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

        tagsFilters =
            model.tagsFilters

        getBreakdownType contentType =
            if contentType == "anime" then
                settings.breakdownType

            else
                "MONTH"

        ensureValidSortField breakdown activeTab =
            if activeTab == "Airing" || breakdown == "SEASON" then
                "AVERAGE"

            else if activeTab == "Repeated" then
                "REPEATS"

            else if activeTab == "Tags" then
                "USAGE COUNT"

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

                        "Repeated" ->
                            "REPEATS"

                        "Tags" ->
                            "USAGE COUNT"

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
                        , historyStartIndex = initialHistoryStartIndex
                        , historyUnrestrictedView = False
                    }
            in
            ( { model
                | historyDetail = []
                , historyYear = []
                , repeatHistory = []
                , settings = updatedSettings
                , ratingsFilters =
                    { searchText = ""
                    , ratings = []
                    , seriesTypes = []
                    , page = 0
                    }
                , repeatedFilters =
                    { searchText = ""
                    }
                , tagsFilters =
                    { searchText = ""
                    , tagIds = []
                    , page = 0
                    }
              }
            , callApi updatedSettings.activeTab updatedSettings
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
                        , historyStartIndex = initialHistoryStartIndex
                        , historyUnrestrictedView = False
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
                        , historyStartIndex = initialHistoryStartIndex
                        , historyUnrestrictedView = False
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
                        , historyStartIndex = initialHistoryStartIndex
                        , historyUnrestrictedView = False
                    }
            in
            ( { model
                | settings = updatedSettings
                , repeatHistory = []
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

        Msgs.MoveTableRowDisplay direction ->
            let
                updatedSettings =
                    { settings
                        | historyStartIndex = settings.historyStartIndex + direction
                    }
            in
            ( { model
                | settings = updatedSettings
              }
            , Cmd.none
            )

        Msgs.ToggleHistoryUnrestrictedView ->
            let
                updatedSettings =
                    { settings
                        | historyStartIndex = initialHistoryStartIndex
                        , historyUnrestrictedView = not settings.historyUnrestrictedView
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

                isRepeatedInput =
                    fieldName == "repeatedSearch"

                isTagsInput =
                    fieldName == "tagSeriesSearch"

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
                            if isRepeatedInput then
                                txt

                            else
                                repeatedFilters.searchText
                    }

                updatedTagsFilters =
                    { tagsFilters
                        | searchText =
                            if isTagsInput then
                                txt

                            else
                                tagsFilters.searchText
                    }
            in
            ( { model
                | debounce = debounce
                , ratingsFilters = updatedRatingFilters
                , repeatedFilters = updatedReaptedFilters
                , tagsFilters = updatedTagsFilters
              }
            , cmd
            )

        Msgs.SaveTextInput fieldName fieldValue ->
            let
                newModel =
                    if fieldName == "search" then
                        { model
                            | ratingsFilters =
                                { searchText = fieldValue
                                , ratings = ratingsFilters.ratings
                                , seriesTypes = ratingsFilters.seriesTypes
                                , page = 0
                                }
                        }

                    else if fieldName == "tagSeriesSearch" then
                        { model
                            | tagsFilters =
                                { searchText = fieldValue
                                , tagIds = tagsFilters.tagIds
                                , page = 0
                                }
                        }

                    else
                        model

                cmd =
                    if fieldName == "search" then
                        Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult newModel.ratingsFilters

                    else if fieldName == "repeatedSearch" then
                        Commands.sendRepeatedSeriesQuery settings.contentType settings.isAdult fieldValue

                    else if fieldName == "tagSeriesSearch" && List.length newModel.tagsFilters.tagIds > 0 then
                        Commands.sendTagsSeriesQuery settings.contentType newModel.tagsFilters

                    else
                        Cmd.none
            in
            ( newModel, cmd )

        Msgs.ClearSelectedRatings ->
            let
                updatedFilters =
                    { ratingsFilters
                        | ratings = []
                        , page = 0
                    }
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
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
                        , page = 0
                    }
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
            )

        Msgs.ToggleSeriesTypeFilter seriesType ->
            let
                updatedTypes =
                    if List.member seriesType ratingsFilters.seriesTypes then
                        List.filter (\x -> x /= seriesType) ratingsFilters.seriesTypes

                    else
                        List.append ratingsFilters.seriesTypes [ seriesType ]

                updatedFilters =
                    { ratingsFilters
                        | seriesTypes = updatedTypes
                        , page = 0
                    }
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
            )

        Msgs.ResetSeriesTypeFilter ->
            let
                updatedFilters =
                    { ratingsFilters
                        | seriesTypes = model.seriesTypes
                        , page = 0
                    }
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
            )

        Msgs.ToggleTagsFilter tagId ->
            let
                updatedTagIds =
                    if List.member tagId tagsFilters.tagIds then
                        List.filter (\x -> x /= tagId) tagsFilters.tagIds

                    else
                        List.append tagsFilters.tagIds [ tagId ]

                updatedFilters =
                    { tagsFilters
                        | tagIds = updatedTagIds
                        , page = 0
                    }

                fetchSeriesForTags =
                    Commands.sendTagsSeriesQuery model.settings.contentType updatedFilters
            in
            ( { model
                | tagsFilters = updatedFilters
              }
            , fetchSeriesForTags
            )

        Msgs.ClearAllTagsFilter ->
            let
                updatedFilters =
                    { tagsFilters
                        | tagIds = []
                        , page = 0
                    }
            in
            ( { model
                | tagsFilters = updatedFilters
                , tagsSeriesPage = emptyTagsSeriesPage
              }
            , Cmd.none
            )

        Msgs.NextTagsSeriesPage ->
            let
                updatedFilters =
                    { tagsFilters
                        | page = tagsFilters.page + 1
                    }

                fetchSeriesForTags =
                    Commands.sendTagsSeriesQuery model.settings.contentType updatedFilters
            in
            ( { model
                | tagsFilters = updatedFilters
              }
            , fetchSeriesForTags
            )

        Msgs.NextRatingSeriesPage ->
            let
                updatedFilters =
                    { ratingsFilters
                        | page = ratingsFilters.page + 1
                    }
            in
            ( { model
                | ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
            )

        Msgs.ToggleRepeatHistory seriesId ->
            let
                statType =
                    toCapital settings.contentType

                matches =
                    List.filter (\x -> x.statType == statType && x.seriesId == seriesId) model.repeatHistory

                requiredNew =
                    List.length matches == 0

                updatedRepeatHistory =
                    if requiredNew then
                        model.repeatHistory

                    else
                        List.filter (\x -> not (x.statType == statType && x.seriesId == seriesId)) model.repeatHistory

                resolvedCmd =
                    if requiredNew then
                        Commands.sendRepeatHistoryQuery settings.contentType seriesId

                    else
                        Cmd.none
            in
            ( { model
                | repeatHistory = updatedRepeatHistory
              }
            , resolvedCmd
            )

        Msgs.ReceiveStatusCountsResponse counts ->
            let
                extractedCounts =
                    Result.withDefault [] counts

                queryForTabData =
                    callApi model.settings.activeTab model.settings
            in
            ( { model
                | status = extractedCounts
              }
            , queryForTabData
            )

        Msgs.ReceiveRatingCountsResponse ratings ->
            let
                extractedCounts =
                    Result.withDefault [] ratings
            in
            ( { model
                | rating = extractedCounts
              }
            , Commands.sendSeriesTypesRequest model.settings.contentType
            )

        Msgs.ReceiveSeriesTypesResponse seriesTypes ->
            let
                extractedTypes =
                    Result.withDefault [] seriesTypes

                updatedFilters =
                    { ratingsFilters
                        | seriesTypes = extractedTypes
                        , page = 0
                    }
            in
            ( { model
                | seriesTypes = extractedTypes
                , ratingsFilters = updatedFilters
              }
            , Commands.sendRatingsSeriesQuery settings.contentType settings.isAdult updatedFilters
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

        Msgs.ReceiveRatingsSeriesResponse page ->
            let
                newPage =
                    Result.withDefault emptyRatingSeriesPage page

                oldPage =
                    model.ratingSeriesPage

                nodesList =
                    if ratingsFilters.page == 0 then
                        newPage.nodes

                    else
                        List.concat [ oldPage.nodes, newPage.nodes ]

                updatedPage =
                    { oldPage
                        | hasMore = newPage.hasMore
                        , total = newPage.total
                        , nodes = nodesList
                    }
            in
            ( { model
                | ratingSeriesPage = updatedPage
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

        Msgs.ReceiveTagsResponse tags ->
            let
                extractedList =
                    Result.withDefault [] tags

                extractedIds =
                    List.map (\x -> x.id) extractedList

                isInTagList tagId =
                    List.member tagId extractedIds

                updatedIds =
                    List.filter (\id -> isInTagList id) tagsFilters.tagIds

                updatedTagsFilters =
                    { tagsFilters
                        | tagIds = updatedIds
                        , page = 0
                    }

                cmd =
                    if List.length updatedIds > 0 then
                        Commands.sendTagsSeriesQuery settings.contentType updatedTagsFilters

                    else
                        Cmd.none
            in
            ( { model
                | tags = extractedList
                , tagsFilters = updatedTagsFilters
                , tagsSeriesPage = emptyTagsSeriesPage
              }
            , cmd
            )

        Msgs.ReceiveTagsSeriesResponse page ->
            let
                newPage =
                    Result.withDefault emptyTagsSeriesPage page

                oldPage =
                    model.tagsSeriesPage

                nodesList =
                    if tagsFilters.page == 0 then
                        newPage.nodes

                    else
                        List.concat [ oldPage.nodes, newPage.nodes ]

                updatedPage =
                    { oldPage
                        | hasMore = newPage.hasMore
                        , total = newPage.total
                        , nodes = nodesList
                    }
            in
            ( { model
                | tagsSeriesPage = updatedPage
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

        Msgs.ReceiveRepeatHistoryResponse repeatHistoryResponse ->
            let
                extractedHistory =
                    Result.withDefault emptyRepeatHistoryResponse repeatHistoryResponse

                combinedHistory =
                    model.repeatHistory ++ List.singleton extractedHistory
            in
            ( { model
                | repeatHistory = combinedHistory
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


callApi : String -> Settings -> Cmd Msg
callApi tabName settings =
    if tabName == "Airing" then
        Commands.sendAiringSeriesQuery

    else if tabName == "History" then
        Commands.sendHistoryCountsRequest settings

    else if tabName == "Ratings" then
        Commands.sendRatingCountsRequest settings.contentType settings.isAdult

    else if tabName == "Repeated" then
        Commands.sendRepeatedSeriesQuery settings.contentType settings.isAdult ""

    else if tabName == "Tags" then
        Commands.sendTagsQuery settings.contentType settings.isAdult

    else
        Cmd.none
