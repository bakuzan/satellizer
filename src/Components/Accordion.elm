module Components.Accordion exposing (view)

import Css
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
            [ Css.position Css.absolute
            , Css.backgroundColor (Css.hex theme.baseColour)
            , Css.property "content" "''"
            , Css.transform (Css.rotate (Css.deg 0))
            , Css.property "transition" "0.5s"
            , Css.top (Css.pct 50)
            ]
    in
    div
        [ class "accordion"
        , css
            [ Css.width (Css.pct 25)
            , Css.minWidth (Css.px 500)
            , Css.margin (Css.px 0)
            , Css.borderBottom3 (Css.px 2) Css.solid (Css.hex "888")
            ]
        ]
        [ global
            [ typeSelector ".accordion-toggler:checked + label:before"
                [ Css.transform (Css.rotate (Css.deg 360))
                , Css.property "transition" "0.5s"
                ]
            , typeSelector ".accordion-toggler:checked + label:after"
                [ Css.transform (Css.rotate (Css.deg 450))
                , Css.property "transition" "0.5s"
                ]
            , typeSelector ".accordion-toggler:checked ~ .accordion-content"
                [ Css.height Css.auto
                , Css.margin3 (Css.px 0) (Css.px 0) (Css.rem 1.6)
                , Css.Global.children
                    [ typeSelector "*"
                        [ Css.opacity (Css.int 1)
                        , Css.property "transition" "0.5s"
                        , Css.property "transition-delay" "0.25s"
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
                [ Css.display Css.none
                ]
            ]
            []
        , label
            [ for idLink
            , css
                [ Css.display Css.block
                , Css.position Css.relative
                , Css.padding (Css.px 5)
                , Css.fontWeight (Css.int 700)
                , Css.marginRight (Css.px 10)
                , Css.cursor Css.pointer
                , Css.before
                    (labelPseudoStyle
                        ++ [ Css.right (Css.px 0)
                           , Css.width (Css.px 10)
                           , Css.height (Css.px 2)
                           , Css.marginTop (Css.px -1)
                           ]
                    )
                , Css.after
                    (labelPseudoStyle
                        ++ [ Css.right (Css.px 4)
                           , Css.height (Css.px 10)
                           , Css.width (Css.px 2)
                           , Css.marginTop (Css.px -5)
                           ]
                    )
                ]
            ]
            [ text title ]
        , div
            [ class "accordion-content"
            , css
                [ Css.height (Css.px 1)
                , Css.overflow Css.hidden
                , Css.Global.children
                    [ typeSelector "*"
                        [ Css.opacity (Css.int 0)
                        , Css.property "transition" "0.5s"
                        , Css.lineHeight (Css.em 1.75)
                        ]
                    ]
                ]
            ]
            ([] ++ children)
        ]
