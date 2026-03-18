// Module_ConcreteObject.pde
// Where all the final classes are defined



final class Crab extends Decomposer {  
    
    Crab(float x, float y, float energyLevel) {
        // Initializing with zero/defaults. 
        // TODO: @[Core-Eng]: please implement a static load method to parse data from data/organisms/crab.json
        // and reuse it for instances. Ensure the values are cached once at startup.
        super(x, y, energyLevel, 50.0f, 0.75f, 1.0f);
    }
    
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