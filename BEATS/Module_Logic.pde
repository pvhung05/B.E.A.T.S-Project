// Module_Logic.pde
// Tier 3: Global Physics & Relationship Engine
// This module handles cross-entity interactions and global environmental influences.

class Logic {

  Logic() {}

  /**
   * Main entry point for Tier 2 (Interaction) and Tier 3 (Global) logic.
   * Processes how entities relate to each other and the world.
   */
  void processRules(ArrayList<IObject> entities, QuadTree spatialTree) {
    if (spatialTree == null) return;

    for (int i = 0; i < entities.size(); i++) {
      IObject obj = entities.get(i);
      if (!(obj instanceof Organism) || obj.isDead()) continue;
      Organism organism = (Organism) obj;

      // Tier 3: Global Environmental Deltas
      processEnvironmentalDeltas(organism);

      // Tier 2: Relationship Processing (Predation/Feeding)
      processRelationships(organism, spatialTree);
    }
  }

  /**
   * Tier 3: Environmental Deltas
   * Calculates how global sliders (Temperature, Pollution) affect the organism.
   */
  private void processEnvironmentalDeltas(Organism o) {
    // 1. Temperature Stress
    // If temperature is outside the species-specific optimal range, increase metabolic decay
    if (UIState.temperature < o.optimalDepthMin * 100 || UIState.temperature > o.optimalDepthMax * 100) {
        // Simple linear stress for now: 1.5x metabolism if uncomfortable
        o.energyLevel -= o.metabolismRate * 0.5f;
    }

    // 2. Pollution Stress
    // Global pollution directly drains energy based on a threshold
    if (UIState.pollution > UIState.POLLUTION_STRESS_THRESHOLD) {
        float pollutionStress = (UIState.pollution - UIState.POLLUTION_STRESS_THRESHOLD) * 0.01f;
        o.energyLevel -= pollutionStress;
    }
    
    // 3. Depth-to-Light mapping (Producer logic handled here centrally)
    if (o instanceof Producer) {
        Producer p = (Producer) o;
        float depthFactor = 1.0f - (p.y / UIState.WORLD_HEIGHT);
        // Bonus or penalty based on global light availability
        p.energyLevel += p.photosynthesisRate * depthFactor * 0.1f;
    }
  }

  /**
   * Tier 2: Relationship Processing
   * Uses spatial partitioning to handle interactions like hunting and eating.
   */
  private void processRelationships(Organism o, QuadTree spatialTree) {
    // Optimization: Skip interaction check if organism is satisfied (above 80% energy)
    if (o.energyLevel > o.maxEnergy * 0.8f) return;

    float searchRadius = 0;
    if (o instanceof Consumer) {
        searchRadius = ((Consumer)o).visionRadius;
    } else if (o instanceof Decomposer) {
        searchRadius = ((Decomposer)o).visionRadius;
    }
    
    if (searchRadius <= 0) return;

    // Use QuadTree for O(log N) neighbor search
    ArrayList<IObject> neighbors = new ArrayList<IObject>();
    spatialTree.query(o.x, o.y, searchRadius, neighbors);

    for (IObject neighborObj : neighbors) {
      if (!(neighborObj instanceof Organism) || neighborObj == o || neighborObj.isDead()) continue;
      Organism target = (Organism) neighborObj;

      // Predation/Feeding Logic
      if (o.canConsume(target)) {
          float d = dist(o.x, o.y, target.x, target.y);
          
          float attackRadius = 15; // Default fallback
          if (o instanceof Consumer) attackRadius = ((Consumer)o).attackRadius;
          if (o instanceof Decomposer) attackRadius = ((Decomposer)o).attackRadius;

          if (d < attackRadius) {
              handleConsumption(o, target);
              break; // One meal per frame
          }
      }
    }
  }

  /**
   * Logic for transferring energy between entities.
   */
  private void handleConsumption(Organism predator, Organism prey) {
      float energyGain = 0;
      
      if (predator instanceof Consumer) {
          energyGain = ((Consumer)predator).energyGain;
          prey.dead = true; // Consumers kill prey
      } else if (predator instanceof Decomposer) {
          energyGain = ((Decomposer)predator).energyGain;
          // Decomposers eat dead tissue, so they don't 'kill', 
          // but we might drain the corpse energy here.
          prey.energyLevel -= energyGain;
          if (prey.energyLevel <= 0) prey.dead = true;
      }
      
      predator.energyLevel = min(predator.maxEnergy, predator.energyLevel + energyGain);
      
      // Notify FX system of a successful hunt/feed
      systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{
          prey.getClass().getSimpleName().toUpperCase(), 
          prey.x, 
          prey.y, 
          "CONSUMED"
      });
  }
}
