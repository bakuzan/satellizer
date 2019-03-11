module Models exposing (Count, CountData, EpisodeStatistic, Flags, Header, HistoryDetail, HistoryDetailData, HistoryYear, HistoryYearData, HistoryYearDetail, InputField, Model, ObjectsWithValue(..), RatingFilters, RepeatedFilters, RepeatedSeries, RepeatedSeriesData, Series, SeriesData, Settings, Sort, Theme, emptyCount, emptyEpisodeStatistic, emptyHistoryDetail, emptyHistoryYear, emptyHistoryYearDetail, initialModel)

import Debounce exposing (Debounce)
import RemoteData exposing (WebData)


type alias Flags =
    { contentType : String
    , isAdult : Bool
    , activeTab : String
    , breakdownType : String
    , detailGroup : String
    , theme : Theme
    }


type alias Theme =
    { baseBackground : String
    , baseBackgroundHover : String
    , baseColour : String
    , colour : String
    , contrast : String
    , anchorColour : String
    , anchorColourHover : String
    , primaryBackground : String
    , primaryBackgroundHover : String
    , primaryColour : String
    }


type alias InputField =
    { name : String
    , value : String
    }


type alias Model =
    { debounce : Debounce InputField
    , status : WebData CountData
    , history : WebData CountData
    , historyDetail : WebData HistoryDetailData
    , historyYear : WebData HistoryYearData
    , rating : WebData CountData
    , seriesList : SeriesData
    , repeatedList : RepeatedSeriesData
    , settings : Settings
    , ratingsFilters : RatingFilters
    , repeatedFilters : RepeatedFilters
    , airingList : HistoryDetailData
    , theme : Theme
    }


type alias Settings =
    { activeTab : String
    , breakdownType : String
    , detailGroup : String
    , sorting : Sort
    , isAdult : Bool
    , contentType : String
    , requireKey : Bool
    }


type alias Sort =
    { field : String
    , isDesc : Bool
    }


type alias RatingFilters =
    { searchText : String
    , ratings : List Int
    }


type alias RepeatedFilters =
    { searchText : String
    }


initialModel : Flags -> Model
initialModel flags =
    { debounce = Debounce.init
    , status = RemoteData.Loading
    , history = RemoteData.Loading
    , historyDetail = RemoteData.Loading
    , historyYear = RemoteData.Loading
    , rating = RemoteData.Loading
    , seriesList = []
    , repeatedList = []
    , airingList = []
    , settings =
        { activeTab = flags.activeTab
        , breakdownType = flags.breakdownType
        , detailGroup = flags.detailGroup
        , sorting =
            { field = "RATING"
            , isDesc = True
            }
        , contentType = flags.contentType
        , isAdult = flags.isAdult
        , requireKey = False
        }
    , ratingsFilters =
        { searchText = ""
        , ratings = []
        }
    , repeatedFilters =
        { searchText = ""
        }
    , theme = flags.theme
    }


type alias CountData =
    List Count


type alias Count =
    { key : String
    , value : Int
    }


emptyCount : Count
emptyCount =
    Count "" 0


type alias HistoryDetailData =
    List HistoryDetail


type alias HistoryDetail =
    { id : String
    , title : String
    , episodeStatistics : EpisodeStatistic
    , rating : Int
    , season : String
    }


type alias EpisodeStatistic =
    { id : String
    , average : Float
    , highest : Int
    , lowest : Int
    , mode : Int
    }


emptyEpisodeStatistic : EpisodeStatistic
emptyEpisodeStatistic =
    EpisodeStatistic "" 0.0 0 0 0


emptyHistoryDetail : HistoryDetail
emptyHistoryDetail =
    HistoryDetail "" "" emptyEpisodeStatistic 0 ""


type alias HistoryYearData =
    List HistoryYear


type alias HistoryYear =
    { id : String
    , value : Int
    , average : Float
    , highest : Int
    , lowest : Int
    , mode : Int
    }


emptyHistoryYear : HistoryYear
emptyHistoryYear =
    HistoryYear "" 0 0.0 0 0 0


type alias HistoryYearDetail =
    { counts : HistoryYearData
    , detail : HistoryDetailData
    }


emptyHistoryYearDetail : HistoryYearDetail
emptyHistoryYearDetail =
    HistoryYearDetail [] []


type ObjectsWithValue
    = HistoryYearData
    | CountData


type alias Series =
    { id : String
    , name : String
    , rating : Int
    }


type alias SeriesData =
    List Series


type alias RepeatedSeries =
    { id : String
    , name : String
    , timesCompleted : Int
    , rating : Int
    , isOwned : Bool
    , lastRepeatDate : List String
    }


type alias RepeatedSeriesData =
    List RepeatedSeries



-- Constant models


type alias Header =
    { name : String
    , number : Int
    }
