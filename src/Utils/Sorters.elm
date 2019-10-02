module Utils.Sorters exposing (repeatedSeriesOrdering, seriesOrdering, sortHistoryDetailList, sortTags)

import Models exposing (HistoryDetail, HistoryDetailData, RepeatedSeries, Series, Tag, TagData)
import Ordering exposing (Ordering)


repeatedSeriesOrdering : Ordering RepeatedSeries
repeatedSeriesOrdering =
    Ordering.byField .timesCompleted
        |> Ordering.reverse
        |> Ordering.breakTiesWith (Ordering.byField .title)


seriesOrdering : Ordering Series
seriesOrdering =
    Ordering.byField .rating
        |> Ordering.reverse
        |> Ordering.breakTiesWith (Ordering.byField .name)


directionHandler : Bool -> (Ordering a -> Ordering a)
directionHandler isDesc =
    if isDesc == True then
        Ordering.reverse

    else
        \x -> x


historyDetailOrderByTitle : Bool -> Ordering HistoryDetail
historyDetailOrderByTitle isDesc =
    Ordering.byField .title
        |> directionHandler isDesc


historyDetailOrderByRating : Bool -> Ordering HistoryDetail
historyDetailOrderByRating isDesc =
    Ordering.byField .rating
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByAverage : Bool -> Ordering HistoryDetail
historyDetailOrderByAverage isDesc =
    Ordering.byField .average
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByHighest : Bool -> Ordering HistoryDetail
historyDetailOrderByHighest isDesc =
    Ordering.byField .highest
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByLowest : Bool -> Ordering HistoryDetail
historyDetailOrderByLowest isDesc =
    Ordering.byField .lowest
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByMode : Bool -> Ordering HistoryDetail
historyDetailOrderByMode isDesc =
    Ordering.byField .mode
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


tagOrderByName : Bool -> Ordering Tag
tagOrderByName isDesc =
    Ordering.byField .name
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .timesUsed)


tagOrderByUsageCount : Bool -> Ordering Tag
tagOrderByUsageCount isDesc =
    Ordering.byField .timesUsed
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .name)


tagOrderByAverageRating : Bool -> Ordering Tag
tagOrderByAverageRating isDesc =
    Ordering.byField .averageRating
        |> directionHandler isDesc
        |> Ordering.breakTiesWith (Ordering.byField .name)



-- Handler


sortHistoryDetailList : String -> Bool -> HistoryDetailData -> HistoryDetailData
sortHistoryDetailList field isDesc list =
    case field of
        "TITLE" ->
            List.sortWith (historyDetailOrderByTitle isDesc) list

        "RATING" ->
            List.sortWith (historyDetailOrderByRating isDesc) list

        "AVERAGE" ->
            List.sortWith (historyDetailOrderByAverage isDesc) list

        "HIGHEST" ->
            List.sortWith (historyDetailOrderByHighest isDesc) list

        "LOWEST" ->
            List.sortWith (historyDetailOrderByLowest isDesc) list

        "MODE" ->
            List.sortWith (historyDetailOrderByMode isDesc) list

        _ ->
            list


sortTags : String -> Bool -> TagData -> TagData
sortTags field isDesc list =
    case field of
        "NAME" ->
            List.sortWith (tagOrderByName isDesc) list

        "USAGE COUNT" ->
            List.sortWith (tagOrderByUsageCount isDesc) list

        "AVERAGE RATING" ->
            List.sortWith (tagOrderByAverageRating isDesc) list

        _ ->
            list
