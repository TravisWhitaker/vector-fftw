module Math.FFT.Vector.Plan(
                -- * Planners
                Planner(),
                planOfType,
                PlanType(..),
                plan,
                run,
                -- * Plans
                Plan(),
                planInputSize,
                planOutputSize,
                execute
                ) where

import Math.FFT.Vector.Base