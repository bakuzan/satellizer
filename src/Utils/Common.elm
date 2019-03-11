module Utils.Common exposing (calculateAverageOfRatings, calculateTotalOfValues, calculateTotalOfValuesTemp, divide, divideTotalByCount, getListFirst, getMonth, getYear, maxOfField, minOfField, replace, setIcon, setRole, splitList)

import Html.Styled exposing (Attribute)
import Html.Styled.Attributes exposing (attribute)
import Models exposing (Count, CountData, HistoryDetail, HistoryDetailData, HistoryYearData)
import Round


replace : String -> String -> String -> String
replace from to str =
    String.split from str
        |> String.join to


splitList : Int -> List a -> List (List a)
splitList i list =
    case List.take i list of
        [] ->
            []

        listHead ->
            listHead :: splitList i (List.drop i list)


divide : Int -> Int -> Float
divide part total =
    toFloat part / toFloat total


maxOfField : (a -> comparable) -> List a -> Maybe a
maxOfField field =
    let
        f x acc =
            case acc of
                Nothing ->
                    Just x

                Just y ->
                    if field x > field y then
                        Just x

                    else
                        Just y
    in
    List.foldr f Nothing


minOfField : (a -> comparable) -> List a -> Maybe a
minOfField field =
    let
        f x acc =
            case acc of
                Nothing ->
                    Just x

                Just y ->
                    if field x < field y then
                        Just x

                    else
                        Just y
    in
    List.foldr f Nothing


setRole : String -> Attribute msg
setRole value =
    attribute "role" value


setIcon : String -> Attribute msg
setIcon str =
    attribute "icon" str


calculateTotalOfValues : CountData -> Int
calculateTotalOfValues list =
    List.map .value list
        |> List.foldr (+) 0


calculateTotalOfValuesTemp : HistoryYearData -> Int
calculateTotalOfValuesTemp list =
    List.map .value list
        |> List.foldr (+) 0


calculateAverageOfRatings : HistoryDetailData -> Float
calculateAverageOfRatings list =
    let
        ratings =
            List.map (\x -> x.rating) list
    in
    List.foldr (+) 0 ratings
        |> divideTotalByCount (List.length (List.filter (\x -> x /= 0) ratings))
        |> Round.round 2
        |> String.toFloat
        |> Maybe.withDefault 0.0


divideTotalByCount : Int -> Int -> Float
divideTotalByCount len total =
    divide total len


getYear : String -> String
getYear str =
    String.slice 0 4 str


getMonth : String -> String
getMonth str =
    String.right 2 str


getListFirst : List Count -> String
getListFirst list =
    List.head list
        |> Maybe.withDefault { key = "", value = 0 }
        |> .key
