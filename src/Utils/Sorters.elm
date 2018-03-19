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


historyDetailOrderByTitle : Ordering HistoryDetail
historyDetailOrderByTitle =
  Ordering.byField .title


historyDetailOrderByRating : Ordering HistoryDetail
historyDetailOrderByRating =
  Ordering.byField .rating
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByAverage : Ordering HistoryDetail
historyDetailOrderByAverage =
  Ordering.byField (\x -> x.episodeStatistics.average)
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByHighest : Ordering HistoryDetail
historyDetailOrderByHighest =
  Ordering.byField (\x -> x.episodeStatistics.highest)
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByLowest : Ordering HistoryDetail
historyDetailOrderByLowest =
  Ordering.byField (\x -> x.episodeStatistics.lowest)
    |> Ordering.breakTiesWith (Ordering.byField .title)


historyDetailOrderByMode : Ordering HistoryDetail
historyDetailOrderByMode =
  Ordering.byField (\x -> x.episodeStatistics.mode)
    |> Ordering.breakTiesWith (Ordering.byField .title)
