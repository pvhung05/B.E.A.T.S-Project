abstract class Producer extends Organism {
    Producer(float x, float y, float energyLevel, float maxEnergy, float optimalDepthMin, float optimalDepthMax) {
        super(x, y, energyLevel, maxEnergy, optimalDepthMin, optimalDepthMax);
    }

    /**
     * Tự hồi phục năng lượng dựa trên các yếu tố môi trường như á sáng
     */
    abstract void photosynthesis();
}