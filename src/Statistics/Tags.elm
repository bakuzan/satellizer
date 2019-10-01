module Statistics.Tags exposing (view)

import Components.Button as Button
import Components.ClearableInput
import Components.NewTabLink
import Css exposing (..)
import Html.Styled exposing (Html, button, div, h2, li, span, strong, table, tbody, td, text, th, thead, tr, ul)
import Html.Styled.Attributes exposing (class, classList, css, href, id, title)
import Html.Styled.Events exposing (onClick)
import Models exposing (Model, Settings, Tag, TagsFilters, TagsSeries, TagsSeriesPage, Theme)
import Msgs exposing (Msg)
import Utils.Common as Common
import Utils.Sorters as Sorters
import Utils.Styles as Styles


view : Model -> TagsFilters -> List Tag -> TagsSeriesPage -> Html Msg
view model filters tags seriesPage =
    let
        tabColumn =
            [ displayFlex, flexDirection column, width (pct 50) ]

        nodeCount =
            List.length seriesPage.nodes

        listCountHeading =
            "Showing " ++ String.fromInt nodeCount ++ " of " ++ String.fromInt seriesPage.total
    in
    div [ id "tags-tab", css Styles.listTabStyles ]
        [ div [ css (tabColumn ++ [ marginRight (px 4) ]) ]
            [ table []
                [ thead []
                    [ tr []
                        [ th [] [ text "" ]
                        , th [ css Styles.leftAlign ] [ text "Name" ]
                        , th [ css Styles.rightAlign ] [ text "Usage count" ]
                        , th [ css Styles.rightAlign ] [ text "Average rating" ]
                        ]
                    ]
                , tbody [] (List.map (viewTagRow model.theme filters.tagIds) tags)
                ]
            ]
        , div [ css (tabColumn ++ [ marginLeft (px 4) ]) ]
            [ div [ css [ width (pct 100) ] ]
                [ Components.ClearableInput.view model.theme "tagSeriesSearch" "search" filters.searchText [] ]
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


viewTagRow : Theme -> List Int -> Tag -> Html Msg
viewTagRow theme selectedTagIds data =
    let
        seriesLink =
            "http://localhost:9003/erza/tag-management/" ++ String.fromInt data.id

        isSelected =
            List.member data.id selectedTagIds

        selectedStyle =
            if isSelected then
                [ important (backgroundColor (hex theme.primaryBackground))
                , important (color (hex theme.primaryColour))
                , hover [ backgroundColor (hex theme.primaryBackgroundHover) ]
                ]

            else
                []

        selectionIcon =
            if isSelected then
                "☑︎"

            else
                "☐︎"

        ariaLabel =
            if isSelected then
                data.name ++ ": selected"

            else
                data.name ++ ": not selected"
    in
    tr []
        [ td []
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
                     ]
                        ++ selectedStyle
                    )
                , onClick (Msgs.ToggleTagsFilter data.id)
                , Common.setCustomAttr "aria-label" ariaLabel
                ]
                [ span
                    [ css
                        [ position absolute
                        , top (px -8)
                        , left (px 0)
                        , right (px 0)
                        , fontSize (rem 2)
                        ]
                    , Common.setCustomAttr "aria-hidden" "true"
                    ]
                    [ text selectionIcon ]
                ]
            ]
        , td []
            [ Components.NewTabLink.view theme
                [ href seriesLink, title ("View " ++ data.name ++ " details") ]
                [ text data.name ]
            ]
        , td [ css Styles.rightAlign ] [ text (String.fromInt data.timesUsed) ]
        , td [ css Styles.rightAlign ] [ text data.averageRating ]
        ]


viewSeriesItem : Theme -> String -> TagsSeries -> Html Msg
viewSeriesItem theme contentType item =
    let
        seriesLink =
            "http://localhost:9003/erza/" ++ contentType ++ "-view/" ++ String.fromInt item.id
    in
    li []
        [ Components.NewTabLink.view theme
            [ href seriesLink, title ("View " ++ item.title ++ " details") ]
            [ text item.title ]
        ]
