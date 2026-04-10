// ECS_Components.pde
// All data components for the ECS architecture.

class CSpecies extends Component {
    EntityType type;
    CSpecies(EntityType type) {
        this.type = type;
    }
}

class CTransform extends Component {
    float x, y;
    float w, h;
    CTransform(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
}

class CVelocity extends Component {
    float vx, vy;
    float yAngle = 0;
    CVelocity(float vx, float vy) {
        this.vx = vx;
        this.vy = vy;
    }
}

class CEcology extends Component {
    float minDepth, maxDepth;
    CEcology(float minDepth, float maxDepth) {
        this.minDepth = minDepth;
        this.maxDepth = maxDepth;
    }
}

class CEnergy extends Component {
    float level;
    float max;
    float metabolism;
    float reproduceThreshold;
    CEnergy(float level, float max, float metabolism, float reproduceThreshold) {
        this.level = level;
        this.max = max;
        this.metabolism = metabolism;
        this.reproduceThreshold = reproduceThreshold;
    }
}

enum State {
    CRUISE,
        HUNT,
        FLEE
}

class CSteering extends Component {
    float speed;
    float turnRate;
    State state = State.CRUISE;
    CSteering(float speed, float turnRate) {
        this.speed = speed;
        this.turnRate = turnRate;
    }
}

class CSenses extends Component {
    float visionRadius;
    float attackRadius;
    CSenses(float visionRadius, float attackRadius) {
        this.visionRadius = visionRadius;
        this.attackRadius = attackRadius;
    }
}

class CDiet extends Component {
    float hungerThreshold;
    float energyGain;
    ArrayList<EntityType> prey = new ArrayList<EntityType>();

    CDiet(float hungerThreshold, float energyGain, EntityType... preyTypes) {
        this.hungerThreshold = hungerThreshold;
        this.energyGain = energyGain;
        for (EntityType pt : preyTypes) {
            this.prey.add(pt);
        }
    }
}

class CProducer extends Component {
    float photosynthesisRate;
    CProducer(float photosynthesisRate) {
        this.photosynthesisRate = photosynthesisRate;
    }
}

class CCorpse extends Component {
    int lifetime;
    CCorpse(int lifetime) {
        this.lifetime = lifetime;
    }
}
