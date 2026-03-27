enum State {
    CRUISE,
        HUNT
}

abstract class Consumer extends Organism {
    float hungerThreshold;
    float energyGain;
    float speed;
    float turnRate;
    float visionRadius;
    float attackRadius;

    State state;
    Organism currentTarget;

    Consumer(EntityType type, float x, float y, float energyLevel, float maxEnergy, float metabolismRate, float reproductionEnergyThreshold, float optimalDepthMin, float optimalDepthMax, float hitboxW, float hitboxH, float hungerThreshold, float energyGain, float speed, float turnRate, float visionRadius, float attackRadius) {
        super(type, x, y, energyLevel, maxEnergy, metabolismRate, reproductionEnergyThreshold, optimalDepthMin, optimalDepthMax, hitboxW, hitboxH);

        this.hungerThreshold = hungerThreshold;
        this.energyGain = energyGain;
        this.speed = speed;
        this.turnRate = turnRate;
        this.visionRadius = visionRadius;
        this.attackRadius = attackRadius;
        this.state = State.CRUISE;
    }

    /**
     * Searches the given list for the nearest valid prey within visionRadius.
     * Returns null if no target found.
     */
    Organism searchFood(java.util.List<Organism> organisms) {
        // FIXME: @[Core] this may create a ClassCast exception later on if you use pass entity list of world to this
        Organism closest = null;
        float closestDist = visionRadius;
        for (Organism o : organisms) {
            if (o == this || o.isDead()) continue;
            if (!canConsume(o)) continue;
            float d = dist(x, y, o.x, o.y);
            if (d < closestDist) {
                closestDist = d;
                closest = o;
            }
        }
        return closest;
    }

    abstract void hunt();

    abstract void cruise();
}

