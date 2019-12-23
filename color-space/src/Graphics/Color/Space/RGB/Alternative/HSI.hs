{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ViewPatterns #-}
-- |
-- Module      : Graphics.Color.Space.RGB.Alternative.HSI
-- Copyright   : (c) Alexey Kuleshevich 2019
-- License     : BSD3
-- Maintainer  : Alexey Kuleshevich <lehins@yandex.ru>
-- Stability   : experimental
-- Portability : non-portable
--
module Graphics.Color.Space.RGB.Alternative.HSI
  ( pattern ColorHSI
  , pattern ColorHSIA
  , pattern ColorH360SI
  , HSI
  , Color(HSI)
  , module Graphics.Color.Space
  ) where

import Data.Coerce
import Data.Proxy
import Data.Typeable
import Foreign.Storable
import Graphics.Color.Model.Alpha
import qualified Graphics.Color.Model.HSI as CM
import Graphics.Color.Model.Internal
import Graphics.Color.Space


-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
data HSI cs

-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
newtype instance Color (HSI cs) e = HSI (Color CM.HSI e)

-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Eq e => Eq (Color (HSI cs) e)
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Ord e => Ord (Color (HSI cs) e)
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Functor (Color (HSI cs))
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Applicative (Color (HSI cs))
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Foldable (Color (HSI cs))
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Traversable (Color (HSI cs))
-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
deriving instance Storable e => Storable (Color (HSI cs) e)

-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
instance ColorModel cs e => Show (Color (HSI cs) e) where
  showsPrec _ = showsColorModel

-- | Constructor for an RGB color space in an alternative HSI color model
pattern ColorHSI :: e -> e -> e -> Color (HSI cs) e
pattern ColorHSI h s i = HSI (CM.ColorHSI h s i)
{-# COMPLETE ColorHSI #-}

-- | Constructor for @HSI@ with alpha channel.
pattern ColorHSIA :: e -> e -> e -> e -> Color (Alpha (HSI cs)) e
pattern ColorHSIA h s i a = Alpha (HSI (CM.ColorHSI h s i)) a
{-# COMPLETE ColorHSIA #-}


-- | Constructor for an RGB color space in an alternative HSI color model. Difference from
-- `ColorHSI` is that the hue is specified in 0 to 360 degree range, rather than 0 to
-- 1. Note, that this is not checked.
pattern ColorH360SI :: RealFloat e => e -> e -> e -> Color (HSI cs) e
pattern ColorH360SI h s i <- ColorHSI ((* 360) -> h) s i where
        ColorH360SI h s i = ColorHSI (h / 360) s i
{-# COMPLETE ColorH360SI #-}

-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
instance ColorModel cs e => ColorModel (HSI cs) e where
  type Components (HSI cs) e = (e, e, e)
  toComponents = toComponents . coerce
  {-# INLINE toComponents #-}
  fromComponents = coerce . fromComponents
  {-# INLINE fromComponents #-}
  showsColorModelName _ = ("HSI-" ++) . showsColorModelName (Proxy :: Proxy (Color cs e))


-- | `HSI` representation for some (@`RedGreenBlue` cs i@) color space
instance (Typeable cs, ColorSpace cs i e, RedGreenBlue cs i) => ColorSpace (HSI cs) i e where
  type BaseColorSpace (HSI cs) = cs
  toBaseColorSpace = mkColorRGB . fmap fromDouble . CM.hsi2rgb . fmap toDouble . coerce
  {-# INLINE toBaseColorSpace #-}
  fromBaseColorSpace = coerce . fmap fromDouble . CM.rgb2hsi . fmap toDouble . unColorRGB
  {-# INLINE fromBaseColorSpace #-}
