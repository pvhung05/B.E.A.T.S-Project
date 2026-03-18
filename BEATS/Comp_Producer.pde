abstract class Producer extends Organism {
    Producer(float x, float y, float energyLevel, float maxEnergy, float optimalDepthMin, float optimalDepthMax) {
        super(x, y, energyLevel, maxEnergy, optimalDepthMin, optimalDepthMax);
    }

    /**
     * Recharges energy based on environmental factors like light availability (depth).
     */
    abstract void photosynthesis();
}
