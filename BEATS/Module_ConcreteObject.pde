// Module_ConcreteObject.pde
// Where all the final classes are defined
// Constructor values are loaded from data/organisms/<name>.json via cfgFloat().

final class Crab extends Decomposer {
    Organism currentCorpse;

    // JSON: data/organisms/crab.json
    Crab(float x, float y, float energyLevel) {
        super(EntityType.CRAB, x, y, energyLevel,
            cfgFloat("crab", "energy", "maxEnergy"),
            cfgFloat("crab", "energy", "metabolismRate"),
            cfgFloat("crab", "reproduction", "energyThreshold"),
            cfgFloat("crab", "ecology", "minDepth"),
            cfgFloat("crab", "ecology", "maxDepth"),
            20.0f, 20.0f, // trong json chưa có nên tôi đang set cứng hitboxW, hitboxH
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
        searchCorpse();
        if (currentCorpse != null) {
            float d = dist(x, y, currentCorpse.x, currentCorpse.y);
            if (d <= attackRadius) {
                consumeCorpse(currentCorpse);
            } else {
                float angle = atan2(currentCorpse.y - y, currentCorpse.x - x);
                velocityX = cos(angle) * speed;
                velocityY = sin(angle) * speed;
            }
        }
        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }


    void render() {
        // Rendering handled centrally by EntityRenderer.drawCrab()
    }


    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }


    boolean canConsume(Organism target) {
        // Crab handles corpse eating manually via searchCorpse()/consumeCorpse() in update().
        // Returning false here prevents Module_Logic from also triggering a second consumption on the same frame.
        return false;
    }


    void consumeCorpse(Organism target) {
        float gained = min(energyGain, target.energyLevel);
        energyLevel = min(maxEnergy, energyLevel + gained);
        target.energyLevel -= gained;
        if (target.energyLevel <= 0) {
            target.dead = true;
            currentCorpse = null;
        }
    }


    void searchCorpse() {
        // Keep tracking current corpse if it is still alive
        if (currentCorpse != null && !currentCorpse.isDead()) return;
        currentCorpse = null;
        ArrayList<IObject> nearby = world.getEntitiesInRange(x, y, visionRadius);
        float closest = visionRadius;
        for (IObject obj : nearby) {
            if (!(obj instanceof Corpse)) continue;
            Corpse c = (Corpse) obj;
            if (c.isDead()) continue;
            float d = dist(x, y, c.x, c.y);
            if (d < closest) {
                closest = d;
                currentCorpse = c;
            }
        }
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
            10.0f, 10.0f, // trong json chưa có nên tôi đang set cứng hitboxW, hitboxH
            cfgFloat("algae", "energy", "photosynthesisRate")
            );
    }

    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;
        photosynthesis();
    }


    void render() {
        // Rendering handled centrally by EntityRenderer.drawAlgae()
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


    void render() {
        if (isDead()) return;
        // TODO: @[FX] implement rendering logic
    }


    void update() {
        if (isDead()) return;
        updateBiologicalState();
        if (isDead()) return;

        state = (energyLevel < hungerThreshold) ? State.HUNT : State.CRUISE;
        if (state == State.HUNT) hunt();
        else cruise();

        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }


    void cruise() {
        if (random(1) < 0.02f) {
            float angle = random(TWO_PI);
            velocityX = cos(angle) * speed;
            velocityY = sin(angle) * speed;
        }
    }


    void hunt() {
        ArrayList<IObject> nearby = world.getEntitiesInRange(x, y, visionRadius);
        currentTarget = searchFood(nearby);
        if (currentTarget != null) {
            float dx = currentTarget.x - x;
            float dy = currentTarget.y - y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                velocityX = (dx / len) * speed;
                velocityY = (dy / len) * speed;
            }
        } else {
            cruise();
        }
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

        ArrayList<IObject> nearby = world.getEntitiesInRange(x, y, visionRadius);

        boolean sharkNearby = false;
        for (IObject obj : nearby) {
            if (obj instanceof Shark && !((Shark) obj).isDead()) {
                sharkNearby = true;
                break;
            }
        }

        if (sharkNearby) {
            state = State.FLEE;
            flee(nearby);
        } else if (energyLevel < hungerThreshold) {
            state = State.HUNT;
            hunt(nearby);
        } else {
            state = State.CRUISE;
            cruise();
        }

        applyBoundaryAI(UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    }


    void cruise() {
        ArrayList<IObject> nearby = world.getEntitiesInRange(x, y, SCHOOL_RADIUS);
        float alignX = 0, alignY = 0;
        float cohesionX = 0, cohesionY = 0;
        float separationX = 0, separationY = 0;
        int count = 0;

        for (IObject obj : nearby) {
            if (!(obj instanceof Sardine) || obj == this) continue;
            Sardine n = (Sardine) obj;
            float d = dist(x, y, n.x, n.y);
            if (d == 0) continue;

            alignX += n.velocityX;
            alignY += n.velocityY;
            cohesionX += n.x;
            cohesionY += n.y;
            if (d < SCHOOL_RADIUS * 0.3f) {
                separationX += (x - n.x) / d;
                separationY += (y - n.y) / d;
            }
            count++;
        }

        if (count > 0) {
            float aLen = sqrt(alignX * alignX + alignY * alignY);
            if (aLen > 0) { alignX /= aLen; alignY /= aLen; }

            float cx = cohesionX / count - x;
            float cy = cohesionY / count - y;
            float cLen = sqrt(cx * cx + cy * cy);
            if (cLen > 0) { cx /= cLen; cy /= cLen; }

            float sLen = sqrt(separationX * separationX + separationY * separationY);
            if (sLen > 0) { separationX /= sLen; separationY /= sLen; }

            float newVx = alignX * ALIGN_WEIGHT + cx * COHESION_WEIGHT + separationX * SEPARATION_WEIGHT;
            float newVy = alignY * ALIGN_WEIGHT + cy * COHESION_WEIGHT + separationY * SEPARATION_WEIGHT;
            float vLen = sqrt(newVx * newVx + newVy * newVy);
            if (vLen > 0) {
                velocityX = (newVx / vLen) * speed;
                velocityY = (newVy / vLen) * speed;
            }
        } else {
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                velocityX = cos(angle) * speed;
                velocityY = sin(angle) * speed;
            }
        }
    }


    void flee(ArrayList<IObject> nearby) {
        float fleeX = 0, fleeY = 0;
        int count = 0;
        for (IObject obj : nearby) {
            if (!(obj instanceof Shark) || ((Shark) obj).isDead()) continue;
            Shark s = (Shark) obj;
            float dx = x - s.x;
            float dy = y - s.y;
            float d = sqrt(dx * dx + dy * dy);
            if (d > 0) {
                fleeX += dx / d;
                fleeY += dy / d;
                count++;
            }
        }
        if (count > 0) {
            fleeX /= count;
            fleeY /= count;
            float fLen = sqrt(fleeX * fleeX + fleeY * fleeY);
            if (fLen > 0) {
                velocityX = (fleeX / fLen) * speed;
                velocityY = (fleeY / fLen) * speed;
            }
        }
    }


    void hunt(ArrayList<IObject> nearby) {
        currentTarget = searchFood(nearby);
        if (currentTarget != null) {
            float dx = currentTarget.x - x;
            float dy = currentTarget.y - y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                velocityX = (dx / len) * speed;
                velocityY = (dy / len) * speed;
            }
        } else {
            cruise();
        }
    }


    void hunt() {
        hunt(world.getEntitiesInRange(x, y, visionRadius));
    }


    void render() {
        if (isDead()) return;
        // TODO: @[FX] implement rendering logic
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

    void render() {
        // TODO: @[FX] implement corpse rendering
    }

    boolean canConsume(Organism o) { return false; }

    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }
}
