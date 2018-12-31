module Debouncers exposing (..)

import Debounce
import Time
import Task

import Msgs exposing (Msg)
import Models exposing (InputField)


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 1
    , transform = Msgs.DebounceMsg
    }


saveSearchString : InputField -> Cmd Msg
saveSearchString field =
    Task.perform (Msgs.SaveTextInput field.name) (Task.succeed field.value)
