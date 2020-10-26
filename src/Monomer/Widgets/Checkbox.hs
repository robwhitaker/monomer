{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Monomer.Widgets.Checkbox (
  CheckboxCfg,
  checkbox,
  checkbox_,
  checkboxV,
  checkboxV_,
  checkboxD_,
  checkboxWidth
) where

import Control.Applicative ((<|>))
import Control.Lens (ALens', (&), (^.), (.~))
import Control.Monad
import Data.Default
import Data.Maybe
import Data.Text (Text)

import Monomer.Widgets.Single

import qualified Monomer.Lens as L

data CheckboxCfg s e = CheckboxCfg {
  _ckcWidth :: Maybe Double,
  _ckcOnChange :: [Bool -> e],
  _ckcOnChangeReq :: [WidgetRequest s]
}

instance Default (CheckboxCfg s e) where
  def = CheckboxCfg {
    _ckcWidth = Nothing,
    _ckcOnChange = [],
    _ckcOnChangeReq = []
  }

instance Semigroup (CheckboxCfg s e) where
  (<>) t1 t2 = CheckboxCfg {
    _ckcWidth = _ckcWidth t2 <|> _ckcWidth t1,
    _ckcOnChange = _ckcOnChange t1 <> _ckcOnChange t2,
    _ckcOnChangeReq = _ckcOnChangeReq t1 <> _ckcOnChangeReq t2
  }

instance Monoid (CheckboxCfg s e) where
  mempty = def

instance OnChange (CheckboxCfg s e) Bool e where
  onChange fn = def {
    _ckcOnChange = [fn]
  }

instance OnChangeReq (CheckboxCfg s e) s where
  onChangeReq req = def {
    _ckcOnChangeReq = [req]
  }

checkboxWidth :: Double -> CheckboxCfg s e
checkboxWidth w = def {
  _ckcWidth = Just w
}

checkbox :: ALens' s Bool -> WidgetInstance s e
checkbox field = checkbox_ field def

checkbox_ :: ALens' s Bool -> [CheckboxCfg s e] -> WidgetInstance s e
checkbox_ field config = checkboxD_ (WidgetLens field) config

checkboxV :: Bool -> (Bool -> e) -> WidgetInstance s e
checkboxV value handler = checkboxV_ value handler def

checkboxV_ :: Bool -> (Bool -> e) -> [CheckboxCfg s e] -> WidgetInstance s e
checkboxV_ value handler config = checkboxD_ (WidgetValue value) newConfig where
  newConfig = onChange handler : config

checkboxD_ :: WidgetData s Bool -> [CheckboxCfg s e] -> WidgetInstance s e
checkboxD_ widgetData configs = checkboxInstance where
  config = mconcat configs
  widget = makeCheckbox widgetData config
  checkboxInstance = (defaultWidgetInstance "checkbox" widget) {
    _wiFocusable = True
  }

makeCheckbox :: WidgetData s Bool -> CheckboxCfg s e -> Widget s e
makeCheckbox widgetData config = widget where
  widget = createSingle def {
    singleGetBaseStyle = getBaseStyle,
    singleHandleEvent = handleEvent,
    singleGetSizeReq = getSizeReq,
    singleRender = render
  }

  getBaseStyle wenv inst = Just style where
    style = copyThemeField wenv def L.fgColor L.checkboxColor

  handleEvent wenv target evt inst = case evt of
    Click (Point x y) _ -> Just $ resultReqsEvents clickReqs events inst
    KeyAction mod code KeyPressed
      | isSelectKey code -> Just $ resultReqsEvents reqs events inst
    _ -> Nothing
    where
      isSelectKey code = isKeyReturn code || isKeySpace code
      model = _weModel wenv
      value = widgetDataGet model widgetData
      newValue = not value
      events = fmap ($ newValue) (_ckcOnChange config)
      setValueReq = widgetDataSet widgetData newValue
      setFocusReq = SetFocus $ _wiPath inst
      reqs = setValueReq ++ _ckcOnChangeReq config
      clickReqs = setFocusReq : reqs

  getSizeReq wenv inst = req where
    theme = activeTheme wenv inst
    width = fromMaybe (theme ^. L.checkboxWidth) (_ckcWidth config)
    req = (FixedSize width, FixedSize width)

  render renderer wenv inst = do
    renderCheckbox renderer checkboxBW checkboxArea fgColor

    when value $
      renderMark renderer checkboxBW checkboxArea fgColor
    where
      model = _weModel wenv
      theme = activeTheme wenv inst
      style = activeStyle wenv inst
      value = widgetDataGet model widgetData
      rarea = removeOuterBounds style $ _wiRenderArea inst
      checkboxW = fromMaybe (theme ^. L.checkboxWidth) (_ckcWidth config)
      checkboxBW = max 1 (checkboxW * 0.1)
      checkboxL = _rX rarea + (_rW rarea - checkboxW) / 2
      checkboxT = _rY rarea + (_rH rarea - checkboxW) / 2
      checkboxArea = Rect checkboxL checkboxT checkboxW checkboxW
      fgColor = styleFgColor style

renderCheckbox :: Renderer -> Double -> Rect -> Color -> IO ()
renderCheckbox renderer checkboxBW rect color = action where
  side = Just $ BorderSide checkboxBW color
  border = Border side side side side
  action = drawRectBorder renderer rect border Nothing

renderMark :: Renderer -> Double -> Rect -> Color -> IO ()
renderMark renderer checkboxBW rect color = action where
  w = checkboxBW * 2
  newRect = subtractFromRect rect w w w w
  action = drawRect renderer newRect (Just color) Nothing
