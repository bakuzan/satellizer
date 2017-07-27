module Utils.Constants exposing (..)



type alias Type = 
  { anime: String
  , manga: String
  }

type : Type
type =
  { anime = "anime
  , manga = "manga"
  }

type alias Header = 
  { name: String
  , number: Int
  }

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
  ,{ name = "Fall" number = 12 }
  ]
  
  
