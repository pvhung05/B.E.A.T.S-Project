# Ecosystem Evaluation & Tuning Report

## Tuning Process & 5 Consecutive 45-Second Survivals
The simulation initially collapsed within 3-4 seconds due to two main factors:
1. **Crab Starvation Loop:** Crabs spawned with full energy (50), immediately reproduced (threshold 40), and halved their energy (25). With a metabolism of 0.1 per frame (6 per second), they starved and died before any corpses could fall to the ocean floor.
2. **Sardine Over-predation & Algae Extinction:** Sardines had a massive `visionRadius` of 150. 200 sardines immediately swarmed and wiped out the 200 starting algae in seconds. The algae's `photosynthesisRate` and starting population were too low to recover.
3. **Overpopulation and System Limits:** Once algae and sardines were given better growth parameters, they multiplied uncontrollably. Furthermore, dead organisms spawned `CORPSE` entities with a long lifetime, leading to an inflation of inactive entities that easily hit the `10000` (later increased to `15000`) engine hard limit.

### Applied Configurations (Branch: `tune-ecosystem`)
To achieve a stable 45-second run without extinction or overpopulation for **5 consecutive runs**, the following parameters were rigorously tuned to flatten the exponential growth curves:
- **`scenario_01.json`:** Increased initial Algae to 800. Reduced Sardines to 50, Sharks to 5, and increased Crabs to 10.
- **`ECS_Core.pde & BEATS.pde`:** Increased the engine's hard entity limit (`MAX_ENTITIES`) from `10000` to `15000` to account for the corpses and active entities combined.
- **`algae.json`:** Reduced `photosynthesisRate` from 0.15 down to **0.06**, and increased `energyThreshold` to **95**. This drastically slows down their exponential growth cycle.
- **`sardine.json`:** Increased `metabolismRate` to **0.05**, reduced `energyGain` to **15**, and increased `energyThreshold` to **95**. This forces them to consume more algae to reproduce, halting their explosive population boom.
- **`shark.json`:** Increased `speed` to **5.0** and `turnRate` to **0.2** (to better catch fast sardines). Reduced `energyGain` to **30** and increased `energyThreshold` to **140** (to sustain their population and keep sardines in check without them exploding).
- **`crab.json`:** Increased `maxEnergy` to **100**, lowered `metabolismRate` to **0.02**, lowered `energyGain` to **15**, and raised `energyThreshold` to **95** (prevents instant starvation and limits explosive scavenging).

*Result: The ecosystem fluctuated dynamically and successfully survived the 45-second test 5 times consecutively. Peak active entities (including corpses) varied between ~2,500 and ~11,000, always stabilizing without hitting the 15,000 engine limit or going extinct.*

---

## Missing Features & Behaviors to Implement
Based on the current project schema (`docs/ORGANISM_SCHEMA.md`), `GEMINI.md`, and the tested PR 50 behavior, the following features are missing to fully represent all 4 species:

### 1. Global Environmental Physics (Tier 3)
Currently, `Module_Logic.processEnvironmentalDeltas()` is unhandled.
- **Temperature & Pollution:** The parameters `minTemperature`, `maxTemperature`, and `pollutionTolerance` inside the `CEcology` component are loaded but have **no effect** on metabolism or survival. Changes in global temperature/pollution should inflict metabolic stress on entities outside their optimal zones.
- **Depth Constraints:** The `minDepth` and `maxDepth` parameters in `CEcology` are ignored. While Algae utilizes depth for photosynthesis, mobile species (Sardines, Sharks) freely roam the entire Y-axis instead of staying within their preferred horizontal bands.

### 2. Crab Movement & Depth (Decomposer Logic)
Crabs currently float around like fish, utilizing standard `CVelocity` and `CSteering` wandering. 
- Crabs (`minDepth`: 0.75 - 1.0) should naturally seek or sink to the ocean floor. PR 50 only added gravity to `CORPSE`. Crabs need a steering behavior that clamps them to the bottom or applies gravity.

### 3. Fleeing Steering Dynamics (F=MA)
While PR 50 correctly updated the Sardine Schooling behavior to use physics-based acceleration (adding to velocity via `turnRate` instead of overriding it), the **Fleeing** behavior inside `SysSteering.updateSardineSteering` was left untouched.
- Currently, `velocity.vx = (fleeX / fLen) * steering.speed;` directly overwrites the velocity vector. This causes aggressive snapping, jitter, and conflicts with boundary reflections when fleeing from Sharks. Fleeing must be refactored to use `turnRate` like the schooling logic.

### 4. Proper AI State Machine Transitions
`GEMINI.md` lists AI State Machine transitions as *Untouched*.
- Currently, states (`CRUISE`, `HUNT`, `FLEE`) are strictly evaluated via a massive top-down `if-else` block every frame based on nearby entities. There is no actual state retention, transition smoothing, or cooldowns (e.g., a shark dropping a chase if prey leaves vision, or a sardine recovering from a flee state over time).