## Summary
Fixes several outstanding core logic issues introduced or left over from recent merges.

### 1. Snappy Movement Fixed
- Replaced the direct linear interpolation (Lerp) steering logic with a proper Reynolds steering force model (`applySteeringForce`). `turnRate` now acts as the maximum absolute force applied per frame. Velocity shifts gradually, simulating inertia and eliminating the jerky movement of Sharks and Sardines.

### 2. Disappearing Corpses Fixed
- Increased initial corpse lifetime from 300 frames (5 seconds) to 3000 frames (50 seconds) in `Comp_EntityFactory`. This ensures corpses have enough time to sink to the ocean floor and be consumed by crabs before decaying completely.

### 3. Scalable Corpse Dropping (ECS)
- Introduced a new `CMeat` component. SARDINE, SHARK, and CRAB receive this tag upon spawning. `Core_EntityManager` now strictly checks for the presence of `CMeat` before dropping a corpse. This prevents ALGAE from dropping corpses and keeps the ECS architecture clean and scalable without relying on hardcoded species checks.