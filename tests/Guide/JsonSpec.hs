{-# LANGUAGE OverloadedStrings #-}
module Guide.JsonSpec (tests) where

import Guide.Colors (associationName)
import Data.Aeson (decode, Value(..))
import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import Test.Tasty
import Test.Tasty.HUnit

tests :: TestTree
tests = testGroup "Guide.Json"
    [ testCase "associationName matches expected value" $
        associationName @?= "Suomen Palikkaharrastajat ry"
    ]
