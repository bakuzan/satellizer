module Utils.Common exposing (..)


replace : String -> String -> String -> String
replace from to str =
    String.split from str
        |> String.join to


splitList : Int -> List a -> List (List a)
splitList i list =
  case List.take i list of
    [] -> []
    listHead -> listHead :: splitList i (List.drop i list)
