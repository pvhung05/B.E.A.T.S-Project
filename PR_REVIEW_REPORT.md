# PR Review Report

## PR 50 (Core)
- **Status:** **Ready to merge**
- **Review:**
  - Resolved `TODO: @[Core]` at `ECS_Systems.pde:49` regarding reproduction logic. The offspring correctly receives half the parent's energy, which is converted to an energy percentage (`energy.level / energy.max`) matching the payload specification in `EVENT_DICTIONARY.md`.
  - Resolved `TODO: @[Core]` at `ECS_Systems.pde:63`. Schooling logic was refactored, utilizing configuration values via `ConfigLoader` and adopting F=MA physics-based acceleration via `turnRate` and `speed`.
  - Resolved `TODO: @[Core]` at `ECS_Systems.pde:297`. Added the `else` case for wandering state (`target == -1`) with random direction application, and constrained `transform.y` using `UIState.WORLD_HEIGHT`.
  - Resolved `TODO: @[Core]` at `ECS_Systems.pde:323`. Predation logic now properly halves the prey's energy and kills it, removing the constant +10 energy gain, strictly following the specified design.
  - Resolved `TODO: @[Core]` at `Comp_EntityFactory.pde:15`. The `CVelocity(0, 1.5f)` component was added to corpses, allowing them to sink for crabs to consume.
  - Non-blocking execution test (`timeout` with `processing --run`) was successful. The application runs and entity counts log properly without exceptions.

## PR 51 (FX)
- **Status:** **NOT Ready to merge**
- **Review:**
  - The implementation successfully transitions from basic primitive shapes to texture-based image rendering for all entities (`Algae`, `Sardine`, `Shark`, `Crab`, `Corpse`), fulfilling the technical requirements of the role.
  - The integration of images includes scaling transformations to match the underlying `CTransform` data.
  - Background imagery implementation was also added and functions properly within camera scaling logic.
  - Non-blocking execution test (`timeout` with `processing --run`) was successful. The sketch compiles and executes without exceptions.

### Issues to address before merging
- **PR:** #51 (FX)
- **File:** `BEATS/Core_EntityRenderer.pde`
- **Line:** 7
- **Problem:** The developer completed the FX task (drawing entities with images instead of primitive shapes) but forgot to remove the target `// TODO: @[FX]` comment from the codebase.
- **What should have been done instead:** The line `// TODO: @[FX] không vẽ các entity bằng hình đơn giản nữa, nhưng dùng hình ảnh trước (để test api) sau đó là tìm dần mô hình 3d nếu được` should have been deleted to accurately reflect task completion.