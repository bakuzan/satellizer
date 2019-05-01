port module Main exposing (contentType, init, isAdult, main, requireKey, subscriptions)

import Browser
import Commands exposing (sendStatusCountsRequest)
import Html.Styled exposing (toUnstyled)
import Models exposing (Flags, Model, Theme, initialModel)
import Msgs exposing (Msg)
import Update exposing (update)
import View exposing (view)


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel flags

        settings =
            model.settings
    in
    ( model, sendStatusCountsRequest settings.contentType settings.isAdult )


port contentType : (String -> msg) -> Sub msg


port isAdult : (Bool -> msg) -> Sub msg


port requireKey : (Bool -> msg) -> Sub msg


port theme : (Theme -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ isAdult Msgs.UpdateIsAdult
        , contentType Msgs.UpdateContentType
        , requireKey Msgs.UpdateRequireKey
        , theme Msgs.UpdateTheme
        ]


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
