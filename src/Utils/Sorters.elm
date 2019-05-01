module Utils.Sorters exposing (repeatedSeriesOrdering, seriesOrdering, sortHistoryDetailList)

import Models exposing (HistoryDetail, HistoryDetailData, RepeatedSeries, Series)
import Ordering exposing (Ordering)


repeatedSeriesOrdering : Ordering RepeatedSeries
repeatedSeriesOrdering =
    Ordering.byField .timesCompleted
        |> Ordering.reverse
        |> Ordering.breakTiesWith (Ordering.byField .name)


seriesOrdering : Ordering Series
seriesOrdering =
    Ordering.byField .rating
        |> Ordering.reverse
        |> Ordering.breakTiesWith (Ordering.byField .name)


historyDetailDirection : Bool -> (Ordering a -> Ordering a)
historyDetailDirection isDesc =
    if isDesc == True then
        Ordering.reverse

    else
        \x -> x


historyDetailOrderByTitle : Bool -> Ordering HistoryDetail
historyDetailOrderByTitle isDesc =
    Ordering.byField .title
        |> historyDetailDirection isDesc


historyDetailOrderByRating : Bool -> Ordering HistoryDetail
historyDetailOrderByRating isDesc =
    Ordering.byField .rating
        |> historyDetailDirection isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByAverage : Bool -> Ordering HistoryDetail
historyDetailOrderByAverage isDesc =
    Ordering.byField .average
        |> historyDetailDirection isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByHighest : Bool -> Ordering HistoryDetail
historyDetailOrderByHighest isDesc =
    Ordering.byField .highest
        |> historyDetailDirection isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByLowest : Bool -> Ordering HistoryDetail
historyDetailOrderByLowest isDesc =
    Ordering.byField .lowest
        |> historyDetailDirection isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByMode : Bool -> Ordering HistoryDetail
historyDetailOrderByMode isDesc =
    Ordering.byField .mode
        |> historyDetailDirection isDesc
        |> Ordering.breakTiesWith (Ordering.byField .title)



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
