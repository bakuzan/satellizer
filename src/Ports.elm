port module ContentFilters exposing (..)


port contentType : (String -> msg) -> Sub msg


port isAdult : (Bool -> msg) -> Sub msg
