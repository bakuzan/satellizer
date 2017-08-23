module Update exposing (..)

import Routing exposing (parseLocation)
import Msgs exposing (Msg)
import Models exposing (Model)
import Commands exposing (fetchHistoryData, fetchStatusData, fetchRatingData, fetchHistoryDetailData, fetchHistoryYearData)
import RemoteData

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let
    settings = 
      model.settings
    
    sorting =
      settings.sorting
      
    getBreakdownType contentType = 
      if contentType == "anime"
        then settings.breakdownType
        else "MONTHS"
    
    ensureValidSortField breakdown =
      if breakdown == "SEASON" || sorting.field == "TITLE" || sorting.field == "RATING"
        then sorting.field
        else "TITLE"
        
  in
  case msg of
    Msgs.OnLocationChange location ->
      let
        newRoute =
          parseLocation location

      in
        ( { model | route = newRoute }, Cmd.none )

    Msgs.OnFetchStatus response ->
      let
        name =
          settings.activeTab

        callApi =
          if name == "History" then (fetchHistoryData settings) else
          if name == "Ratings" then (fetchRatingData settings) else Cmd.none

      in
      ( { model | status = response }, callApi )

    Msgs.OnFetchHistory response ->
      ( { model | history = response }, Cmd.none )

    Msgs.OnFetchHistoryDetail response ->
      ( { model | historyDetail = response }, Cmd.none )

    Msgs.OnFetchHistoryYear response ->
      ( { model | historyYear = response }, Cmd.none )

    Msgs.OnFetchRating response ->
      ( { model | rating = response }, Cmd.none )

    Msgs.UpdateActiveTab name ->
      ( { model
         | historyDetail = RemoteData.Loading
         , historyYear = RemoteData.Loading
         , settings =
           { settings
           | activeTab = name
           , detailGroup = ""
           }
         }, fetchStatusData settings)

    Msgs.UpdateBreakdownType breakdown ->
      ( { model
        | historyDetail = RemoteData.Loading
        , historyYear = RemoteData.Loading
        , settings =
          { settings
          | breakdownType = breakdown
          , detailGroup = ""
          , sorting =
            { sorting
            | field = (ensureValidSortField breakdown)
            }
          }
        }, (fetchHistoryData settings))

    Msgs.DisplayHistoryDetail datePart ->
      let
        fetchHistoryPartition =
          if (String.contains "-" datePart) == True
            then (fetchHistoryDetailData settings)
            else (fetchHistoryYearData settings)
            
      in
      ( { model
        | settings =
          { settings
          | detailGroup = datePart
          }
      }, (fetchHistoryPartition) )


    Msgs.UpdateSortField field ->
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | field = field
            }
          }
      }, Cmd.none)


    Msgs.UpdateSortDirection direction ->
      ( { model
        | settings =
          { settings
          | sorting =
            { sorting
            | isDesc = direction
            }
          }
      }, Cmd.none)
      
    Msgs.UpdateIsAdult isAdult ->
      let
       breakdownType = 
         getBreakdownType settings.contentType
            
      in
      ( { model
        | settings = 
          { model.settings 
          | isAdult = isAdult
          , breakdownType = getBreakdown
          , detailGroup = ""
          , sorting = 
            { sorting
            | field = (ensureValidSortField breakdownType)
            }
          }
        } , fetchStatusData settings)
      
    Msgs.UpdateContentType contentType ->
      let
        breakdownType = 
          getBreakdownType contentType
      
      in
      ( { model
        | settings = 
          { model.settings 
          | contentType = contentType
          , breakdownType = getBreakdown
          , detailGroup = ""
          , sorting = 
            { sorting
            | field = (ensureValidSortField breakdownType)
            }
          }
        } , fetchStatusData settings)
      
    _ ->
      ( model, Cmd.none )
