module Components.SeasonKey exposing (view)

import Css exposing (..)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (class, classList, css, id, title)
import Models exposing (Theme)
import Msgs exposing (Msg)
import Utils.Colours exposing (seasonColours)


view : Theme -> Bool -> Html Msg
view theme shouldDisplay =
    if shouldDisplay then
        viewKey theme

    else
        text ""


viewKey : Theme -> Html Msg
viewKey theme =
    div
        [ id "season-key"
        , css
            [ position fixed
            , top (px 75)
            , right (px 10)
            , backgroundColor (hex theme.baseBackground)
            , boxShadow4 (px 1) (px 1) (px 5) (px 1)
            , zIndex (int 10)
            ]
        ]
        [ viewKeyEntry "winter"
        , viewKeyEntry "spring"
        , viewKeyEntry "summer"
        , viewKeyEntry "autumn"
        ]


viewKeyEntry : String -> Html Msg
viewKeyEntry season =
    let
        colour =
            List.filter (\x -> Tuple.first x == season) seasonColours
                |> List.head
                |> Maybe.withDefault ( "", "000" )
                |> Tuple.second
    in
    div
        [ class "key-entry"
        , classList [ ( season, True ) ]
        , css
            [ displayFlex
            , margin (px 1)
            , border3 (px 1) solid (hex colour)
            ]
        , title season
        ]
        [ div
            [ class "colour-block"
            , css
                [ width (px 25)
                , height (px 25)
                , backgroundColor (hex colour)
                ]
            ]
            []
        , div
            [ class "label"
            , css
                [ width (px 25)
                , fontWeight bold
                , fontSize (em 1.2)
                , textAlign center
                ]
            ]
            [ text (String.left 1 season |> String.toUpper)
            ]
        ]
