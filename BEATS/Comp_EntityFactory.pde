// EntityFactory.pde
// Loads JSON definitions and spawns concrete entities
// Integrated with PR 33 ConfigLoader and Organism hierarchy

class EntityFactory {
  
  Organism spawn(String species, float x, float y, float initialEnergyPct) {
    species = species.toUpperCase();
    
    // Determine maxEnergy to apply initialEnergyPct
    float maxEnergy = 100.0f; // Default fallback
    
    if (species.equals("CRAB")) maxEnergy = cfgFloat("crab", "energy", "maxEnergy");
    else if (species.equals("ALGAE")) maxEnergy = cfgFloat("algae", "energy", "maxEnergy");
    else if (species.equals("SHARK")) maxEnergy = cfgFloat("shark", "energy", "maxEnergy");
    else if (species.equals("SARDINE")) maxEnergy = cfgFloat("sardine", "energy", "maxEnergy");
    
    float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;

    if (species.equals("CRAB")) {
      return new Crab(x, y, currentEnergy);
    } else if (species.equals("ALGAE")) {
      return new Algae(x, y, currentEnergy);
    } else if (species.equals("SHARK")) {
      return new Shark(x, y, currentEnergy);
    } else if (species.equals("SARDINE")) {
      return new Sardine(x, y, currentEnergy);
    }
    
    System.err.println("EntityFactory: Unknown species: " + species);
    return null;
  }
}
