// EntityFactory.pde
// Loads JSON definitions and spawns concrete entities
// Integrated with PR 33 ConfigLoader and Organism hierarchy

class EntityFactory {

    Organism spawn(EntityType species, float x, float y, float initialEnergyPct) {
        // Try to get from pool first
        BaseEntity pooled = world.getFromPool(species);
        
        float maxEnergy = species == EntityType.CORPSE ? initialEnergyPct : cfgFloat(species.name().toLowerCase(), "energy", "maxEnergy");
        float currentEnergy = initialEnergyPct >= 0 ? (species == EntityType.CORPSE ? initialEnergyPct : maxEnergy * initialEnergyPct) : maxEnergy;

        if (pooled != null && pooled instanceof Organism) {
            Organism o = (Organism) pooled;
            o.reinit(x, y, currentEnergy);
            return o;
        }

        // Corpse is not config-driven; energy is passed directly as absolute value
        if (species == EntityType.CORPSE) {
            return new Corpse(x, y, initialEnergyPct);
        }

        switch(species) {
        case ALGAE:
            return new Algae(x, y, currentEnergy);
        case SARDINE:
            return new Sardine(x, y, currentEnergy);
        case SHARK:
            return new Shark(x, y, currentEnergy);
        case CRAB:
            return new Crab(x, y, currentEnergy);
        }

        System.err.println("EntityFactory: Unknown species: " + species);
        return null;
    }
}
