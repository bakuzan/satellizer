module Components.Accordion exposing (view)

import Css exposing (..)
import Css.Global exposing (global, typeSelector)
import Html.Styled exposing (Html, div, input, label, text)
import Html.Styled.Attributes exposing (class, css, for, id, name, type_)
import Models exposing (Theme)
import Msgs exposing (Msg)


view : Theme -> String -> String -> List (Html Msg) -> Html Msg
view theme htmlId title children =
    let
        idLink =
            htmlId ++ "-accordion"

        labelPseudoStyle =
            [ position absolute
            , backgroundColor (hex theme.baseColour)
            , property "content" "''"
            , transform (rotate (deg 0))
            , property "transition" "0.5s"
            , top (pct 50)
            ]
    in
    div
        [ class "accordion"
        , css
            [ width (pct 25)
            , minWidth (px 500)
            , margin (px 0)
            , borderBottom3 (px 2) solid (hex "888")
            ]
        ]
        [ global
            [ typeSelector ".accordion-toggler:checked + label:before"
                [ transform (rotate (deg 360))
                , property "transition" "0.5s"
                ]
            , typeSelector ".accordion-toggler:checked + label:after"
                [ transform (rotate (deg 450))
                , property "transition" "0.5s"
                ]
            , typeSelector ".accordion-toggler:checked ~ .accordion-content"
                [ height auto
                , margin3 (px 0) (px 0) (rem 1.6)
                , Css.Global.children
                    [ typeSelector "*"
                        [ opacity (int 1)
                        , property "transition" "0.5s"
                        , property "transition-delay" "0.25s"
                        ]
                    ]
                ]
            ]
        , input
            [ type_ "checkbox"
            , class "accordion-toggler"
            , id idLink
            , name "accordion"
            , css
                [ display none
                ]
            ]
            []
        , label
            [ for idLink
            , css
                [ display block
                , position relative
                , padding (px 5)
                , fontWeight (int 700)
                , marginRight (px 10)
                , cursor pointer
                , before
                    (labelPseudoStyle
                        ++ [ right (px 0)
                           , width (px 10)
                           , height (px 2)
                           , marginTop (px -1)
                           ]
                    )
                , after
                    (labelPseudoStyle
                        ++ [ right (px 4)
                           , height (px 10)
                           , width (px 2)
                           , marginTop (px -5)
                           ]
                    )
                ]
            ]
            [ text title ]
        , div
            [ class "accordion-content"
            , css
                [ height (px 1)
                , overflow hidden
                , Css.Global.children
                    [ typeSelector "*"
                        [ opacity (int 0)
                        , property "transition" "0.5s"
                        , lineHeight (em 1.75)
                        ]
                    ]
                ]
            ]
            ([] ++ children)
        ]
