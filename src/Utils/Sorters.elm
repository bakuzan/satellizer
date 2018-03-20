module Utils.Sorters exposing (..)

import Ordering exposing (Ordering)

import Models exposing (RepeatedSeries, Series, HistoryDetail)


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
  if isDesc == True
    then Ordering.reverse
    else (\x -> x)


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
  Ordering.byField (\x -> x.episodeStatistics.average)
    |> historyDetailDirection isDesc
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByHighest : Bool -> Ordering HistoryDetail
historyDetailOrderByHighest isDesc =
  Ordering.byField (\x -> x.episodeStatistics.highest)
    |> historyDetailDirection isDesc
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByLowest : Bool -> Ordering HistoryDetail
historyDetailOrderByLowest isDesc =
  Ordering.byField (\x -> x.episodeStatistics.lowest)
    |> historyDetailDirection isDesc
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByMode : Bool -> Ordering HistoryDetail
historyDetailOrderByMode isDesc =
  Ordering.byField (\x -> x.episodeStatistics.mode)
    |> historyDetailDirection isDesc
    |> Ordering.breakTiesWith (Ordering.byField .title)
