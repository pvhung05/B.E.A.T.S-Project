// Core_EntityType.pde
// Definition of all entity types in the simulation.
// Used for efficient rendering and logical identification.

enum EntityType {
    ALGAE,
    SARDINE,
    SHARK,
    CRAB,
    CORPSE, // TODO: @[Core] handle logic when shark die
    PARTICLE // TODO: unsure, but in the future might need
}
