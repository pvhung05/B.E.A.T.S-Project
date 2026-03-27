
abstract class Organism extends BaseEntity {
    float energyLevel;
    float maxEnergy;
    float metabolismRate;
    float reproductionEnergyThreshold;
    float optimalDepthMin, optimalDepthMax;
    float hitboxW, hitboxH; 
    // TODO: @[Core] forgot to assign lifetime (int type suggested, decrease each frame), if not literally no corpse for crab to eat
    // float yAngle;? 
    // TODO: @[FX] @[Core] might need that yAngle in MMP with 3D model of entities (just spin when turn around)
    /**
    the expected behavior 
    */

    Organism(EntityType type, float x, float y, float energyLevel, float maxEnergy, float metabolismRate, float reproductionEnergyThreshold, float optimalDepthMin, float optimalDepthMax, float width, float height)
    {
        super(type, x, y);
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
    }

    boolean isOutOfBound()
    {
        return y < this.optimalDepthMin || y > this.optimalDepthMax;
    }

    void checkReproduction() {
        if (energyLevel >= reproductionEnergyThreshold) {
            // Split energy
            energyLevel *= 0.5f;

            // Spawn offspring nearby with a slight offset
            String speciesName = this.getClass().getSimpleName().toUpperCase();
            systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                speciesName,
                x + random(-10, 10),
                y + random(-10, 10),
                0.5f // Offspring starts with 50% energy
                });
        }
    }


    // what this organism specifically eat
    abstract boolean canConsume(Organism target);

    // check if the mouse click is within the organism's bounding box
    boolean isSelected(float mx, float my) {
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
