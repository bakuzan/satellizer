module Utils.Colours exposing (getSeasonColour, ratingColours, seasonColours)

import Css


ratingColours : List ( String, String )
ratingColours =
    [ ( "Onhold", "00f" )
    , ( "Completed", "f00" )
    , ( "Ongoing", "0f0" )
    , ( "Planned", "bbb" )
    , ( "ten", "fc0" )
    , ( "nine", "fc0" )
    , ( "eight", "ccc" )
    , ( "seven", "ccc" )
    , ( "six", "c63" )
    , ( "five", "c63" )
    , ( "four", "c63" )
    , ( "three", "000" )
    , ( "two", "000" )
    , ( "one", "000" )
    , ( "unrated", "008080" )
    ]


seasonColours : List ( String, String )
seasonColours =
    [ ( "winter", "50A3C6" )
    , ( "spring", "5B9E48" )
    , ( "summer", "FEF24E" )
    , ( "autumn", "E84F0B" )
    ]



-- Helper


getSeasonColour : String -> List Css.Style
getSeasonColour season =
    let
        backgroundTup =
            List.filter (\x -> Tuple.first x == season) seasonColours
                |> List.head
                |> Maybe.withDefault ( "", "000" )

        textHex =
            if Tuple.first backgroundTup == "summer" then
                "000"

            else
                "fff"
    in
    [ Css.backgroundColor (Css.hex (Tuple.second backgroundTup))
    , Css.color (Css.hex textHex)
    ]
