module Utils.TableFunctions exposing (getBreakdownName)

import Models exposing (Header)
import Utils.Constants as Constants


getBreakdownName : String -> String -> String
getBreakdownName breakdown str =
    if breakdown == "MONTH" then
        getMonthName str

    else
        getSeasonName str


getMonthName : String -> String
getMonthName str =
    getMonthHeader str
        |> .name


getMonthHeader : String -> Header
getMonthHeader str =
    let
        grabListItem num =
            List.drop (num - 1) Constants.months
                |> shiftHeader
    in
    prepareMonthAsInt str
        |> grabListItem


getSeasonName : String -> String
getSeasonName str =
    getSeasonHeader str
        |> .name


getSeasonHeader : String -> Header
getSeasonHeader str =
    let
        getDrop n =
            if n < 4 then
                0

            else if n < 7 then
                1

            else if n < 10 then
                2

            else
                3

        grabListItem num =
            List.drop (getDrop num) Constants.seasons
                |> shiftHeader
    in
    prepareMonthAsInt str
        |> grabListItem


prepareMonthAsInt : String -> Int
prepareMonthAsInt str =
    String.slice 5 (String.length str) str
        |> String.toInt
        |> Maybe.withDefault 0


shiftHeader : List Header -> Header
shiftHeader list =
    List.head list
        |> Maybe.withDefault { name = "Invalid", number = 0 }
