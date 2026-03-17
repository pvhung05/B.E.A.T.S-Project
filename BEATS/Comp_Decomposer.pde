abstract class Decomposer extends Organism {
    Decomposer(float x, float y, float energyLevel, float maxEnergy, float optimalDepthMin, float optimalDepthMax) {
        super(x, y, energyLevel, maxEnergy, optimalDepthMin, optimalDepthMax);
    }

    /**
     * Searches for a corpse to consume.
     */
    abstract void searchCorpse();

    /**
     * Performs the scavenger action on the specified target organism.
     *
     * @param target The organism to be scavenged.
     */
    abstract void consumeCorpse(Organism target);
}
