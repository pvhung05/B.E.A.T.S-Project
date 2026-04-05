// Module_ConcreteObject.pde
// Where all the final classes are defined
// Constructor values are loaded from data/organisms/<name>.json via cfgFloat().

final class Crab extends Decomposer {

    // JSON: data/organisms/crab.json
    Crab(float x, float y, float energyLevel) {
        super(EntityType.CRAB, x, y, energyLevel,
            cfgFloat("crab", "energy", "maxEnergy"),
            cfgFloat("crab", "energy", "metabolismRate"),
            cfgFloat("crab", "reproduction", "energyThreshold"),
            cfgFloat("crab", "ecology", "minDepth"),
            cfgFloat("crab", "ecology", "maxDepth"),
            20.0f, 20.0f,
            cfgFloat("crab", "movement", "speed"),
            cfgFloat("crab", "movement", "turnRate"),
            cfgFloat("crab", "feeding", "visionRadius"),
            cfgFloat("crab", "feeding", "consumeRadius"),
            cfgFloat("crab", "energy", "energyGain")
            );
    }


    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }


    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }


    boolean canConsume(Organism target) {
        return target instanceof Corpse && !target.isDead();
    }
}


final class Algae extends Producer {

    Algae(float x, float y, float energyLevel) {
        super(EntityType.ALGAE, x, y, energyLevel,
            cfgFloat("algae", "energy", "maxEnergy"),
            cfgFloat("algae", "energy", "metabolismRate"),
            cfgFloat("algae", "reproduction", "energyThreshold"),
            cfgFloat("algae", "ecology", "minDepth"),
            cfgFloat("algae", "ecology", "maxDepth"),
            10.0f, 10.0f,
            cfgFloat("algae", "energy", "photosynthesisRate")
            );
    }


    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        photosynthesis();
    }


    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 10;
    }


    boolean canConsume(Organism target) {
        return false;
    }


    void photosynthesis() {
        float lightFactor = 1.0f - (y / UIState.WORLD_HEIGHT);
        energyLevel = min(maxEnergy, energyLevel + photosynthesisRate * lightFactor);
    }
}


final class Shark extends Consumer {

    Shark(float x, float y, float energyLevel) {
        super(EntityType.SHARK, x, y, energyLevel,
            cfgFloat("shark", "energy", "maxEnergy"),
            cfgFloat("shark", "energy", "metabolismRate"),
            cfgFloat("shark", "reproduction", "energyThreshold"),
            cfgFloat("shark", "ecology", "minDepth"),
            cfgFloat("shark", "ecology", "maxDepth"),
            40.0f, 20.0f,
            cfgFloat("shark", "energy", "hungerThreshold"),
            cfgFloat("shark", "energy", "energyGain"),
            cfgFloat("shark", "movement", "speed"),
            cfgFloat("shark", "movement", "turnRate"),
            cfgFloat("shark", "feeding", "visionRadius"),
            cfgFloat("shark", "feeding", "attackRadius")
            );
    }


    boolean canConsume(Organism other) {
        return other instanceof Sardine && !other.isDead();
    }


    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }
}


final class Sardine extends Consumer {
    static final float SCHOOL_RADIUS     = 60.0f;
    static final float ALIGN_WEIGHT      = 1.0f;
    static final float COHESION_WEIGHT   = 0.8f;
    static final float SEPARATION_WEIGHT = 1.2f;

    Sardine(float x, float y, float energyLevel) {
        super(EntityType.SARDINE, x, y, energyLevel,
            cfgFloat("sardine", "energy", "maxEnergy"),
            cfgFloat("sardine", "energy", "metabolismRate"),
            cfgFloat("sardine", "reproduction", "energyThreshold"),
            cfgFloat("sardine", "ecology", "minDepth"),
            cfgFloat("sardine", "ecology", "maxDepth"),
            15.0f, 10.0f,
            cfgFloat("sardine", "energy", "hungerThreshold"),
            cfgFloat("sardine", "energy", "energyGain"),
            cfgFloat("sardine", "movement", "speed"),
            cfgFloat("sardine", "movement", "turnRate"),
            cfgFloat("sardine", "feeding", "visionRadius"),
            cfgFloatOr("sardine", "feeding", "attackRadius", 8.0f)
            );
    }


    boolean canConsume(Organism other) {
        return other instanceof Producer && !other.isDead();
    }


    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }
}


final class Corpse extends Organism {
    int corpseLifetime;

    Corpse(float x, float y, float energy) {
        super(EntityType.CORPSE, x, y, energy, energy, 0, Float.MAX_VALUE, 0, Float.MAX_VALUE, 20, 20);
        this.corpseLifetime = 300; // ~5 seconds @ 60fps
    }


    void update() {
        if (isDead()) return;
        if (energyLevel <= 0 || corpseLifetime <= 0) {
            dead = true;
            return;
        }
        corpseLifetime--;
    }


    boolean canConsume(Organism o) { return false; }


    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }
}
