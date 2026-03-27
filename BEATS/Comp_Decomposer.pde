abstract class Decomposer extends Organism {
    float speed;
    float turnRate;
    float visionRadius;
    float attackRadius;
    float energyGain;

    Decomposer(EntityType type, float x, float y, float energyLevel, float maxEnergy, float metabolismRate, float reproductionEnergyThreshold, float optimalDepthMin, float optimalDepthMax, float hitboxW, float hitboxH, float speed, float turnRate, float visionRadius, float attackRadius, float energyGain) {
        super(type, x, y, energyLevel, maxEnergy, metabolismRate, reproductionEnergyThreshold, optimalDepthMin, optimalDepthMax, hitboxW, hitboxH);
        this.speed = speed;
        this.turnRate = turnRate;
        this.visionRadius = visionRadius;
        this.attackRadius = attackRadius;
        this.energyGain = energyGain;
    }

    /**
     * Searches for a corpse to consume within visionRadius.
     */
    abstract void searchCorpse();

    /**
     * Performs the scavenger action on the specified target organism.
     * Should increase energyLevel by energyGain and drain the corpse.
     *
     * @param target The dead organism to be consumed.
     */
    abstract void consumeCorpse(Organism target);
}
