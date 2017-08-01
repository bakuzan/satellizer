module Utils.Constants exposing (..)

import General.RadioButton exposing (RadioOption)
import Models exposing (Header)
import Msgs


type alias ItemType =
  { anime: String
  , manga: String
  }


itemType : ItemType
itemType =
  ItemType "anime" "manga"



months : List Header
months =
  [{ name = "Jan", number = 0 }
  ,{ name = "Feb", number = 1 }
  ,{ name = "Mar", number = 2 }
  ,{ name = "Apr", number = 3 }
  ,{ name = "May", number = 4 }
  ,{ name = "Jun", number = 5 }
  ,{ name = "Jul", number = 6 }
  ,{ name = "Aug", number = 7 }
  ,{ name = "Sep", number = 8 }
  ,{ name = "Oct", number = 9 }
  ,{ name = "Nov", number = 10 }
  ,{ name = "Dec", number = 11 }
  ]


seasons : List Header
seasons =
  [{ name = "Winter", number = 3 }
  ,{ name = "Spring", number = 6 }
  ,{ name = "Summer", number = 9 }
  ,{ name = "Fall", number = 12 }
  ]



breakdownOptions : List RadioOption
breakdownOptions =
  [{ label = "Months", optionValue = "MONTHS", action = Msgs.UpdateBreakdownType "MONTHS" }
  ,{ label = "Season", optionValue = "SEASON", action = Msgs.UpdateBreakdownType "SEASON" }
  ]
