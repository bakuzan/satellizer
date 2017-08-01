module Utils.Common exposing (..)

import Html.Attributes exposing (attribute)

replace : String -> String -> String -> String
replace from to str =
    String.split from str
        |> String.join to


splitList : Int -> List a -> List (List a)
splitList i list =
  case List.take i list of
    [] -> []
    listHead -> listHead :: splitList i (List.drop i list)

divide : Int -> Int -> Float
divide part total =
  (toFloat part) / (toFloat total)

maxOfField : (a -> comparable) -> List a -> Maybe a
maxOfField field =
  let f x acc =
    case acc of
      Nothing -> Just x
      Just y -> if field x > field y then Just x else Just y
  in List.foldr f Nothing


setRole : String -> Attribute msg
setRole value = 
  attribute "role" value
