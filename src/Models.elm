module Models exposing
    ( Count
    , CountData
    , EpisodeStatistic
    , Flags
    , Header
    , HistoryDetail
    , HistoryDetailData
    , HistoryYear
    , HistoryYearData
    , HistoryYearDetail
    , InputField
    , Model
    , RatingFilters
    , RepeatedFilters
    , RepeatedSeries
    , RepeatedSeriesData
    , Series
    , SeriesData
    , Settings
    , Sort
    , Tag
    , TagData
    , TagsFilters
    , TagsSeries
    , TagsSeriesData
    , Theme
    , emptyCount
    , emptyEpisodeStatistic
    , emptyHistoryDetail
    , emptyHistoryYear
    , emptyHistoryYearDetail
    , initialModel
    )

import Debounce exposing (Debounce)


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
    , status : CountData
    , history : CountData
    , historyDetail : HistoryDetailData
    , historyYear : HistoryYearData
    , rating : CountData
    , seriesList : SeriesData
    , repeatedList : RepeatedSeriesData
    , tags : TagData
    , tagsSeriesList : TagsSeriesData
    , settings : Settings
    , ratingsFilters : RatingFilters
    , repeatedFilters : RepeatedFilters
    , tagsFilters : TagsFilters
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


type alias TagsFilters =
    { searchText : String
    , tagIds : List Int
    }


initialModel : Flags -> Model
initialModel flags =
    let
        activeTab =
            resolveTab flags

        sortField =
            if activeTab == "Airing" then
                "AVERAGE"

            else
                "RATING"
    in
    { debounce = Debounce.init
    , status = []
    , history = []
    , historyDetail = []
    , historyYear = []
    , rating = []
    , seriesList = []
    , repeatedList = []
    , tags = []
    , tagsSeriesList = []
    , airingList = []
    , settings =
        { activeTab = activeTab
        , breakdownType = flags.breakdownType
        , detailGroup = flags.detailGroup
        , sorting =
            { field = sortField
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
    , tagsFilters =
        { searchText = ""
        , tagIds = []
        }
    , theme = flags.theme
    }


resolveTab : Flags -> String
resolveTab flags =
    let
        isAiringTab =
            flags.activeTab == "Airing"
    in
    if (flags.isAdult || flags.contentType == "manga") && isAiringTab then
        "History"

    else
        flags.activeTab


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
    { id : Int
    , title : String
    , rating : Int
    , season : String
    , average : Float
    , highest : Int
    , lowest : Int
    , mode : Int
    }


type alias EpisodeStatistic =
    { average : Float
    , highest : Int
    , lowest : Int
    , mode : Int
    }


emptyEpisodeStatistic : EpisodeStatistic
emptyEpisodeStatistic =
    EpisodeStatistic -1.0 -1 -1 -1


emptyHistoryDetail : HistoryDetail
emptyHistoryDetail =
    HistoryDetail 0 "" 0 "" 0.0 0 0 0


type alias HistoryYearData =
    List HistoryYear


type alias HistoryYear =
    { key : String
    , average : Float
    , highest : Int
    , lowest : Int
    , mode : Int
    }


emptyHistoryYear : HistoryYear
emptyHistoryYear =
    HistoryYear "" 0.0 0 0 0


type alias HistoryYearDetail =
    { counts : HistoryYearData
    , detail : HistoryDetailData
    }


emptyHistoryYearDetail : HistoryYearDetail
emptyHistoryYearDetail =
    HistoryYearDetail [] []


type alias Series =
    { id : Int
    , name : String
    , rating : Int
    }


type alias SeriesData =
    List Series


type alias RepeatedSeries =
    { id : Int
    , title : String
    , rating : Int
    , timesCompleted : Int
    , isOwned : Bool
    , lastRepeatDate : String
    }


type alias RepeatedSeriesData =
    List RepeatedSeries


type alias Tag =
    { id : Int
    , name : String
    , timesUsed : Int
    , averageRating : String
    }


type alias TagData =
    List Tag


type alias TagsSeries =
    { id : Int
    , title : String
    }


type alias TagsSeriesData =
    List TagsSeries



-- Constant models


type alias Header =
    { name : String
    , number : Int
    }
