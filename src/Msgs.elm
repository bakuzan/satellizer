module Msgs exposing (..)

-- import Http
import Models exposing (Counts)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | OnLocationChange Location
    | OnFetchStatus (WebData Counts)
