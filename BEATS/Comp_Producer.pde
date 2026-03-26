abstract class Producer extends Organism {
    float photosynthesisRate;

    Producer(float x, float y, float energyLevel, float maxEnergy, float metabolismRate, float reproductionEnergyThreshold, float optimalDepthMin, float optimalDepthMax, float hitboxW, float hitboxH, float photosynthesisRate) {
        super(x, y, energyLevel, maxEnergy, metabolismRate, reproductionEnergyThreshold, optimalDepthMin, optimalDepthMax, hitboxW, hitboxH);
        this.photosynthesisRate = photosynthesisRate;
    }

    /**
     * Recharges energy based on environmental factors like light availability (depth).
     * Use photosynthesisRate to determine energy gain per frame.
     */
    abstract void photosynthesis();
}
