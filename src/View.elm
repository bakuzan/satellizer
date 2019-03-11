module View exposing (view)

import Css exposing (..)
import General.ProgressBar
import General.Tabs exposing (..)
import Html.Styled exposing (Html, div)
import Html.Styled.Attributes exposing (css, id)
import Models exposing (CountData, Model)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)
import Statistics.Airing
import Statistics.HistoryTable
import Statistics.Ratings
import Statistics.Repeated
import Utils.Common as Common


viewRender : WebData (List a) -> List a
viewRender model =
    case model of
        RemoteData.NotAsked ->
            []

        RemoteData.Loading ->
            []

        RemoteData.Failure err ->
            []

        RemoteData.Success m ->
            m


view : Model -> Html Msg
view model =
    let
        activeTab =
            model.settings.activeTab

        status =
            model.status

        history =
            viewRender model.history

        detail =
            viewRender model.historyDetail

        yearDetail =
            viewRender model.historyYear

        ratings =
            viewRender model.rating

        seriesList =
            model.seriesList
    in
    div
        [ css
            [ displayFlex
            , flexDirection column
            , flexGrow (int 1)
            ]
        ]
        [ viewRender status |> viewStatus
        , viewTabContainer activeTab
            [ ( "Airing", [ Statistics.Airing.view model.settings model.airingList ] )
            , ( "History", [ Statistics.HistoryTable.view model.settings history detail yearDetail ] )
            , ( "Ratings", [ Statistics.Ratings.view model.settings model.ratingsFilters ratings seriesList ] )
            , ( "Repeated", [ Statistics.Repeated.view model.settings model.repeatedFilters model.repeatedList ] )
            ]
        ]


viewStatus : CountData -> Html Msg
viewStatus list =
    let
        total =
            Common.calculateTotalOfValues list
    in
    div [ id "status-container", css [ margin (px 15) ] ]
        [ General.ProgressBar.viewProgressBar total list
        ]
