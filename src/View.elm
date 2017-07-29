module View exposing (..)

import Html exposing (Html, div, text)
-- import Html.Attributes exposing (id)
-- import Navigation exposing (Location)
import Models exposing (Model)
import Msgs exposing (Msg)
import Statistics.Core


view : Model -> Html Msg
view model =
    div []
        [ page model ]



page : Model -> Html Msg
page model =
    case model.route of
        Models.StatisticsRoute "manga" ->
            Statistics.Core.view model

        Models.StatisticsRoute "anime" ->
            Statistics.Core.view model

        Models.NotFoundRoute ->
            notFoundView model.route



notFoundView : Models.Route -> Html msg
notFoundView route =
    div []
        [ text ("Route" ++ (toString route) ++ " not found.")
        ]
