module Debouncers exposing (debounceConfig, saveSearchString)

import Debounce
import Models exposing (InputField)
import Msgs exposing (Msg)
import Task


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 666 -- devils delay
    , transform = Msgs.DebounceMsg
    }


saveSearchString : InputField -> Cmd Msg
saveSearchString field =
    Task.perform (Msgs.SaveTextInput field.name) (Task.succeed field.value)
