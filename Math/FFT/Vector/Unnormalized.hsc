{- |
Raw, unnormalized versions of the transforms in @fftw@.

Note that the forwards and backwards transforms of this module are not actually
inverses.  For example, @run idft (run dft v) /= v@ in general.

For more information on the individual transforms, see
<http://www.fftw.org/fftw3_doc/What-FFTW-Really-Computes.html>.
-}
module Math.FFT.Vector.Unnormalized(
                    -- * Creating and executing 'Plan's
                    run,
                    plan,
                    execute,
                    -- * Complex-to-complex transforms
                    dft,
                    idft,
                    -- * Real-to-complex transforms
                    dftC2R,
                    dftR2C,
                    -- * Real-to-real transforms
                    -- $dct_size
                    -- ** Discrete cosine transforms
                    dct1,
                    dct2,
                    dct3,
                    dct4,
                    -- ** Discrete sine transforms
                    dst1,
                    dst2,
                    dst3,
                    dst4,
                    ) where

import Math.FFT.Vector.Base
import Foreign
import Foreign.C
import Data.Complex

#include <fftw3.h>

-- | Whether the complex fft is forwards or backwards.
type CDirection = CInt

-- | The type of the cosine or sine transform.
type CKind = (#type fftw_r2r_kind)

foreign import ccall unsafe fftw_plan_dft_1d
    :: CInt -> Ptr (Complex Double) -> Ptr (Complex Double) -> CDirection
        -> CFlags -> IO (Ptr CPlan)

foreign import ccall unsafe fftw_plan_dft_r2c_1d
    :: CInt -> Ptr Double -> Ptr (Complex Double) -> CFlags -> IO (Ptr CPlan)

foreign import ccall unsafe fftw_plan_dft_c2r_1d
    :: CInt -> Ptr (Complex Double) -> Ptr Double -> CFlags -> IO (Ptr CPlan)

foreign import ccall unsafe fftw_plan_r2r_1d
    :: CInt -> Ptr Double -> Ptr Double -> CKind -> CFlags -> IO (Ptr CPlan)

dft1D :: CDirection -> Planner (Complex Double) (Complex Double)
dft1D d = Planner {
            inputSize = id,
            outputSize = id,
            creationSizeFromInput = id,
            makePlan = \n a b -> fftw_plan_dft_1d n a b d,
            normalization = const id
            }

-- | A forward discrete Fourier transform.  The output and input sizes are the same (@n@).
-- 
-- @y_k = sum_(j=0)^(n-1) x_j e^(-2pi i j k/n)@
dft :: Planner (Complex Double) (Complex Double)
dft = dft1D (#const FFTW_FORWARD)

-- | A backward discrete Fourier transform.  The output and input sizes are the same (@n@).
-- 
-- @y_k = sum_(j=0)^(n-1) x_j e^(2pi i j k/n)@
idft :: Planner (Complex Double) (Complex Double)
idft = dft1D (#const FFTW_BACKWARD)

dftR2C :: Planner Double (Complex Double)
dftR2C = Planner {
            inputSize = id,
            outputSize = \n -> n `div` 2 + 1,
            creationSizeFromInput = id,
            makePlan = fftw_plan_dft_r2c_1d,
            normalization = const id
        }

dftC2R :: Planner (Complex Double) Double
dftC2R = Planner {
            inputSize = \n -> n `div` 2 + 1,
            outputSize = id,
            creationSizeFromInput = \n -> 2 * (n-1),
            makePlan = fftw_plan_dft_c2r_1d,
            normalization = const id
        }

r2rPlanner :: CKind -> Planner Double Double
r2rPlanner kind = Planner {
                    inputSize = id,
                    outputSize = id,
                    creationSizeFromInput = id,
                    makePlan = \n a b -> fftw_plan_r2r_1d n a b kind,
                    normalization = const id
                }

-- $dct_size
-- The real-even (DCT) and real-odd (DST) transforms.  The input and output sizes
-- are the same (@n@).

-- | A type-1 discrete cosine transform.  
--
-- @y_k = x_0 + (-1)^k x_(n-1) + 2 sum_(j=1)^(n-2) x_j cos(pi j k\/(n-1))@
dct1 :: Planner Double Double
dct1 = r2rPlanner (#const  FFTW_REDFT00)

-- | A type-2 discrete cosine transform.  
--
-- @y_k = 2 sum_(j=0)^(n-1) x_j cos(pi(j+1\/2)k\/n)@
dct2 :: Planner Double Double
dct2 = r2rPlanner (#const  FFTW_REDFT10)

-- | A type-3 discrete cosine transform.  
--
-- @y_k = x_0 + 2 sum_(j=1)^(n-1) x_j cos(pi j(k+1\/2)\/n)@
dct3 :: Planner Double Double
dct3 = r2rPlanner (#const  FFTW_REDFT01)

-- | A type-4 discrete cosine transform.  
--
-- @y_k = 2 sum_(j=0)^(n-1) x_j cos(pi(j+1\/2)(k+1\/2)\/n)@
dct4 :: Planner Double Double
dct4 = r2rPlanner (#const  FFTW_REDFT11)

-- | A type-1 discrete sine transform.
-- 
-- @y_k = 2 sum_(j=0)^(n-1) x_j sin(pi(j+1)(k+1)\/(n+1))@
dst1 :: Planner Double Double
dst1 = r2rPlanner (#const  FFTW_RODFT00)

-- | A type-2 discrete sine transform.
-- 
-- @y_k = 2 sum_(j=0)^(n-1) x_j sin(pi(j+1\/2)(k+1)\/n)@
dst2 :: Planner Double Double
dst2 = r2rPlanner (#const  FFTW_RODFT10)

-- | A type-3 discrete sine transform.  
--
-- @y_k = (-1)^k x_(n-1) + 2 sum_(j=0)^(n-2) x_j sin(pi(j+1)(k+1\/2)/n)@
dst3 :: Planner Double Double
dst3 = r2rPlanner (#const  FFTW_RODFT01)

-- | A type-4 discrete sine transform.
--
-- @y_k = sum_(j=0)^(n-1) x_j sin(pi(j+1\/2)(k+1\/2)\/n)@
dst4 :: Planner Double Double
dst4 = r2rPlanner (#const FFTW_RODFT11)
