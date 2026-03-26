// EntityFactory.pde
// Loads JSON definitions and spawns concrete entities
// Integrated with PR 33 ConfigLoader and Organism hierarchy

class EntityFactory {
  
  Organism spawn(String species, float x, float y, float initialEnergyPct) {
    species = species.toLowerCase();
    
    // Get maxEnergy from ConfigLoader (PR 33 system)
    float maxEnergy = cfgFloat(species, "energy", "maxEnergy");
    float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;

    if (species.equals("crab")) {
      return new Crab(x, y, currentEnergy);
    } else if (species.equals("algae")) {
      return new Algae(x, y, currentEnergy);
    } else if (species.equals("shark")) {
      return new Shark(x, y, currentEnergy);
    } else if (species.equals("sardine")) {
      return new Sardine(x, y, currentEnergy);
    }
    
    System.err.println("EntityFactory: Unknown species: " + species);
    return null;
  }
}
