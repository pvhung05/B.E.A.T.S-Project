# Ecosystem Stability Report: PR 60 (Balance Tuning)

## Summary
The "Ecosystem Balance Tuning" in PR 60 fails to sustain a stable population for the requested 5-minute (300 simulated seconds) duration. While it implements a promising "Digest Cooldown" mechanic to prevent predatory chain-killing, the underlying species parameters are still too aggressive, leading to an **overpopulation collapse** within the first 60 simulated seconds.

## Test Configuration
- **Branch:** `feature/ecosystem-balance-tuning`
- **Target FrameRate:** 300 FPS (Accelerated testing)
- **Time Unit:** 60 frames = 1 simulated second
- **Duration:** 300 simulated seconds (5 minutes)
- **Collapse Conditions:** 
    - Species Extinction (0 count)
    - Overpopulation (9,500+ entities, near the 10,000 engine hard-cap)

## Test Results
- **Outcome:** **COLLAPSE: Overpopulation**
- **Collapse Time:** Simulated Second 46 (~9.2 real seconds at 300 FPS)
- **Final Population Count:**
    - **Algae:** 5,539
    - **Sardine:** 3,955
    - **Crab:** 54
    - **Shark:** 10
    - **Total:** 9,940 (Engine limit reached)

## Analysis of Failure
The primary drivers of the collapse are the **Algae** and **Sardine** populations:
1. **Low Sardine Metabolism:** PR 60 reduced Sardine metabolism from `0.05` to `0.03`. Combined with an increased `energyGain` (20), Sardines are becoming effectively immortal as long as Algae exists.
2. **Aggressive Reproduction:** The reproduction thresholds for both Algae (80) and Sardines (75) are too low. Once they find food, they multiply exponentially until they hit the engine's hard cap of 10,000 entities. 
3. **Shark Inefficiency:** While Sharks now have a "Digest Cooldown," they cannot keep up with the Sardine explosion. With only 10 Sharks against 4,000 Sardines, the top-down pressure is insufficient.

## Recommendations
To reach the 5-minute balance goal, the following changes are likely required:
- **Increase Reproduction Thresholds:** Raise Algae and Sardine thresholds to `95+` to slow down the population doubling rate.
- **Increase Sardine Metabolism:** Revert or increase metabolism to at least `0.06` to ensure they die off if they over-graze the Algae.
- **Tweak Algae Photosynthesis:** Lower the base photosynthesis rate slightly to prevent Algae from filling all 10,000 entity slots when predation is low.

**Status: NOT Ready to Merge** (Stability target not met)