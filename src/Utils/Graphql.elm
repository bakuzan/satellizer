module Utils.Graphql exposing (..)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var

import Models exposing (SeriesData, Series)


itemQuery : String -> Document Query SeriesData { vars | isAdult: Bool, search: String, ratings: List Float }
itemQuery contentType =
    let
        isAdultVar =
          Var.required "isAdult" .isAdult Var.bool

        searchVar =
          Var.required "search" .search Var.string

        ratingsVar =
          Var.required "ratings" .ratings (Var.list Var.float)

        filters =
          [ ("isAdult", Arg.variable isAdultVar)
          , ("search", Arg.variable searchVar)
          , ("ratingIn", Arg.variable ratingsVar)
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
                        [ ("filter", Arg.object filters)
                        ]
                        items
                    )
                )
    in
        queryDocument queryRoot
