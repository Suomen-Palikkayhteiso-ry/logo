module Component.SectionHeader exposing (view, viewSub)

import Html exposing (Html)
import Html.Attributes as Attr


{-| Top-level section heading (h2). Use directly under the page h1.
-}
view : { title : String, description : Maybe String } -> Html msg
view { title, description } =
    Html.div [ Attr.class "mb-6" ]
        (Html.h2 [ Attr.class "type-h2 text-brand" ] [ Html.text title ]
            :: (case description of
                    Just desc ->
                        [ Html.p [ Attr.class "mt-2 text-gray-600" ] [ Html.text desc ] ]

                    Nothing ->
                        []
               )
        )


{-| Sub-section heading (h3). Use inside a section that already has an h2.
-}
viewSub : { title : String, description : Maybe String } -> Html msg
viewSub { title, description } =
    Html.div [ Attr.class "mb-4" ]
        (Html.h3 [ Attr.class "type-h4 text-brand" ] [ Html.text title ]
            :: (case description of
                    Just desc ->
                        [ Html.p [ Attr.class "mt-1 text-gray-600 text-sm" ] [ Html.text desc ] ]

                    Nothing ->
                        []
               )
        )
