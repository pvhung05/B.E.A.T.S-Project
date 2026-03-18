
abstract class Organism extends BaseEntity {
  float energyLevel;
  float maxEnergy;
  float optimalDepthMin, optimalDepthMax;

  Organism(float x, float y, float energyLevel, float maxEnergy, float optimalDepthMin, float optimalDepthMax)
  {
    super(x,y);
    this.energyLevel = energyLevel;
    this.maxEnergy = maxEnergy;
    this.optimalDepthMin = optimalDepthMin;
    this.optimalDepthMax = optimalDepthMax;
  }

  void updateBiologicalState() {
    energyLevel -= 0.1;
    if (energyLevel <= 0) dead = true;

    // TODO: @[Architect]: write check depth tolerance function to generally affect species that move out of its bound.
  }

  // what this organism specifically eat
  abstract boolean canConsume(Organism target);
}