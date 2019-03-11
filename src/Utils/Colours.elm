module Utils.Colours exposing (getSeasonColour, ratingColours, seasonColours)


ratingColours : List ( String, String )
ratingColours =
    [ ( "onhold", "00f" )
    , ( "completed", "f00" )
    , ( "ongoing", "0f0" )
    , ( "planned", "bbb" )
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
    [ ( "winter", "4682b4" )
    , ( "spring", "228b22" )
    , ( "summer", "ff4500" )
    , ( "fall", "a52a2a" )
    ]



-- Helper


getSeasonColour : String -> String
getSeasonColour season =
    List.filter (\x -> Tuple.first x == season) seasonColours
        |> List.head
        |> Maybe.withDefault ( "", "000" )
        |> Tuple.second
