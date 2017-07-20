module Msgs exposing (..)

import Http
import Models exposing (Count)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | OnLocationChange Location
    | OnFetchData (WebData (List Count))
