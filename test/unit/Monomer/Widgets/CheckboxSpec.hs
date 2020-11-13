{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Monomer.Widgets.CheckboxSpec (spec) where

import Control.Lens ((&), (^.), (.~))
import Control.Lens.TH (abbreviatedFields, makeLensesWith)
import Data.Default
import Data.Text (Text)
import Test.Hspec

import qualified Data.Sequence as Seq

import Monomer.Core
import Monomer.Event
import Monomer.TestUtil
import Monomer.Widgets.Checkbox

import qualified Monomer.Lens as L

newtype TestEvt
  = BoolSel Bool
  deriving (Eq, Show)

newtype TestModel = TestModel {
  _tmTestBool :: Bool
} deriving (Eq)

makeLensesWith abbreviatedFields ''TestModel

spec :: Spec
spec = describe "Checkbox" $ do
  handleEvent
  handleEventValue
  updateSizeReq

handleEvent :: Spec
handleEvent = describe "handleEvent" $ do
  it "should not generate an event if clicked outside" $
    clickModel (Point 3000 3000) ^. testBool `shouldBe` False

  it "should generate a user provided event when clicked" $
    clickModel (Point 100 100) ^. testBool `shouldBe` True

  it "should generate a user provided event when Enter/Space is pressed" $
    keyModel keyReturn ^. testBool `shouldBe` True
  where
    wenv = mockWenvEvtUnit (TestModel False)
    chkInst = checkbox testBool
    clickModel p = _weModel wenv2 where
      (wenv2, _, _) = instRunEvent wenv (Click p LeftBtn) chkInst
    keyModel key = _weModel wenv2 where
      (wenv2, _, _) = instRunEvent wenv (KeyAction def key KeyPressed) chkInst

handleEventValue :: Spec
handleEventValue = describe "handleEventValue" $ do
  it "should not generate an event if clicked outside" $
    clickModel (Point 3000 3000) chkInst `shouldBe` Seq.empty

  it "should generate a user provided event when clicked" $
    clickModel (Point 100 100) chkInst `shouldBe` Seq.singleton (BoolSel True)

  it "should generate a user provided event when clicked (set to false)" $
    clickModel (Point 100 100) chkInstT `shouldBe` Seq.singleton (BoolSel False)

  it "should generate a user provided event when Enter/Space is pressed" $
    keyModel keyReturn chkInst `shouldBe` Seq.singleton (BoolSel True)
  where
    wenv = mockWenv (TestModel False)
    chkInst = checkboxV False BoolSel
    chkInstT = checkboxV True BoolSel
    clickModel p inst = evts where
      (_, evts, _) = instRunEvent wenv (Click p LeftBtn) inst
    keyModel key inst = evts where
      (_, evts, _) = instRunEvent wenv (KeyAction def key KeyPressed) inst

updateSizeReq :: Spec
updateSizeReq = describe "updateSizeReq" $ do
  it "should return Fixed width = 20" $
    sizeReqW `shouldBe` FixedSize 20

  it "should return Fixed height = 20" $
    sizeReqH `shouldBe` FixedSize 20

  where
    wenv = mockWenvEvtUnit (TestModel False) & L.theme .~ darkTheme
    (sizeReqW, sizeReqH) = instUpdateSizeReq wenv (checkbox testBool)
