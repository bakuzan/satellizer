module Statistics.Tags exposing (view)

import Components.Button as Button
import Components.ClearableInput
import Components.NewTabLink
import Components.TableSortHeader as TSH
import Css exposing (..)
import Html.Styled exposing (Html, div, h2, li, span, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id, title)
import Html.Styled.Events exposing (onClick)
import Models exposing (Model, Tag, TagsFilters, TagsSeries, TagsSeriesPage, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Constants as Constants
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> TagsFilters -> List Tag -> TagsSeriesPage -> Html Msg
view model filters tags seriesPage =
    let
        sorting =
            model.settings.sorting

        sortedList =
            Sorters.sortTags sorting.field sorting.isDesc tags

        nodeCount =
            List.length seriesPage.nodes

        listCountHeading =
            "Showing " ++ String.fromInt nodeCount ++ " of " ++ String.fromInt seriesPage.total

        renderTh =
            TSH.view sorting model.theme

        hasSelected =
            List.length filters.tagIds > 0
    in
    div
        [ id "tags-tab"
        , class "tag-stats"
        , css
            [ property "display" "grid"
            , property "grid-template-columns" "minmax(380px, 480px) minmax(200px, 1fr)"
            , property "grid-gap" "8px"
            , width (pct 100)
            , padding2 (px 10) (px 5)
            ]
        ]
        [ div []
            [ table [ css [ width (pct 100) ] ]
                [ thead []
                    [ tr []
                        [ th []
                            [ Button.view { isPrimary = False, theme = model.theme }
                                [ class "tags-label"
                                , classList [ ( "selected", hasSelected ) ]
                                , css
                                    ([ position relative
                                     , displayFlex
                                     , alignItems center
                                     , justifyContent center
                                     , important (minWidth (rem 2))
                                     , height (rem 2)
                                     , margin auto
                                     ]
                                        ++ Styles.selectedStyle model.theme hasSelected
                                    )
                                , onClick Msgs.ClearAllTagsFilter
                                , Common.setCustomAttr "aria-label" "Click to clear all selected"
                                , Common.setCustomAttr "title" "Click to clear all selected"
                                ]
                                [ span
                                    [ css
                                        [ position absolute
                                        , top (px 2)
                                        , displayFlex
                                        , alignItems center
                                        , fontSize (rem 2)
                                        , height (px 24)
                                        ]
                                    , Common.setCustomAttr "aria-hidden" "true"
                                    ]
                                    [ text (Common.selectionIcon hasSelected) ]
                                ]
                            ]
                        , renderTh "Name" [ justifyContent flexStart ]
                        , renderTh "Usage count" (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ])
                        , renderTh "Average rating" (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ])
                        ]
                    ]
                , tbody [] (List.map (viewTagRow model.theme filters.tagIds) sortedList)
                ]
            ]
        , div []
            [ div [ css [ width (pct 100) ] ]
                [ Components.ClearableInput.view model.theme "tagSeriesSearch" "search" filters.searchText []
                , viewInvalidFilterWarning filters
                ]
            , h2 [ css [ fontSize (rem 1), marginLeft (px 10) ] ] [ text listCountHeading ]
            , ul [ css (Styles.list model.theme True 1) ]
                (List.map (viewSeriesItem model.theme model.settings.contentType) seriesPage.nodes)
            , if seriesPage.hasMore then
                Button.view { isPrimary = False, theme = model.theme }
                    [ css [ width (pct 100) ]
                    , onClick Msgs.NextTagsSeriesPage
                    ]
                    [ text "Load more..."
                    ]

              else
                text ""
            ]
        ]


viewInvalidFilterWarning : TagsFilters -> Html Msg
viewInvalidFilterWarning filters =
    if List.length filters.tagIds == 0 && String.length filters.searchText > 0 then
        div [ css [ color (hex "f00"), fontSize (em 0.75), margin2 (px 0) (px 10) ] ]
            [ text "A tag must be selected for results to appear" ]

    else
        text ""


viewTagRow : Theme -> List Int -> Tag -> Html Msg
viewTagRow theme selectedTagIds data =
    let
        seriesLink =
            "/erza/tag-management/" ++ String.fromInt data.id

        isSelected =
            List.member data.id selectedTagIds

        ariaLabel =
            if isSelected then
                data.name ++ ": selected"

            else
                data.name ++ ": not selected"
    in
    tr [ css (Styles.entryHoverHighlight theme) ]
        [ td [ css [ padding2 (px 0) (px 4) ] ]
            [ Button.view { isPrimary = False, theme = theme }
                [ class "tags-label"
                , classList [ ( "selected", isSelected ) ]
                , css
                    ([ position relative
                     , displayFlex
                     , alignItems center
                     , justifyContent center
                     , important (minWidth (rem 2))
                     , height (rem 2)
                     , margin auto
                     ]
                        ++ Styles.selectedStyle theme isSelected
                    )
                , onClick (Msgs.ToggleTagsFilter data.id)
                , Common.setCustomAttr "aria-label" ariaLabel
                ]
                [ span
                    [ css
                        [ position absolute
                        , top (px 2)
                        , displayFlex
                        , alignItems center
                        , fontSize (rem 2)
                        , height (px 24)
                        ]
                    , Common.setCustomAttr "aria-hidden" "true"
                    ]
                    [ text (Common.selectionIcon isSelected) ]
                ]
            ]
        , td [ css [ padding2 (px 0) (px 4) ] ]
            [ Components.NewTabLink.view theme
                [ href seriesLink, title ("View " ++ data.name ++ " details") ]
                [ text data.name ]
            ]
        , td [ css (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ]) ] [ text (String.fromInt data.timesUsed) ]
        , td [ css (Styles.rightAlign ++ [ padding2 (px 0) (px 4) ]) ] [ text data.averageRating ]
        ]


viewSeriesItem : Theme -> String -> TagsSeries -> Html Msg
viewSeriesItem theme contentType item =
    let
        seriesLink =
            Constants.erzaSeriesLink contentType item.id
    in
    li
        [ css
            ([ displayFlex
             , justifyContent spaceBetween
             , padding2 (px 0) (px 4)
             ]
                ++ Styles.entryHoverHighlight theme
            )
        ]
        [ Components.NewTabLink.view theme
            [ href seriesLink, title ("View " ++ item.title ++ " details") ]
            [ text item.title ]
        , span []
            [ text
                (if item.rating == 0 then
                    "-"

                 else
                    String.fromInt item.rating
                )
            ]
        ]
