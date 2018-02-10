module Utils.Graphql exposing (..)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var

import Models exposing (SeriesData, Series)


itemQuery : String -> Document Query SeriesData { vars | search : String, ratings : List Int }
itemQuery contentType =
    let
        searchVar =
            Var.required "search" .search Var.string

        ratingsVar =
            Var.required "ratings" .ratings (Var.list Var.int)

        item =
            object Series
                |> with (field "id" [] string)
                |> with (field "title" [] string)
                |> with (field "rating" [] int)

        items =
            list item
        
        queryRoot =
            extract
                (aliasAs "seriesList"
                    (field (contentType ++ "Many")
                        [ ( "search", Arg.variable searchVar )
                        , ( "ratingIn", Arg.variable ratingsVar )
                        ]
                        items
                    )
                )
    in
        queryDocument queryRoot