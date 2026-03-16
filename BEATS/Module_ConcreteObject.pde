// Module_ConcreteObject.pde
// Where all the final classes are defined



final class Crab extends Decomposer {  
    @Override
    void update() {
        if (isDead()) return;

        updateBiologicalState();

        // TODO: implement movement logic for crab (e.g., random walk, or move towards food if detected).
    }

    @Override
    void render() {
        if (isDead()) return;
        // TODO: implement rendering logic for crab (e.g., draw a simple shape representing the crab).
    }

    @Override
    boolean isSelected(float mx, float my) {
        return false; 
        // TODO: implement selection logic based on mouse coordinates.
    }

    @Override
    boolean canConsume(Organism target) {
        return target.isDead();
    }

    void spawnAlgae() {
        // TODO: publish event EVENT_ENTITY_SPAWN_REQUEST (ALGAE) when energy level reaches a certain threshold.
    }

    @Override
    void consumeCorpse(Organism target) {
        // TODO: implement scavenger action logic (e.g., increase energy level by consuming the target organism).
    }

    @Override
    void searchCorpse() {
        // TODO: implement corpse searching logic (e.g., scan nearby area for dead organisms to consume).
    }
}

// Module_ConcreteObject.pde
// Where all the final classes are defined

final class Algae extends Producer {
    
    Algae(float x, float y, float energyLevel, float maxEnergy, float optimalDepthMin, float optimalDepthMax) {
        super(x, y, energyLevel, maxEnergy, optimalDepthMin, optimalDepthMax);
    }

    @Override
    void update() {
        if (isDead) return; [cite: 95]

        updateBiologicalState(); [cite: 102]

        // TODO: implement photosynthesis logic (e.g., recovery energy based on Y depth/light intensity). [cite: 18, 36]
        
        // TODO: implement reproduction logic (e.g., clone itself when energy reaches max). 
    }

    @Override
    void render() {
        if (isDead) return; [cite: 95]
        // TODO: implement rendering logic for Algae (e.g., green primitive shapes for 60 FPS).
    }

    @Override
    boolean isSelected(float mx, float my) {
        return false; 
        // TODO: implement selection logic based on mouse coordinates.
    }

    @Override
    boolean canConsume(Organism target) {
        return false; 
        // Producer typically does not consume other organisms in this sim.
    }

    @Override
    void photosynthesis() {
        // TODO: implement energy recovery logic depending on depth Y (Shallow/Mid/Deep). 
    }

    void checkReproduction() {
        // TODO: implement biological control: duplicate when energy is max and reduce current energy. [cite: 75, 76]
        // TODO: publish EVENT_ENTITY_SPAWN_REQUEST via EventBus. [cite: 23]
    }
}