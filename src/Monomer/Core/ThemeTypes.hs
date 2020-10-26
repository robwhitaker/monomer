module Monomer.Core.ThemeTypes where

import Control.Applicative ((<|>))
import Data.Default

import Monomer.Core.BasicTypes
import Monomer.Core.StyleTypes
import Monomer.Graphics.Color
import Monomer.Graphics.Types

data Theme = Theme {
  _themeBasic :: ThemeState,
  _themeHover :: ThemeState,
  _themeFocus :: ThemeState,
  _themeDisabled :: ThemeState
} deriving (Eq, Show)

instance Default Theme where
  def = Theme {
    _themeBasic = def,
    _themeHover = def,
    _themeFocus = def,
    _themeDisabled = def
  }

instance Semigroup Theme where
  (<>) t1 t2 = t2

instance Monoid Theme where
  mempty = def

data ThemeState = ThemeState {
  _thsFgColor :: Color,
  _thsHlColor :: Color,
  _thsEmptyOverlayColor :: Color,
  _thsScrollBarColor :: Color,
  _thsScrollThumbColor :: Color,
  _thsScrollWidth :: Double,
  _thsCheckboxColor :: Color,
  _thsCheckboxWidth :: Double,
  _thsRadioColor :: Color,
  _thsRadioWidth :: Double,
  _thsText :: TextStyle,
  _thsBtnStyle :: StyleState,
  _thsBtnMainStyle :: StyleState,
  _thsDialogFrameStyle :: StyleState,
  _thsDialogTitleStyle :: StyleState,
  _thsDialogBodyStyle :: StyleState,
  _thsDialogButtonsStyle :: StyleState
} deriving (Eq, Show)

instance Default ThemeState where
  def = ThemeState {
    _thsFgColor = def,
    _thsHlColor = def,
    _thsEmptyOverlayColor = def,
    _thsScrollBarColor = def,
    _thsScrollThumbColor = def,
    _thsScrollWidth = def,
    _thsCheckboxColor = def,
    _thsCheckboxWidth = def,
    _thsRadioColor = def,
    _thsRadioWidth = def,
    _thsText = def,
    _thsBtnStyle = def,
    _thsBtnMainStyle = def,
    _thsDialogFrameStyle = def,
    _thsDialogTitleStyle = def,
    _thsDialogBodyStyle = def,
    _thsDialogButtonsStyle = def
  }

instance Semigroup ThemeState where
  (<>) ts1 ts2 = ts2

instance Monoid ThemeState where
  mempty = def
