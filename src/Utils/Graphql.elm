module Utils.Graphql exposing
    ( airingItemQuery
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



-- item queries


ratingItemQuery : String -> Document Query SeriesData { vars | isAdult : Bool, search : String, ratings : List Int }
ratingItemQuery contentType =
    let
        searchVar =
            Var.required "search" .search Var.string

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
