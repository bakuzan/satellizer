module Main exposing (..)

import Commands exposing (fetchStatusData)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Update exposing (update)
import View exposing (view)


init : Flags Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel flags currentRoute, fetchStatusData )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.programWithFlags Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
