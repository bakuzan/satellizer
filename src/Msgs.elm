module Msgs exposing (..)

-- import Http
import Models exposing (CountData)
import Navigation exposing (Location)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | OnLocationChange Location
    | OnFetchStatus (WebData CountData)
