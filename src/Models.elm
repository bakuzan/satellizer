module Models exposing (..)

import RemoteData exposing (WebData)


type alias Flags =
  { contentType: String
  , isAdult: Bool
  }


type alias Model =
    { status : WebData CountData
    , history: WebData CountData
    , historyDetail: WebData HistoryDetailData
    , historyYear: WebData HistoryYearData
    , rating: WebData CountData
    , seriesList: SeriesData
    , repeatedList: RepeatedSeriesData
    , route: Route
    , settings: Settings
    , ratingsFilters: RatingFilters
    , repeatedFilters: RepeatedFilters
    }


type alias Settings =
  { activeTab: String
  , breakdownType: String
  , detailGroup: String
  , sorting: Sort
  , isAdult: Bool
  , contentType: String
  , requireKey: Bool
  }


type alias Sort =
  { field: String
  , isDesc: Bool
  }

type alias RatingFilters =
  { searchText: String
  , ratings: List Int
  }

type alias RepeatedFilters =
  { searchText: String
  }

initialModel : Flags -> Route -> Model
initialModel flags route =
    { status = RemoteData.Loading
    , history = RemoteData.Loading
    , historyDetail = RemoteData.Loading
    , historyYear = RemoteData.Loading
    , rating = RemoteData.Loading
    , seriesList = []
    , repeatedList = []
    , route = route
    , settings =
      { activeTab = "History"
      , breakdownType = "MONTHS"
      , detailGroup = ""
      , sorting =
        { field = "TITLE"
        , isDesc = False
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
    }


type alias CountData =
  List Count


type alias Count =
  { key: String
  , value: Int
  }


emptyCount : Count
emptyCount =
  Count "" 0


type alias HistoryDetailData =
  List HistoryDetail


type alias HistoryDetail =
  { id: String
  , title: String
  , episodeStatistics: EpisodeStatistic
  , rating: Int
  , season: String
  }


type alias EpisodeStatistic =
  { id: String
  , average: Float
  , highest: Int
  , lowest: Int
  , mode: Int
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
  { id: String
  , value: Int
  , average: Float
  , highest: Int
  , lowest: Int
  , mode: Int
  }


emptyHistoryYear : HistoryYear
emptyHistoryYear =
  HistoryYear "" 0 0.0 0 0 0


type alias HistoryYearDetail =
  { counts: HistoryYearData
  , detail: HistoryDetailData
  }


emptyHistoryYearDetail : HistoryYearDetail
emptyHistoryYearDetail =
    HistoryYearDetail [] []


type ObjectsWithValue
  = HistoryYearData
  | CountData

type alias Series =
  { id: String
  , name: String
  , rating: Int
  }

type alias SeriesData =
  List Series

type alias RepeatedSeries =
  { id: String
  , name: String
  , timesCompleted: Int
  , rating: Int
  , isOwned: Bool
  , lastRepeatDate: List SeriesHistory
  }

type alias RepeatedSeriesData =
  List RepeatedSeries

type alias SeriesHistory =
  { date: Int
  , dateStr: String
  }

-- Constant models

type alias Header =
  { name: String
  , number: Int
  }




-- Routing

type Route
    = StatisticsRoute
    | NotFoundRoute
