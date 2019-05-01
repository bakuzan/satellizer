module Utils.Graphql exposing (airingItemQuery, itemQuery, repeatedItemQuery, statusCountQuery)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Models exposing (Count, CountData, EpisodeStatistic, HistoryDetail, HistoryDetailData, RepeatedSeries, RepeatedSeriesData, Series, SeriesData)
import Utils.Common exposing (toCapital)



-- count queries


statusCountQuery : Document Query CountData { vars | contentType : String, isAdult : Bool }
statusCountQuery =
    let
        item =
            object Count
                |> with (field "key" [] string)
                |> with (field "value" [] int)

        items =
            list item

        queryRoot =
            extract
                (aliasAs "counts"
                    (field "statsStatusCounts"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        ]
                        items
                    )
                )
    in
    queryDocument queryRoot



-- item queries


itemQuery : String -> Document Query SeriesData { vars | isAdult : Bool, search : String, ratings : List Float }
itemQuery contentType =
    let
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
                |> with (field "id" [] id)
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


airingItemQuery : Document Query HistoryDetailData {}
airingItemQuery =
    let
        item =
            object HistoryDetail
                |> with (field "id" [] int)
                |> with (field "title" [] string)
                |> with (field "rating" [] int)
                |> with (field "season" [] string)
                |> with (field "average" [] float)
                |> with (field "highest" [] int)
                |> with (field "lowest" [] int)
                |> with (field "mode" [] int)

        items =
            list item

        queryRoot =
            extract
                (aliasAs "airingList"
                    (field "currentSeason"
                        []
                        items
                    )
                )
    in
    queryDocument queryRoot



-- shared variables


isAdultVar : Var.Variable { vars | isAdult : Bool }
isAdultVar =
    Var.required "isAdult" .isAdult Var.bool


typeVar : Var.Variable { vars | contentType : String }
typeVar =
    Var.required "type" .contentType (Var.enum "StatType" (\x -> toCapital x))
