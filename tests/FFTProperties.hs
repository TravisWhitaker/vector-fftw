{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
-- This module uses the test-framework-quickcheck2 package.
module Main where

import qualified Data.Vector.Unboxed as V
import Data.Complex

import Test.Framework (defaultMain, testGroup)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck

import qualified Numeric.FFT.Vector.Invertible as I
import qualified Numeric.FFT.Vector.Unitary as U
import Numeric.FFT.Vector.Plan

main = defaultMain
            -- NB: There's no explicit tests for the Unnormalized package.
            -- However, its Planners are implicitly used by the other modules,
            -- so it's covered in the below tests.
            [ testGroup "invertibility"
              [ testProperty "I.dft" $ prop_invert I.dft I.idft
              , testProperty "I.dftR2C" $ prop_invert I.dftR2C I.dftC2R
              , testProperty "I.dct1" $ prop_invert I.dct1 I.idct1
              , testProperty "I.dct2" $ prop_invert I.dct2 I.idct2
              , testProperty "I.dct3" $ prop_invert I.dct3 I.idct3
              , testProperty "I.dct4" $ prop_invert I.dct4 I.idct4
              , testProperty "I.dst1" $ prop_invert I.dst1 I.idst1
              , testProperty "I.dst2" $ prop_invert I.dst2 I.idst2
              , testProperty "I.dst3" $ prop_invert I.dst3 I.idst3
              , testProperty "I.dst4" $ prop_invert I.dst4 I.idst4
              , testProperty "U.dft" $ prop_invert U.dft U.idft
              , testProperty "U.dftR2C" $ prop_invert U.dftR2C U.dftC2R
              , testProperty "U.dct2" $ prop_invert U.dct2 U.idct2
              ]
            , testGroup "orthogonality"
              [ testProperty "U.dft" $ prop_orthog U.dft
              , testProperty "U.idft" $ prop_orthog U.idft
              , testProperty "U.dftR2C" $ prop_orthog U.dftR2C
              , testProperty "U.dftC2R" $ prop_orthog U.dftR2C
              , testProperty "U.dct2" $ prop_orthog U.dct2
              , testProperty "U.idct2" $ prop_orthog U.idct2
              , testProperty "U.dct4" $ prop_orthog U.dct4
              ]
            ]

-------------------
-- An instance of Arbitrary that probably belongs in another package.

instance (V.Unbox a, Arbitrary a) => Arbitrary (V.Vector a) where
    arbitrary = V.fromList `fmap` arbitrary


-------------------------
-- Support functions to compare Doubles for (near) equality.

class Num a => Mag a where
    mag :: a -> Double

instance Mag Double where
    mag = abs

instance Mag (Complex Double) where
    mag = magnitude

-- Robustly test whether two Doubles are nearly identical.
close :: Mag a => a -> a -> Bool
close x y = tol > mag (x-y) / max 1 (mag x + mag y)
  where
    tol = 1e-10

withinTol :: (Mag a, V.Unbox a) => V.Vector a -> V.Vector a -> Bool
withinTol a b
    | V.length a /= V.length b = False
    | otherwise = V.and $ V.zipWith close a b


---------------------
-- The actual properties

-- Test whether the inverse actually inverts the forward transform.
prop_invert f g a = let
                        p1 = plan f (V.length a)
                        p2 = plan g (V.length a)
                    in (V.length a > 1) ==> withinTol a $ execute p2 $ execute p1 a

-- Test whether the transform preserves the L2 (sum-of-squares) norm.
prop_orthog f a = let
                    p1 = plan f (V.length a)
                  in (V.length a > 1) ==> close (norm2 a) (norm2 $ execute p1 a)

norm2 a = sqrt $ V.sum $ V.map (\x -> x*x) $ V.map mag a
