# PR Review Report: PR 61 & PR 62

## PR 61 (UI: Remove Duplicate Text)
- **Status:** **Ready to Merge**
- **Review:**
  - This PR removes the hardcoded "Temperature" and "Pollution" labels from the `Slider` constructor in `UI_Submenus.pde`.
  - Static analysis confirms this is a purely visual cleanup. The labels were redundant or overlapping with other UI elements.
  - The code compiles and runs without issues.
  - No architectural or schema violations found.

## PR 62 (FX/UI: 30x30 Fishing Net & Entity Resizing)
- **Status:** **NOT Ready to Merge (Changes Requested)**

### 1. Verification of "Fishing Net" Logic
- The implementation of `catchAllInNet(float x, float y)` in `UI_Controller.pde` is architecturally correct.
- It properly iterates through `world.activeEntities` and uses the `systemBus` to publish `EVENT_ENTITY_DESTROYED` for all entities within the 30x30 box.
- This adheres to the "Decoupled systems using the Event Bus" mandate.

### 2. Issues with Entity Resizing (Critical Logic Failure)
The PR doubles the physical size of entities but fails to scale the biological parameters, creating severe gameplay imbalances:

- **Hitbox vs. Interaction Radii:**
  - In `Comp_EntityFactory.pde`, the Shark's hitbox was increased to **70x30** (half-width = 35).
  - However, in `data/organisms/shark.json`, the `attackRadius` remains at **15**.
  - **Problem:** The attack radius is now *smaller* than the shark's own body. A Sardine could be touching the Shark's skin but remain "out of reach" for the predation logic. An attack would only trigger if the Sardine's center is almost perfectly aligned with the Shark's center.
  
- **Sluggish Movement:**
  - The entities are twice as large, but their `speed` and `turnRate` parameters in the JSON files have not been increased. 
  - **Problem:** The simulation will feel artificially slow/sluggish as organisms cover less of their own body-length per second.

- **Vision Range:**
  - Organisms will now appear closer to each other due to their larger size, but their `visionRadius` remains short. This makes predators feel "blind" despite being visually large.

### Required Actions for PR 62:
1. **Update Organism JSONs:** Proportionally double the `visionRadius`, `attackRadius`, `consumeRadius`, and `speed` for all 4 species in `BEATS/data/organisms/*.json`.
2. **Schooling Logic:** The `schooling.radius` for Sardines should also be doubled to maintain school density.

**Verdict:** PR 61 is safe. PR 62 requires a follow-up to scale the JSON parameters before it can be merged without breaking the simulation mechanics.