
abstract class Organism extends BaseEntity {
  float energyLevel;
  float maxEnergy;
  float metabolismRate;
  float reproductionEnergyThreshold;
  float optimalDepthMin, optimalDepthMax;
  float hitboxW, hitboxH;

  Organism(float x, float y, float energyLevel, float maxEnergy, float metabolismRate, float reproductionEnergyThreshold, float optimalDepthMin, float optimalDepthMax, float width, float height)
  {
    super(x,y);
    this.energyLevel = energyLevel;
    this.maxEnergy = maxEnergy;
    this.metabolismRate = metabolismRate;
    this.reproductionEnergyThreshold = reproductionEnergyThreshold;
    this.optimalDepthMin = optimalDepthMin;
    this.optimalDepthMax = optimalDepthMax;
    this.hitboxW = width;
    this.hitboxH = height;
  }

  void updateBiologicalState() {
    energyLevel -= metabolismRate;
    if (energyLevel <= 0) dead = true;
    checkReproduction();

    // TODO: @[Architect]: write check depth tolerance function to generally affect species that move out of its bound.
  }

  void checkReproduction() {
    // TODO: implement reproduction logic based on energy level.
    // When energyLevel >= reproductionEnergyThreshold, spawn a new instance of the same species.
  }


  // what this organism specifically eat
  abstract boolean canConsume(Organism target);

  // check if the mouse click is within the organism's bounding box
  public boolean isSelected(float mx, float my) {
    float left = x - hitboxW / 2;
    float right = x + hitboxW / 2;
    float bottom = y + hitboxH / 2;
    float top = y - hitboxH / 2;
    return (mx >= left && mx <= right && my >= top && my <= bottom);
  }

  // Boundary AI to keep organisms within the environment bounds
  void applyBoundaryAI(float worldWidth, float worldHeight) {
    x += velocityX;
    y += velocityY;

    if (x < 0) {
        x = 0;
        velocityX *= -1;
    } else if (x > worldWidth) {
        x = worldWidth;
        velocityX *= -1;
    }
    if (y < 0) {
        y = 0;
        velocityY *= -1;
    } else if (y > worldHeight) {
        y = worldHeight;
        velocityY *= -1;
    }
  }
}
