module Debouncers exposing (debounceConfig, saveSearchString)

import Debounce
import Models exposing (InputField)
import Msgs exposing (Msg)
import Task
import Time


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later 1000
    , transform = Msgs.DebounceMsg
    }


saveSearchString : InputField -> Cmd Msg
saveSearchString field =
    Task.perform (Msgs.SaveTextInput field.name) (Task.succeed field.value)
