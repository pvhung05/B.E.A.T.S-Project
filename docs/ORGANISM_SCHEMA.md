# Organism Configuration Schema

This document defines the parameters used in the JSON files within `BEATS/data/organisms/`. These files drive the biological logic, movement, and ecological balance of the simulation.

---

## 1. Top-Level Properties

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `name` | String | The unique identifier for the species (e.g., "algae", "shark"). |
| `type` | String | The trophic role: `producer`, `consumer`, or `decomposer`. |

---

## 2. Energy (`energy`)
Defines the metabolic and nutritional properties of the organism.

| Parameter | Type | Role | Description |
| :--- | :--- | :--- | :--- |
| `maxEnergy` | Float | All | The maximum energy capacity. If energy reaches 0, the organism dies. |
| `metabolismRate` | Float | All | The amount of energy consumed per frame to sustain life. |
| `photosynthesisRate`| Float | Producer | Energy gained per frame from light (affected by depth). |
| `hungerThreshold` | Float | Consumer | Energy level below which the organism enters `HUNT` state. |
| `energyGain` | Float | Consumer / Decomposer | Amount of energy recovered after a successful meal. |

---

## 3. Movement (`movement`)
Defines how the organism navigates the 2D world.

| Parameter | Type | Role | Description |
| :--- | :--- | :--- | :--- |
| `canMove` | Boolean | Producer | (Optional) If false, the organism remains stationary. |
| `speed` | Float | All | The base velocity magnitude (pixels per frame). |
| `turnRate` | Float | Consumer / Decomposer | How fast the entity can rotate toward its target (steering). |

---

## 4. Ecology (`ecology`)
Defines environmental tolerances and preferred zones.

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `minDepth` / `maxDepth` | Float | Normalized depth (0.0 = Surface, 1.0 = Bottom) where the species survives optimally. |
| `minWidth` / `maxWidth` | Float | Normalized width (0.0 to 1.0) defining the horizontal territory. |
| `minTemperature` / `maxTemperature` | Float | Temperature range (°C) outside of which the entity suffers metabolic stress. |
| `pollutionTolerance` | Float | Sensitivity to global pollution. Higher values mean better survival in dirty water. |

---

## 5. Feeding (`feeding`)
Specific to predatory and scavenging roles.

| Parameter | Type | Role | Description |
| :--- | :--- | :--- | :--- |
| `food` | Array | Consumer | List of species names this organism can consume. |
| `visionRadius` | Float | Consumer / Decomposer | Detection range for finding food or corpses. |
| `attackRadius` | Float | Consumer | Distance required to "catch" and consume prey. |
| `consumeRadius` | Float | Decomposer | Distance required to scavenger from a corpse. |

---

## 6. Reproduction (`reproduction`)
Defines the population expansion logic.

| Parameter | Type | Description |
| :--- | :--- | :--- |
| `energyThreshold` | Float | The energy level required to trigger reproduction. |
| `spawnRate` | Float | (Optional/Legacy) Probability of spawning a new instance per frame when thresholds are met. |

---
