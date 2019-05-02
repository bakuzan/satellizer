module Utils.Graphql exposing
    ( airingItemQuery
    , historyCountQuery
    , ratingCountQuery
    , ratingItemQuery
    , repeatedItemQuery
    , statusCountQuery
    )

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Models exposing (Count, CountData, EpisodeStatistic, HistoryDetail, HistoryDetailData, RepeatedSeries, RepeatedSeriesData, Series, SeriesData)
import Utils.Common exposing (toCapital)



-- count queries


statusCountQuery : Document Query CountData { vars | contentType : String, isAdult : Bool }
statusCountQuery =
    let
        queryRoot =
            extract
                (aliasAs "counts"
                    (field "statsStatusCounts"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        ]
                        countItems
                    )
                )
    in
    queryDocument queryRoot


ratingCountQuery : Document Query CountData { vars | contentType : String, isAdult : Bool }
ratingCountQuery =
    let
        queryRoot =
            extract
                (aliasAs "counts"
                    (field "statsRatingCounts"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        ]
                        countItems
                    )
                )
    in
    queryDocument queryRoot


historyCountQuery : Document Query CountData { vars | contentType : String, isAdult : Bool, breakdown : String }
historyCountQuery =
    let
        breakdownVar =
            Var.required "breakdown" .breakdown (Var.enum "StatBreakdown" (\x -> toCapital x))

        queryRoot =
            extract
                (aliasAs "counts"
                    (field "statsHistoryCounts"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        , ( "breakdown", Arg.variable breakdownVar )
                        ]
                        countItems
                    )
                )
    in
    queryDocument queryRoot



-- item queries


ratingItemQuery : String -> Document Query SeriesData { vars | isAdult : Bool, search : String, ratings : List Int }
ratingItemQuery contentType =
    let
        ratingsVar =
            Var.required "ratings" .ratings (Var.list Var.int)

        pagingVar =
            Var.required "paging"
                (\x -> { size = 1000, page = 0 })
                (Var.object
                    "Paging"
                    [ Var.field "size" .size Var.int
                    , Var.field "page" .page Var.int
                    ]
                )

        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "Paged")
                        [ ( "isAdult", Arg.variable isAdultVar )
                        , ( "search", Arg.variable searchVar )
                        , ( "ratings", Arg.variable ratingsVar )
                        , ( "paging", Arg.variable pagingVar )
                        ]
                        seriesItems
                    )
                )
    in
    queryDocument queryRoot


repeatedItemQuery : String -> Document Query RepeatedSeriesData { vars | isAdult : Bool, search : String }
repeatedItemQuery contentType =
    let
        items =
            list
                (object RepeatedSeries
                    |> with (field "id" [] int)
                    |> with (field "title" [] string)
                    |> with (field "rating" [] int)
                    |> with (field "timesCompleted" [] int)
                    |> with (aliasAs "isOwned" (field "owned" [] bool))
                    |> with (field "lastRepeatDate" [] string)
                )

        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "Repeated")
                        [ ( "isAdult", Arg.variable isAdultVar )
                        , ( "search", Arg.variable searchVar )
                        ]
                        items
                    )
                )
    in
    queryDocument queryRoot


airingItemQuery : Document Query HistoryDetailData {}
airingItemQuery =
    let
        items =
            list
                (object HistoryDetail
                    |> with (field "id" [] int)
                    |> with (field "title" [] string)
                    |> with (field "rating" [] int)
                    |> with (field "season" [] string)
                    |> with (field "average" [] float)
                    |> with (field "highest" [] int)
                    |> with (field "lowest" [] int)
                    |> with (field "mode" [] int)
                )

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


searchVar : Var.Variable { vars | search : String }
searchVar =
    Var.required "search" .search Var.string


countItems : ValueSpec NonNull (ListType NonNull ObjectType) (List Count) vars
countItems =
    list
        (object Count
            |> with (field "key" [] string)
            |> with (field "value" [] int)
        )


seriesItems : ValueSpec NonNull ObjectType (List Series) vars
seriesItems =
    extract
        (field "nodes"
            []
            (list
                (object Series
                    |> with (field "id" [] int)
                    |> with (field "title" [] string)
                    |> with (field "rating" [] int)
                )
            )
        )
