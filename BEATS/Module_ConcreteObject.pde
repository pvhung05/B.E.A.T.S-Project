// Module_ConcreteObject.pde
// Where all the final classes are defined

final class Crab extends Decomposer {
    final float MAX_ENERGY = cfgFloat("crab", "energy", "maxEnergy");
    final float METABOLISM_RATE = cfgFloat("crab", "energy", "metabolismRate");
    final float REPRO_THRESHOLD = cfgFloat("crab", "reproduction", "energyThreshold");
    final float MIN_DEPTH = cfgFloat("crab", "ecology", "minDepth");
    final float MAX_DEPTH = cfgFloat("crab", "ecology", "maxDepth");
    final float SPEED = cfgFloat("crab", "movement", "speed");
    final float TURN_RATE = cfgFloat("crab", "movement", "turnRate");
    final float VISION_RADIUS = cfgFloat("crab", "feeding", "visionRadius");
    final float CONSUME_RADIUS = cfgFloat("crab", "feeding", "consumeRadius");
    final float ENERGY_GAIN = cfgFloat("crab", "energy", "energyGain");

    Organism currentCorpse;

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

    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
        searchCorpse();
        if (currentCorpse != null) {
            float d = dist(x, y, currentCorpse.x, currentCorpse.y);
            if (d <= CONSUME_RADIUS) {
                consumeCorpse(currentCorpse);
            }
        }
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }

    @Override
    boolean canConsume(Organism target) {
        return target.isDead();
    }

    @Override
    void consumeCorpse(Organism target) {
        float gained = min(ENERGY_GAIN, target.energyLevel);
        energyLevel = min(MAX_ENERGY, energyLevel + gained);
        target.energyLevel -= gained;
        if (target.energyLevel <= 0) currentCorpse = null;
    }

    @Override
    void searchCorpse() {
        // TODO: search
    }
}


final class Algae extends Producer {
    final float MAX_ENERGY = cfgFloat("algae", "energy", "maxEnergy");
    final float METABOLISM_RATE = cfgFloat("algae", "energy", "metabolismRate");
    final float REPRO_THRESHOLD = cfgFloat("algae", "reproduction", "energyThreshold");
    final float MIN_DEPTH = cfgFloat("algae", "ecology", "minDepth");
    final float MAX_DEPTH = cfgFloat("algae", "ecology", "maxDepth");
    final float PHOTO_RATE = cfgFloat("algae", "energy", "photosynthesisRate");

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

    Algae(float x, float y, float energyLevel, float _maxE, float _dMin, float _dMax) {
        this(x, y, energyLevel);
    }

    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        photosynthesis();
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 10;
    }

    @Override
    boolean canConsume(Organism target) {
        return false;
    }

    @Override
    void photosynthesis() {
        float lightFactor = 1.0f - (y / UIState.WORLD_HEIGHT);
        energyLevel = min(MAX_ENERGY, energyLevel + PHOTO_RATE * lightFactor);
    }
}


final class Shark extends Consumer {
    final float MAX_ENERGY = cfgFloat("shark", "energy", "maxEnergy");
    final float METABOLISM_RATE = cfgFloat("shark", "energy", "metabolismRate");
    final float REPRO_THRESHOLD = cfgFloat("shark", "reproduction", "energyThreshold");
    final float MIN_DEPTH = cfgFloat("shark", "ecology", "minDepth");
    final float MAX_DEPTH = cfgFloat("shark", "ecology", "maxDepth");
    final float HUNGER_THRESHOLD = cfgFloat("shark", "energy", "hungerThreshold");
    final float ENERGY_GAIN = cfgFloat("shark", "energy", "energyGain");
    final float SPEED = cfgFloat("shark", "movement", "speed");
    final float TURN_RATE = cfgFloat("shark", "movement", "turnRate");
    final float VISION_RADIUS = cfgFloat("shark", "feeding", "visionRadius");
    final float ATTACK_RADIUS = cfgFloat("shark", "feeding", "attackRadius");

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

    @Override
    public boolean canConsume(Organism other) {
        return other instanceof Sardine && !other.isDead();
    }

    @Override
    public void update() {
        if (isDead()) return;
        updateBiologicalState();
        
        state = (energyLevel < HUNGER_THRESHOLD) ? State.HUNT : State.CRUISE;
        if (state == State.HUNT) hunt();
        else cruise();

        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }

    @Override
    void cruise() {
        // TODO: patrol
    }

    @Override
    void hunt() {
        // TODO: search and steer
    }
}

final class Sardine extends Consumer {
    final float MAX_ENERGY = cfgFloat("sardine", "energy", "maxEnergy");
    final float METABOLISM_RATE = cfgFloat("sardine", "energy", "metabolismRate");
    final float REPRO_THRESHOLD = cfgFloat("sardine", "reproduction", "energyThreshold");
    final float MIN_DEPTH = cfgFloat("sardine", "ecology", "minDepth");
    final float MAX_DEPTH = cfgFloat("sardine", "ecology", "maxDepth");
    final float HUNGER_THRESHOLD = cfgFloat("sardine", "energy", "hungerThreshold");
    final float ENERGY_GAIN = cfgFloat("sardine", "energy", "energyGain");
    final float SPEED = cfgFloat("sardine", "movement", "speed");
    final float TURN_RATE = cfgFloat("sardine", "movement", "turnRate");
    final float VISION_RADIUS = cfgFloat("sardine", "feeding", "visionRadius");
    final float ATTACK_RADIUS = cfgFloatOr("sardine", "feeding", "attackRadius", 8.0f);

    final float SCHOOL_RADIUS     = 60.0f;
    final float ALIGN_WEIGHT      = 1.0f;
    final float COHESION_WEIGHT   = 0.8f;
    final float SEPARATION_WEIGHT = 1.2f;

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

    @Override
    boolean canConsume(Organism other) {
        return other instanceof Producer && !other.isDead();
    }

    @Override
    public void update() {
        if (isDead()) return;
        updateBiologicalState();
        
        state = (energyLevel < HUNGER_THRESHOLD) ? State.HUNT : State.CRUISE;
        if (state == State.HUNT) hunt();
        else cruise();

        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }

    @Override
    void cruise() {
        // TODO: schooling
    }

    @Override
    void hunt() {
        // TODO: search and steer
    }
}
