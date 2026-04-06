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

}
