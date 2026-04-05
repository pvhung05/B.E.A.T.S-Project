// Module_Logic.pde
// Tier 3: Global Physics & Relationship Engine
// This module handles cross-entity interactions and global environmental influences.

class Logic {

    Logic() {
    }

    /**
     * Main entry point for Tier 2 (Interaction) and Tier 3 (Global) logic.
     * Processes how entities relate to each other and the world.
     */
    void processRules(ArrayList<IObject> entities, QuadTree spatialTree) {
        if (spatialTree == null) return;

        for (int i = 0; i < entities.size(); i++) {
            IObject obj = entities.get(i);
            if (!(obj instanceof Organism) || obj.isDead()) continue;
            Organism organism = (Organism) obj;

            // Tier 3: Global Environmental Deltas
            processEnvironmentalDeltas(organism);

            // Tier 2: Steering — sets velocityX/Y for each mobile species
            processSteering(organism, spatialTree);

            // Tier 2: Relationship Processing (Predation/Feeding)
            processRelationships(organism, spatialTree);
        }
    }

    /**
     * Tier 3: Environmental Deltas
     * Calculates how global sliders (Temperature, Pollution) affect the organism.
     */
    private void processEnvironmentalDeltas(Organism o) {
        // 1. Temperature Stress
        // If temperature is outside the species-specific optimal range, increase metabolic decay
        if (UIState.temperature < o.optimalDepthMin * 100 || UIState.temperature > o.optimalDepthMax * 100) {
            // Simple linear stress for now: 1.5x metabolism if uncomfortable
            o.energyLevel -= o.metabolismRate * 0.5f;
        }

        // 2. Pollution Stress
        // Global pollution directly drains energy based on a threshold
        if (UIState.pollution > UIState.POLLUTION_STRESS_THRESHOLD) {
            float pollutionStress = (UIState.pollution - UIState.POLLUTION_STRESS_THRESHOLD) * 0.01f;
            o.energyLevel -= pollutionStress;
        }

        // 3. Depth-to-Light mapping (Producer logic handled here centrally)
        if (o instanceof Producer) {
            Producer p = (Producer) o;
            float depthFactor = 1.0f - (p.y / UIState.WORLD_HEIGHT);
            // Bonus or penalty based on global light availability
            p.energyLevel += p.photosynthesisRate * depthFactor * 0.1f;
        }
    }

    /**
     * Tier 2: Steering
     * Sets velocityX/Y on each mobile organism based on its behavioral state.
     * Velocity is applied later in Organism.applyBoundaryAI() during the entity's own update().
     */
    private void processSteering(Organism o, QuadTree spatialTree) {
        if (o instanceof Shark) {
            processSharkSteering((Shark) o, spatialTree);
        } else if (o instanceof Sardine) {
            processSardineSteering((Sardine) o, spatialTree);
        } else if (o instanceof Crab) {
            processCrabSteering((Crab) o, spatialTree);
        }
        // Algae and Corpse: no locomotion
    }

    private void processSharkSteering(Shark shark, QuadTree spatialTree) {
        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(shark.x, shark.y, shark.visionRadius, nearby);

        Organism prey = shark.searchFood(nearby);
        if (prey != null) {
            shark.state = State.HUNT;
            float dx = prey.x - shark.x;
            float dy = prey.y - shark.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                shark.velocityX = (dx / len) * shark.speed;
                shark.velocityY = (dy / len) * shark.speed;
            }
        } else {
            shark.state = State.CRUISE;
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                shark.velocityX = cos(angle) * shark.speed;
                shark.velocityY = sin(angle) * shark.speed;
            }
        }
    }

    private void processSardineSteering(Sardine sardine, QuadTree spatialTree) {
        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(sardine.x, sardine.y, sardine.visionRadius, nearby);

        // FLEE takes priority — check for any live Shark in vision range
        boolean sharkNearby = false;
        for (IObject obj : nearby) {
            if (obj instanceof Shark && !((Shark) obj).isDead()) {
                sharkNearby = true;
                break;
            }
        }

        if (sharkNearby) {
            sardine.state = State.FLEE;
            float fleeX = 0, fleeY = 0;
            int count = 0;
            for (IObject obj : nearby) {
                if (!(obj instanceof Shark) || ((Shark) obj).isDead()) continue;
                Shark s = (Shark) obj;
                float dx = sardine.x - s.x;
                float dy = sardine.y - s.y;
                float d = sqrt(dx * dx + dy * dy);
                if (d > 0) {
                    fleeX += dx / d;
                    fleeY += dy / d;
                    count++;
                }
            }
            if (count > 0) {
                float fLen = sqrt(fleeX * fleeX + fleeY * fleeY);
                if (fLen > 0) {
                    sardine.velocityX = (fleeX / fLen) * sardine.speed;
                    sardine.velocityY = (fleeY / fLen) * sardine.speed;
                }
            }
        } else if (sardine.energyLevel < sardine.hungerThreshold) {
            sardine.state = State.HUNT;
            Organism prey = sardine.searchFood(nearby);
            if (prey != null) {
                float dx = prey.x - sardine.x;
                float dy = prey.y - sardine.y;
                float len = sqrt(dx * dx + dy * dy);
                if (len > 0) {
                    sardine.velocityX = (dx / len) * sardine.speed;
                    sardine.velocityY = (dy / len) * sardine.speed;
                }
            } else {
                // No prey found — fall back to schooling
                sardine.state = State.CRUISE;
                applySardineSchooling(sardine, spatialTree);
            }
        } else {
            sardine.state = State.CRUISE;
            applySardineSchooling(sardine, spatialTree);
        }
    }

    private void applySardineSchooling(Sardine sardine, QuadTree spatialTree) {
        ArrayList<IObject> school = new ArrayList<IObject>();
        spatialTree.query(sardine.x, sardine.y, Sardine.SCHOOL_RADIUS, school);

        float alignX = 0, alignY = 0;
        float cohesionX = 0, cohesionY = 0;
        float separationX = 0, separationY = 0;
        int count = 0;

        for (IObject obj : school) {
            if (!(obj instanceof Sardine) || obj == sardine) continue;
            Sardine n = (Sardine) obj;
            if (n.isDead()) continue;
            float d = dist(sardine.x, sardine.y, n.x, n.y);
            if (d == 0) continue;

            alignX += n.velocityX;
            alignY += n.velocityY;
            cohesionX += n.x;
            cohesionY += n.y;
            if (d < Sardine.SCHOOL_RADIUS * 0.3f) {
                separationX += (sardine.x - n.x) / d;
                separationY += (sardine.y - n.y) / d;
            }
            count++;
        }

        if (count > 0) {
            float aLen = sqrt(alignX * alignX + alignY * alignY);
            if (aLen > 0) { alignX /= aLen; alignY /= aLen; }

            float cx = cohesionX / count - sardine.x;
            float cy = cohesionY / count - sardine.y;
            float cLen = sqrt(cx * cx + cy * cy);
            if (cLen > 0) { cx /= cLen; cy /= cLen; }

            float sLen = sqrt(separationX * separationX + separationY * separationY);
            if (sLen > 0) { separationX /= sLen; separationY /= sLen; }

            float newVx = alignX * Sardine.ALIGN_WEIGHT + cx * Sardine.COHESION_WEIGHT + separationX * Sardine.SEPARATION_WEIGHT;
            float newVy = alignY * Sardine.ALIGN_WEIGHT + cy * Sardine.COHESION_WEIGHT + separationY * Sardine.SEPARATION_WEIGHT;
            float vLen = sqrt(newVx * newVx + newVy * newVy);
            if (vLen > 0) {
                sardine.velocityX = (newVx / vLen) * sardine.speed;
                sardine.velocityY = (newVy / vLen) * sardine.speed;
            }
        } else {
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                sardine.velocityX = cos(angle) * sardine.speed;
                sardine.velocityY = sin(angle) * sardine.speed;
            }
        }
    }

    private void processCrabSteering(Crab crab, QuadTree spatialTree) {
        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(crab.x, crab.y, crab.visionRadius, nearby);

        Organism closestCorpse = null;
        float closestDist = crab.visionRadius;
        for (IObject obj : nearby) {
            if (!(obj instanceof Corpse) || ((Corpse) obj).isDead()) continue;
            float d = dist(crab.x, crab.y, ((Corpse) obj).x, ((Corpse) obj).y);
            if (d < closestDist) {
                closestDist = d;
                closestCorpse = (Corpse) obj;
            }
        }

        if (closestCorpse != null) {
            float dx = closestCorpse.x - crab.x;
            float dy = closestCorpse.y - crab.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                crab.velocityX = (dx / len) * crab.speed;
                crab.velocityY = (dy / len) * crab.speed;
            }
        }
    }

    /**
     * Tier 2: Relationship Processing
     * Uses spatial partitioning to handle interactions like hunting and eating.
     */
    private void processRelationships(Organism o, QuadTree spatialTree) {
        // Optimization: Skip interaction check if organism is satisfied (above 80% energy)
        if (o.energyLevel > o.maxEnergy * 0.8f) return;

        float searchRadius = 0;
        if (o instanceof Consumer) {
            searchRadius = ((Consumer)o).visionRadius;
        } else if (o instanceof Decomposer) {
            searchRadius = ((Decomposer)o).visionRadius;
        }

        if (searchRadius <= 0) return;

        // Use QuadTree for O(log N) neighbor search
        ArrayList<IObject> neighbors = new ArrayList<IObject>();
        spatialTree.query(o.x, o.y, searchRadius, neighbors);

        for (IObject neighborObj : neighbors) {
            if (!(neighborObj instanceof Organism) || neighborObj == o || neighborObj.isDead()) continue;
            Organism target = (Organism) neighborObj;

            // Predation/Feeding Logic
            if (o.canConsume(target)) {
                float d = dist(o.x, o.y, target.x, target.y);

                float attackRadius = 15; // Default fallback
                if (o instanceof Consumer) attackRadius = ((Consumer)o).attackRadius;
                if (o instanceof Decomposer) attackRadius = ((Decomposer)o).attackRadius;

                if (d < attackRadius) {
                    handleConsumption(o, target);
                    break; // One meal per frame
                }
            }
        }
    }

    /**
     * Logic for transferring energy between entities.
     */
    private void handleConsumption(Organism predator, Organism prey) {
        float energyGain = 0;

        if (predator instanceof Consumer) {
            energyGain = ((Consumer)predator).energyGain;
            prey.dead = true; // Consumers kill prey
        } else if (predator instanceof Decomposer) {
            energyGain = ((Decomposer)predator).energyGain;
            // Decomposers eat dead tissue, so they don't 'kill',
            // but we might drain the corpse energy here.
            prey.energyLevel -= energyGain;
            if (prey.energyLevel <= 0) prey.dead = true;
        }

        predator.energyLevel = min(predator.maxEnergy, predator.energyLevel + energyGain);

        // Notify FX system of a successful hunt/feed
        systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{
            prey.getClass().getSimpleName().toUpperCase(),
            prey.x,
            prey.y,
            "EATEN"
            });
    }
}
