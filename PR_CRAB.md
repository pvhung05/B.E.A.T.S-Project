## Summary
Fixes the issue where crabs were starving to death despite the abundance of corpses.

### The Problem
Previously, crabs were programmed to wander within their vertical `minDepth` ecology zone (which started around 75% depth). If a crab was swimming at exactly 75% depth, its `wanderTargetVy` was set to 0. Because crabs only have a vertical `visionRadius` of 70 pixels, they were often swimming too high above the literal ocean floor (100% depth) to "see" the sinking corpses that had settled at the bottom. Furthermore, when they did hit the floor, they bounced back up due to collision logic.

### The Fix
- `SysMovement` was updated so crabs' `velocity.vy` becomes 0 when they hit the floor, stopping the bouncing effect.
- `updateCrabSteering` in `SysSteering` was updated so that crabs now seek the *absolute bottom* (`UIState.WORLD_HEIGHT - 5`) instead of just their starting `minDepth`. Once at the absolute bottom, they exclusively wander horizontally, placing them in perfect alignment to intercept sinking corpses.