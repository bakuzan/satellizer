module Utils.Graphql exposing (airingItemQuery, itemQuery, repeatedItemQuery)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Models exposing (EpisodeStatistic, HistoryDetail, HistoryDetailData, RepeatedSeries, RepeatedSeriesData, Series, SeriesData)


itemQuery : String -> Document Query SeriesData { vars | isAdult : Bool, search : String, ratings : List Float }
itemQuery contentType =
    let
        isAdultVar =
            Var.required "isAdult" .isAdult Var.bool

        searchVar =
            Var.required "search" .search Var.string

        ratingsVar =
            Var.required "ratings" .ratings (Var.list Var.float)

        filters =
            [ ( "isAdult", Arg.variable isAdultVar )
            , ( "search", Arg.variable searchVar )
            , ( "ratingIn", Arg.variable ratingsVar )
            ]

        item =
            object Series
                |> with (aliasAs "id" (field "_id" [] id))
                |> with (field "title" [] string)
                |> with (field "rating" [] int)

        items =
            list item

        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "Many")
                        [ ( "filter", Arg.object filters )
                        ]
                        items
                    )
                )
    in
    queryDocument queryRoot


repeatedItemQuery : String -> Document Query RepeatedSeriesData { vars | isAdult : Bool, search : String }
repeatedItemQuery contentType =
    let
        isAdultVar =
            Var.required "isAdult" .isAdult Var.bool

        searchVar =
            Var.required "search" .search Var.string

        filters =
            [ ( "isAdult", Arg.variable isAdultVar )
            , ( "search", Arg.variable searchVar )
            ]

        item =
            object RepeatedSeries
                |> with (aliasAs "id" (field "_id" [] id))
                |> with (field "title" [] string)
                |> with (field "timesCompleted" [] int)
                |> with (field "rating" [] int)
                |> with (aliasAs "isOwned" (field "owned" [] bool))
                |> with
                    (aliasAs "lastRepeatDate"
                        (field "historyList"
                            [ ( "limit", Arg.int 1 )
                            , ( "sort", Arg.enum "DATE_DESC" )
                            ]
                            (list (extract (field "dateStr" [] string)))
                        )
                    )

        items =
            list item

        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "ManyRepeated")
                        [ ( "filter", Arg.object filters )
                        ]
                        items
                    )
                )
    in
    queryDocument queryRoot


airingItemQuery : Document Query HistoryDetailData { vars | key : String }
airingItemQuery =
    let
        item =
            object HistoryDetail
                |> with (aliasAs "id" (field "_id" [] id))
                |> with (field "title" [] string)
                |> with (field "episodeStatistics" [] mapEpisodeStatistics)
                |> with (field "rating" [] int)
                |> with (field "season" [] string)

        mapEpisodeStatistics =
            object EpisodeStatistic
                |> with (aliasAs "id" (field "_id" [] id))
                |> with (field "average" [] float)
                |> with (field "highest" [] int)
                |> with (field "lowest" [] int)
                |> with (field "mode" [] int)

        items =
            list item

        queryRoot =
            extract
                (aliasAs "airingList"
                    (field "animeManyAiring"
                        []
                        items
                    )
                )
    in
    queryDocument queryRoot
