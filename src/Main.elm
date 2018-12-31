port module Main exposing (..)

import Browser
import Commands exposing (fetchStatusData)
import Models exposing (Model, Flags, initialModel)
import Msgs exposing (Msg)
-- import Navigation exposing (Location)
-- import Routing
import Update exposing (update)
import View exposing (view)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        -- currentRoute =
        --     Routing.parseLocation location

        model =
          initialModel flags

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
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
