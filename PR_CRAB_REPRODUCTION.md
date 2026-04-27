## Summary
Fixes the issue where crabs would never reproduce after their initial spawn and would eventually starve to death.

### The Problems
1. **Missing Hunger Threshold:** The `crab.json` file lacked a `hungerThreshold`. This caused the `ConfigLoader` to assign the default threshold of `50%` (50 energy). However, the crab needs `95` energy to reproduce. Since it only hunted when energy was below 50, it could never eat enough to reach the 95 threshold.
2. **Artificial Energy Cap:** `SysPredation` had a hardcoded cap that prevented entities from eating if their energy was `> 80%` of max. This meant crabs (and other entities) could never reach 100% energy.
3. **Empty Corpses:** When an entity was eaten, its energy dropped to `0`. When the corpse was spawned, its energy was based on the dead entity's current energy (capped at a minimum of 10). This meant all corpses only provided 10 energy, which was too little to sustain the crab population.

### The Fixes
- Added `"hungerThreshold": 95` to `crab.json` so crabs actively seek food up until they have enough energy to reproduce.
- Updated `SysPredation` to allow entities to eat until they reach their absolute `max` energy (`energy.level >= energy.max`).
- Updated `Core_EntityManager` so that when an organism dies, the corpse spawns containing the original organism's `max` energy instead of its depleted energy. 

*Tested successfully: Crabs now naturally seek corpses, build up to 95+ energy, and dynamically reproduce throughout the simulation.*