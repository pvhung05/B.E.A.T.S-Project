// EntityFactory.pde
// Loads JSON definitions and spawns concrete entities
// Integrated with PR 33 ConfigLoader and Organism hierarchy

class EntityFactory {

    Organism spawn(EntityType species, float x, float y, float initialEnergyPct) {
        // species = species.toLowerCase();

        // Get maxEnergy from ConfigLoader (PR 33 system)
        float maxEnergy = cfgFloat(species.name(), "energy", "maxEnergy");
        float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;

        // if (species.equals("crab")) {
        //
        // } else if (species.equals("algae")) {
        //
        // } else if (species.equals("shark")) {
        //
        // } else if (species.equals("sardine")) {
        //
        // }
        switch(species) {
        case ALGAE:
            return new Algae(x, y, currentEnergy);
        case SARDINE:
            return new Sardine(x, y, currentEnergy);
        case SHARK:
            return new Shark(x, y, currentEnergy);
        case CRAB:
            return new Crab(x, y, currentEnergy);
        } // TODO: @[Core] May need to handle spawn corpse?

        System.err.println("EntityFactory: Unknown species: " + species);
        return null;
    }
}
