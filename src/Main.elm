port module Main exposing (..)

import Commands exposing (fetchStatusData)
import Models exposing (Model, Flags, initialModel)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Update exposing (update)
import View exposing (view)


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
          initialModel flags currentRoute

    in
        ( model, fetchStatusData model.settings)


port contentType : (String -> msg) -> Sub msg
port isAdult : (Bool -> msg) -> Sub msg
port requireKey: (Bool -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ isAdult Msgs.UpdateIsAdult
            , contentType Msgs.UpdateContentType
            , requireKey Msgs.UpdateRequireKey
            ]


main : Program Flags Model Msg
main =
    Navigation.programWithFlags Msgs.OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
