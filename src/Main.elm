module Main exposing (..)

import Commands exposing (fetchStatusData)
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Update exposing (update)
import View exposing (view)
import ContentFilters


init : Flags Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location
    in
        ( initialModel flags currentRoute, fetchStatusData )


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ ContentFilters.isAdult Msgs.UpdateIsAdult
            , ContentFilters.contentType Msgs.UpdateContentType
            ]


main : Program Never Model Msg
main =
    Navigation.programWithFlags Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
