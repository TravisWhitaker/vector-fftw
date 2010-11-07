{- |
This module provides normalized versions of the transforms in @fftw@.

The forwards transforms in this module are identical to those in "Math.FFT.Vector.Unnormalized".
The backwards transforms are normalized to be their inverse operations (approximately, due to floating point precision).

For more information on the underlying transforms, see
<http://www.fftw.org/fftw3_doc/What-FFTW-Really-Computes.html>.
-}
module Math.FFT.Vector.Invertible(
                    -- * Creating and executing 'Plan's
                    run,
                    plan,
                    execute,
                    -- * Complex-to-complex transforms
                    U.dft,
                    idft,
                    -- * Real-to-complex transforms
                    U.dftR2C,
                    dftC2R,
                    -- * Discrete cosine transforms
                    U.dct1,
                    idct1,
                    U.dct2,
                    idct2,
                    U.dct3,
                    idct3,
                    U.dct4,
                    idct4,
                    -- * Discrete sine transforms
                    U.dst1,
                    idst1,
                    U.dst2,
                    idst2,
                    U.dst3,
                    idst3,
                    U.dst4,
                    idst4,
                    ) where

import Math.FFT.Vector.Base
import qualified Math.FFT.Vector.Unnormalized as U
import Data.Complex

-- | A backward discrete Fourier transform which is the inverse of 'U.dft'.  The output and input sizes are the same (@n@).
-- 
-- @y_k = (1\/n) sum_(j=0)^(n-1) x_j e^(2pi i j k/n)@
idft :: Planner (Complex Double) (Complex Double)
idft = U.idft {normalization = \n -> constMultOutput $ 1 / toEnum n}

dftC2R :: Planner (Complex Double) Double
dftC2R = U.dftC2R {normalization = \n -> constMultOutput $ 1 / toEnum n}

-- OK, the inverse of each unnormalized operation.

-- | A type-1 discrete cosine transform which is the inverse of 'U.dct1'.
--
-- @y_k = (1\/(2(n-1)) [x_0 + (-1)^k x_(n-1) + 2 sum_(j=1)^(n-2) x_j cos(pi j k\/(n-1))]@
idct1 :: Planner Double Double
idct1 = U.dct1 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * (n-1))}

-- | A type-3 discrete cosine transform which is the inverse of 'U.dct2'.
-- 
-- @y_k = (1\/(2n)) [x_0 + 2 sum_(j=1)^(n-1) x_j cos(pi j(k+1\/2)\/n)]@
idct2 :: Planner Double Double
idct2 = U.dct3 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

-- | A type-2 discrete cosine transform which is the inverse of 'U.dct3'.
-- 
-- @y_k = (1\/n) sum_(j=0)^(n-1) x_j cos(pi(j+1\/2)k\/n)@
idct3 :: Planner Double Double
idct3 = U.dct2 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

-- | A type-4 discrete cosine transform which is the inverse of 'U.dct4'.
--
-- @y_k = (1\/n) sum_(j=0)^(n-1) x_j cos(pi(j+1\/2)(k+1\/2)\/n)@
idct4 :: Planner Double Double
idct4 = U.dct4 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

-- | A type-1 discrete sine transform which is the inverse of 'U.dst1'.
--
-- @y_k = (1\/(n+1)) sum_(j=0)^(n-1) x_j sin(pi(j+1)(k+1)\/(n+1))@
idst1 :: Planner Double Double
idst1 = U.dst1 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * (n+1))}

-- | A type-3 discrete sine transform which is the inverse of 'U.dst2'.
--
-- @y_k = (1\/(2n)) [(-1)^k x_(n-1) + 2 sum_(j=0)^(n-2) x_j sin(pi(j+1)(k+1\/2)/n)]@
idst2 :: Planner Double Double
idst2 = U.dst3 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

-- | A type-2 discrete sine transform which is the inverse of 'U.dst3'.
--
-- @y_k = (1\/n) sum_(j=0)^(n-1) x_j sin(pi(j+1\/2)(k+1)\/n)@
idst3 :: Planner Double Double
idst3 = U.dst2 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

-- | A type-4 discrete sine transform which is the inverse of 'U.dst4'.
--
-- @y_k = (1\/(2n)) sum_(j=0)^(n-1) x_j sin(pi(j+1\/2)(k+1\/2)\/n)@
idst4 :: Planner Double Double
idst4 = U.dst4 {normalization = \n -> constMultOutput $ 1 / toEnum (2 * n)}

