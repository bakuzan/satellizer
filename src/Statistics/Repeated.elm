module Statistics.Repeated exposing (view)

import Components.Button as Button
import Components.ClearableInput
import Components.NewTabLink
import Components.TableSortHeader as TSH
import Css exposing (..)
import Html.Styled exposing (Html, div, h2, span, table, tbody, td, text, th, thead, tr)
import Html.Styled.Attributes exposing (class, classList, colspan, css, href, id, title)
import Html.Styled.Events exposing (onClick)
import Models exposing (Model, RepeatHistory, RepeatHistoryResponse, RepeatedFilters, RepeatedSeries, RepeatedSeriesData, Theme, emptyRepeatHistoryResponse)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> RepeatedFilters -> RepeatedSeriesData -> Html Msg
view model filters repeatedList =
    let
        seriesCount =
            List.length repeatedList

        seriesCountTitle =
            "Showing " ++ String.fromInt seriesCount ++ " series"

        renderTitle =
            if seriesCount < 1 then
                text ""

            else
                h2 [ id "series-title", css [ fontSize (rem 1) ] ] [ text seriesCountTitle ]
    in
    div [ id "repeated-tab", css (Styles.listTabStyles ++ [ flexDirection column ]) ]
        [ Components.ClearableInput.view model.theme "repeatedSearch" "search" filters.searchText []
        , renderTitle
        , viewSeriesList model repeatedList
        ]


viewSeriesList : Model -> RepeatedSeriesData -> Html Msg
viewSeriesList model seriesList =
    let
        sorting =
            model.settings.sorting

        sortedSeriesList =
            Sorters.sortRepeatedSeries sorting.field sorting.isDesc seriesList

        renderTh =
            TSH.view model.settings.sorting model.theme
    in
    table
        [ id "repeated-series-table"
        , css
            [ minWidth (px 400)
            , maxWidth (pct 80)
            ]
        ]
        [ thead []
            [ tr []
                [ th [] []
                , renderTh "Title" [ justifyContent flexStart ]
                , renderTh "Rating" [ margin2 (px 0) auto ]
                , renderTh "Repeats" [ margin2 (px 0) auto ]
                , renderTh "Last Repeat" [ minWidth (px 105), margin2 (px 0) auto ]
                ]
            ]
        , tbody []
            ([]
                ++ (List.map (viewSeriesEntry model) sortedSeriesList
                        |> Common.denestList
                   )
            )
        ]


viewSeriesEntry : Model -> RepeatedSeries -> List (Html Msg)
viewSeriesEntry model entry =
    let
        theme =
            model.theme

        contentType =
            model.settings.contentType

        seriesLink =
            Constants.erzaSeriesLink contentType entry.id

        lastRepeatDate =
            if entry.lastRepeatDate == "" then
                "Unknown"

            else
                entry.lastRepeatDate

        isOwnedTitle =
            if entry.isOwned then
                "Owned"

            else
                "Not owned"

        icon =
            if entry.isOwned then
                "✓"

            else
                "❌︎"
    in
    [ tr
        [ id (String.fromInt entry.id)
        , class "repeated-series-table-row"
        , css (Styles.entryHoverHighlight theme)
        ]
        [ td [ css [ padding2 (px 0) (px 4), textAlign center ] ]
            [ div
                [ class "is-owned"
                , classList [ ( "owned", entry.isOwned ), ( "not-owned", not entry.isOwned ) ]
                , title isOwnedTitle
                , Common.setCustomAttr "aria-label" isOwnedTitle
                , Common.setIcon icon
                , css
                    [ Styles.icon
                    , display inlineBlock
                    , width (px 20)
                    , height (pct 100)
                    , lineHeight (int 1)
                    , before
                        [ fontSize (em 0.8)
                        , fontWeight bold
                        ]
                    ]
                ]
                []
            ]
        , td [ class "left-align", css (Styles.leftAlign ++ [ padding2 (px 0) (px 4) ]) ]
            [ Components.NewTabLink.view theme
                [ href seriesLink, title ("View " ++ entry.title ++ " details") ]
                [ text entry.title ]
            ]
        , td [ css [ padding2 (px 0) (px 4), textAlign center ] ]
            [ span [] [ text (String.fromInt entry.rating) ]
            ]
        , td [ css [ padding2 (px 0) (px 4), textAlign center ] ]
            [ Button.view { isPrimary = False, theme = theme }
                [ onClick (Msgs.ToggleRepeatHistory entry.id)
                , title "Show repeat history"
                , Common.setCustomAttr "aria-label" "Show repeat history"
                , class "slz-times-completed"
                ]
                [ span [] [ text (String.fromInt entry.timesCompleted) ] ]
            ]
        , td [ class "date-column", css [ minWidth (px 105), padding2 (px 0) (px 4), textAlign center ] ]
            [ span [] [ text lastRepeatDate ]
            ]
        ]
    , viewRepeatHistoryRow contentType entry model.repeatHistory
    ]


viewRepeatHistoryRow : String -> RepeatedSeries -> List RepeatHistoryResponse -> Html Msg
viewRepeatHistoryRow contentType entry data =
    let
        seriesId =
            entry.id

        statType =
            Common.toCapital contentType

        repeatHistory =
            List.filter (\x -> x.statType == statType && x.seriesId == seriesId) data
                |> List.head
                |> Maybe.withDefault emptyRepeatHistoryResponse
    in
    if repeatHistory.hasRepeats then
        tr []
            [ td [] []
            , td [ colspan 4 ]
                [ table [ css [ width (pct 100) ] ]
                    [ thead [] [ tr [] [ th [] [] ] ]
                    , tbody []
                        ([]
                            ++ List.map viewWarning repeatHistory.warningMessages
                            ++ List.map (viewRepeat repeatHistory.seriesTotalParts) repeatHistory.items
                        )
                    ]
                ]
            ]

    else
        text ""


viewWarning : String -> Html Msg
viewWarning message =
    tr [] [ td [] [ text message ] ]


viewRepeat : Int -> RepeatHistory -> Html Msg
viewRepeat seriesTotalParts item =
    let
        padNum n =
            String.fromInt n
                |> String.padLeft 3 '0'

        from =
            item.startDateFormatted ++ " (#" ++ padNum item.start ++ ")"

        to =
            if item.isCurrentRepeat then
                "Present"

            else
                item.endDateFormatted ++ " (#" ++ padNum item.end ++ ")"

        repeatText =
            if seriesTotalParts == 1 then
                from

            else
                from ++ " - " ++ to
    in
    tr [] [ td [] [ text repeatText ] ]
