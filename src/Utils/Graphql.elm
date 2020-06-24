module Utils.Graphql exposing
    ( airingItemQuery
    , historyCountQuery
    , historyItemQuery
    , historyYearItemQuery
    , ratingCountQuery
    , ratingItemQuery
    , repeatedItemQuery
    , seriesTypesQuery
    , statusCountQuery
    , tagsQuery
    , tagsSeriesQuery
    )

import GraphQL.Request.Builder
    exposing
        ( Document
        , ListType
        , NonNull
        , ObjectType
        , Query
        , ValueSpec
        , aliasAs
        , bool
        , extract
        , field
        , float
        , int
        , list
        , object
        , queryDocument
        , string
        , with
        )
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Models
    exposing
        ( Count
        , CountData
        , HistoryDetail
        , HistoryDetailData
        , HistoryYear
        , HistoryYearDetail
        , Paging
        , RatingSeriesPage
        , RepeatedSeries
        , RepeatedSeriesData
        , Series
        , SeriesTypes
        , Tag
        , TagData
        , TagsSeries
        , TagsSeriesPage
        )
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


historyItemQuery :
    String
    ->
        Document Query
            HistoryDetailData
            { vars
                | contentType : String
                , isAdult : Bool
                , breakdown : String
                , partition : String
            }
historyItemQuery _ =
    let
        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field "statsHistoryDetail"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        , ( "breakdown", Arg.variable breakdownVar )
                        , ( "partition", Arg.variable partitionVar )
                        ]
                        historyItems
                    )
                )
    in
    queryDocument queryRoot


historyYearItemQuery :
    String
    ->
        Document Query
            HistoryYearDetail
            { vars
                | contentType : String
                , isAdult : Bool
                , breakdown : String
                , partition : String
            }
historyYearItemQuery _ =
    let
        yearResponse =
            object HistoryYearDetail
                |> with
                    (aliasAs "counts"
                        (field "summary"
                            []
                            (list
                                (object HistoryYear
                                    |> with (field "key" [] string)
                                    |> with (field "average" [] float)
                                    |> with (field "highest" [] int)
                                    |> with (field "lowest" [] int)
                                    |> with (field "mode" [] int)
                                )
                            )
                        )
                    )
                |> with (aliasAs "detail" (field "series" [] historyItems))

        queryRoot =
            extract
                (aliasAs "historyYear"
                    (field "statsHistoryDetailYear"
                        [ ( "type", Arg.variable typeVar )
                        , ( "isAdult", Arg.variable isAdultVar )
                        , ( "breakdown", Arg.variable breakdownVar )
                        , ( "partition", Arg.variable partitionVar )
                        ]
                        yearResponse
                    )
                )
    in
    queryDocument queryRoot


ratingItemQuery :
    String
    ->
        Document Query
            RatingSeriesPage
            { vars
                | isAdult : Bool
                , search : String
                , ratings : List Int
                , seriesTypes : SeriesTypes
                , paging : Paging
            }
ratingItemQuery contentType =
    let
        ratingsVar =
            Var.required "ratings" .ratings (Var.list Var.int)

        sortingVar =
            Var.required "sorting"
                (\_ -> [ "rating", "DESC" ])
                (Var.list Var.string)

        page =
            object RatingSeriesPage
                |> with (field "hasMore" [] bool)
                |> with (field "total" [] int)
                |> with
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

        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "Paged")
                        [ ( "isAdult", Arg.variable isAdultVar )
                        , ( "search", Arg.variable searchVar )
                        , ( "ratings", Arg.variable ratingsVar )
                        , ( "seriesTypes", Arg.variable (seriesTypesVar contentType) )
                        , ( "paging", Arg.variable pagingVar )
                        , ( "sorting", Arg.variable sortingVar )
                        ]
                        page
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


tagsQuery : Document Query TagData { vars | contentType : String, isAdult : Bool }
tagsQuery =
    let
        items =
            list
                (object Tag
                    |> with (field "id" [] int)
                    |> with (field "name" [] string)
                    |> with (field "timesUsed" [] int)
                    |> with (field "averageRating" [] string)
                )

        queryRoot =
            extract
                (field "tagStats"
                    [ ( "type", Arg.variable typeVar )
                    , ( "isAdult", Arg.variable isAdultVar )
                    ]
                    items
                )
    in
    queryDocument queryRoot


tagsSeriesQuery : Document Query TagsSeriesPage { vars | contentType : String, search : String, tagIds : List Int, paging : Paging }
tagsSeriesQuery =
    let
        page =
            object TagsSeriesPage
                |> with (field "hasMore" [] bool)
                |> with (field "total" [] int)
                |> with
                    (field "nodes"
                        []
                        (list
                            (object TagsSeries
                                |> with (field "id" [] int)
                                |> with (field "title" [] string)
                                |> with (field "rating" [] int)
                            )
                        )
                    )

        tagIdsVar =
            Var.required "tagIds" .tagIds (Var.list Var.int)

        queryRoot =
            extract
                (field "seriesByTags"
                    [ ( "type", Arg.variable typeVar )
                    , ( "search", Arg.variable searchVar )
                    , ( "tagIds", Arg.variable tagIdsVar )
                    , ( "paging", Arg.variable pagingVar )
                    ]
                    page
                )
    in
    queryDocument queryRoot


airingItemQuery : Document Query HistoryDetailData {}
airingItemQuery =
    let
        queryRoot =
            extract
                (aliasAs "airingList"
                    (field "currentSeason"
                        []
                        historyItems
                    )
                )
    in
    queryDocument queryRoot


seriesTypesQuery : Document Query SeriesTypes { vars | contentType : String }
seriesTypesQuery =
    let
        queryRoot =
            extract
                (field "seriesTypes"
                    [ ( "type", Arg.variable typeVar )
                    ]
                    (list string)
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


breakdownVar : Var.Variable { vars | breakdown : String }
breakdownVar =
    Var.required "breakdown" .breakdown (Var.enum "StatBreakdown" (\x -> toCapital x))


partitionVar : Var.Variable { vars | partition : String }
partitionVar =
    Var.required "partition" .partition (Var.enum "HistoryPartition" (\x -> x))


seriesTypesVar : String -> Var.Variable { vars | seriesTypes : SeriesTypes }
seriesTypesVar contentType =
    let
        enumName =
            toCapital contentType ++ "Type"
    in
    Var.required "seriesTypes" .seriesTypes (Var.list (Var.enum enumName (\x -> x)))


pagingVar : Var.Variable { vars | paging : Paging }
pagingVar =
    Var.required "paging"
        .paging
        (Var.object
            "Paging"
            [ Var.field "size" .size Var.int
            , Var.field "page" .page Var.int
            ]
        )


countItems : ValueSpec NonNull (ListType NonNull ObjectType) (List Count) vars
countItems =
    list
        (object Count
            |> with (field "key" [] string)
            |> with (field "value" [] int)
        )


historyItems : ValueSpec NonNull (ListType NonNull ObjectType) HistoryDetailData vars
historyItems =
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
