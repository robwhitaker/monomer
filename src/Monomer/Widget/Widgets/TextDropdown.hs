module Monomer.Widget.Widgets.TextDropdown (
  textDropdown,
  textDropdown_,
  textDropdownV,
  textDropdownV_,
  textDropdownD_
) where

import Control.Lens (ALens')
import Data.Default
import Data.Text (Text)

import Monomer.Widget.Types
import Monomer.Widget.Widgets.Label
import Monomer.Widget.Widgets.Dropdown

textDropdown
  :: (Traversable t, Eq a)
  => ALens' s a
  -> t a
  -> (a -> Text)
  -> WidgetInstance s e
textDropdown field items toText = newInst where
  newInst = textDropdown_ field items toText def

textDropdown_
  :: (Traversable t, Eq a)
  => ALens' s a
  -> t a
  -> (a -> Text)
  -> DropdownCfg s e a
  -> WidgetInstance s e
textDropdown_ field items toText config = newInst where
  newInst = textDropdownD_ (WidgetLens field) items toText config

textDropdownV
  :: (Traversable t, Eq a)
  => a
  -> t a
  -> (a -> Text)
  -> WidgetInstance s e
textDropdownV value items toText = newInst where
  newInst = textDropdownV_ value items toText def

textDropdownV_
  :: (Traversable t, Eq a)
  => a
  -> t a
  -> (a -> Text)
  -> DropdownCfg s e a
  -> WidgetInstance s e
textDropdownV_ value items toText config = newInst where
  newInst = textDropdownD_ (WidgetValue value) items toText config

textDropdownD_
  :: (Traversable t, Eq a)
  => WidgetData s a
  -> t a
  -> (a -> Text)
  -> DropdownCfg s e a
  -> WidgetInstance s e
textDropdownD_ widgetData items toText config = newInst where
  makeMain = toText
  makeRow = label . toText
  newInst = dropdownD_ widgetData items makeMain makeRow config
