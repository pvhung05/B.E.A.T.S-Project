// ECS_Systems.pde
// ECS Systems implementing the simulation logic.

class SysMovement extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CVelocity velocity = coordinator.getComponent(entity, CVelocity.class);

            transform.x += velocity.vx;
            transform.y += velocity.vy;

            // Boundary AI logic
            if (transform.x < 0) {
                transform.x = 0;
                velocity.vx *= -1;
            } else if (transform.x > UIState.WORLD_WIDTH) {
                transform.x = UIState.WORLD_WIDTH;
                velocity.vx *= -1;
            }

            CCorpse corpse = coordinator.getComponent(entity, CCorpse.class);

            if (transform.y < 0) {
                transform.y = 0;
                velocity.vy *= -1;
            } else if (transform.y > UIState.WORLD_HEIGHT) {
                transform.y = UIState.WORLD_HEIGHT;
                if (corpse != null) {
                    velocity.vx = 0;
                    velocity.vy = 0;
                } else {
                    velocity.vy *= -1;
                }
            }

            if (velocity.vx != 0 || velocity.vy != 0) {
                velocity.yAngle = atan2(velocity.vy, velocity.vx);
            }

            // Corpse decay — here because CORPSE has no CEcology and is excluded from SysEnvironment
            if (corpse != null) {
                corpse.lifetime--;
            }
        }
    }
}

class SysMetabolism extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CEnergy energy = coordinator.getComponent(entity, CEnergy.class);
            energy.level -= energy.metabolism;

            // Reproduction check
            if (energy.level >= energy.reproduceThreshold) {
                energy.level *= 0.5f;
                CTransform t = coordinator.getComponent(entity, CTransform.class);
                CSpecies s = coordinator.getComponent(entity, CSpecies.class);
                // Truyền đúng phần năng lượng đã tách (tính theo % của maxEnergy) cho con
                systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                    s.type.name(), t.x + random(-10, 10), t.y + random(-10, 10), energy.level / energy.max
                });
            }
        }
    }
}

class SysSteering extends System {

    /**
     * Attempt a guarded state transition.
     * FLEE always bypasses cooldown (survival priority).
     * Other transitions require the cooldown timer to have elapsed.
     * Returns true if the entity is now in the desired state.
     */
    private boolean tryTransition(CSteering steering, State desired) {
        if (steering.state == desired) {
            steering.stateTimer++;
            return true;
        }
        // FLEE always overrides immediately — survival takes priority
        if (desired == State.FLEE || steering.stateTimer >= steering.stateCooldown) {
            steering.state = desired;
            steering.stateTimer = 0;
            return true;
        }
        steering.stateTimer++;
        return false; // Cooldown not met — stay in current state
    }

    /** Returns speed adjusted by the current AI state multiplier. */
    private float effectiveSpeed(CSteering steering) {
        switch (steering.state) {
            case FLEE: return steering.speed * steering.fleeSpeedMult;
            case HUNT: return steering.speed * steering.huntSpeedMult;
            default:   return steering.speed;
        }
    }

    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CVelocity velocity = coordinator.getComponent(entity, CVelocity.class);
            CSteering steering = coordinator.getComponent(entity, CSteering.class);
            CSenses senses = coordinator.getComponent(entity, CSenses.class);
            CSpecies species = coordinator.getComponent(entity, CSpecies.class);

            ArrayList<Integer> nearby = new ArrayList<Integer>();
            spatialTree.query(coordinator, transform.x, transform.y, senses.visionRadius, nearby);

            // Behavioral logic based on species
            if (species.type == EntityType.SHARK) {
                updateSharkSteering(entity, coordinator, transform, velocity, steering, nearby);
            } else if (species.type == EntityType.SARDINE) {
                updateSardineSteering(entity, coordinator, transform, velocity, steering, nearby, spatialTree);
            } else if (species.type == EntityType.CRAB) {
                updateCrabSteering(entity, coordinator, transform, velocity, steering, nearby);
            }
        }
    }

    private void updateSharkSteering(int entity, Coordinator coordinator, CTransform transform, CVelocity velocity, CSteering steering, ArrayList<Integer> nearby) {
        int target = -1;
        float minDist = Float.MAX_VALUE;
        for (int other : nearby) {
            CSpecies otherSpecies = coordinator.getComponent(other, CSpecies.class);
            if (otherSpecies != null && otherSpecies.type == EntityType.SARDINE) {
                CTransform otherT = coordinator.getComponent(other, CTransform.class);
                float d = dist(transform.x, transform.y, otherT.x, otherT.y);
                if (d < minDist) {
                    minDist = d;
                    target = other;
                }
            }
        }

        if (target != -1 && tryTransition(steering, State.HUNT)) {
            CTransform targetT = coordinator.getComponent(target, CTransform.class);
            float dx = targetT.x - transform.x;
            float dy = targetT.y - transform.y;
            float len = sqrt(dx * dx + dy * dy);
            float spd = effectiveSpeed(steering);
            if (len > 0) {
                float targetVx = (dx / len) * spd;
                float targetVy = (dy / len) * spd;
                velocity.vx += (targetVx - velocity.vx) * steering.turnRate;
                velocity.vy += (targetVy - velocity.vy) * steering.turnRate;
            }
        } else if (target == -1 && tryTransition(steering, State.CRUISE)) {
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                steering.wanderTargetVx = cos(angle) * steering.speed;
                steering.wanderTargetVy = sin(angle) * steering.speed;
            }
            velocity.vx += (steering.wanderTargetVx - velocity.vx) * steering.turnRate;
            velocity.vy += (steering.wanderTargetVy - velocity.vy) * steering.turnRate;
        } else {
            // Cooldown active — continue current behavior
            steering.stateTimer++;
        }
    }

    private void updateSardineSteering(int entity, Coordinator coordinator, CTransform transform, CVelocity velocity, CSteering steering, ArrayList<Integer> nearby, QuadTree spatialTree) {
        // 1. Scan for threats
        float fleeX = 0, fleeY = 0;
        int sharkCount = 0;

        for (int other : nearby) {
            CSpecies s = coordinator.getComponent(other, CSpecies.class);
            if (s != null && s.type == EntityType.SHARK) {
                CTransform otherT = coordinator.getComponent(other, CTransform.class);
                float dx = transform.x - otherT.x;
                float dy = transform.y - otherT.y;
                float d = sqrt(dx * dx + dy * dy);
                if (d > 0) {
                    fleeX += dx / d;
                    fleeY += dy / d;
                    sharkCount++;
                }
            }
        }

        // 2. FLEE — always bypasses cooldown (survival priority)
        if (sharkCount > 0 && tryTransition(steering, State.FLEE)) {
            float spd = effectiveSpeed(steering);
            float fLen = sqrt(fleeX * fleeX + fleeY * fleeY);
            if (fLen > 0) {
                // Use turnRate steering instead of direct velocity overwrite (smoother flee)
                float targetVx = (fleeX / fLen) * spd;
                float targetVy = (fleeY / fLen) * spd;
                velocity.vx += (targetVx - velocity.vx) * steering.turnRate;
                velocity.vy += (targetVy - velocity.vy) * steering.turnRate;
            }
            return;
        }

        // 3. HUNT — pursue prey if hungry
        CEnergy energy = coordinator.getComponent(entity, CEnergy.class);
        CDiet diet = coordinator.getComponent(entity, CDiet.class);

        if (energy != null && diet != null && energy.level < diet.hungerThreshold) {
            int prey = -1;
            float minDist = Float.MAX_VALUE;
            for (int other : nearby) {
                CSpecies otherS = coordinator.getComponent(other, CSpecies.class);
                if (otherS != null && diet.prey.contains(otherS.type)) {
                    CTransform otherT = coordinator.getComponent(other, CTransform.class);
                    float d = dist(transform.x, transform.y, otherT.x, otherT.y);
                    if (d < minDist) {
                        minDist = d;
                        prey = other;
                    }
                }
            }

            if (prey != -1 && tryTransition(steering, State.HUNT)) {
                CTransform preyT = coordinator.getComponent(prey, CTransform.class);
                float dx = preyT.x - transform.x;
                float dy = preyT.y - transform.y;
                float len = sqrt(dx * dx + dy * dy);
                float spd = effectiveSpeed(steering);
                if (len > 0) {
                    float targetVx = (dx / len) * spd;
                    float targetVy = (dy / len) * spd;
                    velocity.vx += (targetVx - velocity.vx) * steering.turnRate;
                    velocity.vy += (targetVy - velocity.vy) * steering.turnRate;
                }
                return;
            }
        }

        // 4. CRUISE — schooling / wandering
        if (tryTransition(steering, State.CRUISE)) {
            applySardineSchooling(entity, coordinator, transform, velocity, steering, spatialTree);
        } else {
            // Cooldown active — continue current behavior
            steering.stateTimer++;
        }
    }

    private void applySardineSchooling(int entity, Coordinator coordinator, CTransform transform, CVelocity velocity, CSteering steering, QuadTree spatialTree) {
        float schoolRadius    = cfgFloatOr("sardine", "schooling", "radius",           60.0f);
        float alignWeight     = cfgFloatOr("sardine", "schooling", "alignmentWeight",  1.0f);
        float cohesionWeight  = cfgFloatOr("sardine", "schooling", "cohesionWeight",   0.8f);
        float separationWeight= cfgFloatOr("sardine", "schooling", "separationWeight", 1.2f);

        ArrayList<Integer> school = new ArrayList<Integer>();
        spatialTree.query(coordinator, transform.x, transform.y, schoolRadius, school);

        float alignX = 0, alignY = 0;
        float cohesionX = 0, cohesionY = 0;
        float separationX = 0, separationY = 0;
        int count = 0;

        for (int other : school) {
            if (other == entity) continue;
            CSpecies otherS = coordinator.getComponent(other, CSpecies.class);
            if (otherS == null || otherS.type != EntityType.SARDINE) continue;

            CTransform otherT = coordinator.getComponent(other, CTransform.class);
            CVelocity otherV = coordinator.getComponent(other, CVelocity.class);

            float d = dist(transform.x, transform.y, otherT.x, otherT.y);
            if (d == 0) continue;

            if (otherV != null) {
                alignX += otherV.vx;
                alignY += otherV.vy;
            }
            cohesionX += otherT.x;
            cohesionY += otherT.y;

            if (d < schoolRadius * 0.3f) {
                separationX += (transform.x - otherT.x) / d;
                separationY += (transform.y - otherT.y) / d;
            }
            count++;
        }

        if (count > 0) {
            float aLen = sqrt(alignX * alignX + alignY * alignY);
            if (aLen > 0) { alignX /= aLen; alignY /= aLen; }

            float cx = cohesionX / count - transform.x;
            float cy = cohesionY / count - transform.y;
            float cLen = sqrt(cx * cx + cy * cy);
            if (cLen > 0) { cx /= cLen; cy /= cLen; }

            float sLen = sqrt(separationX * separationX + separationY * separationY);
            if (sLen > 0) { separationX /= sLen; separationY /= sLen; }

            float newVx = alignX * alignWeight + cx * cohesionWeight + separationX * separationWeight;
            float newVy = alignY * alignWeight + cy * cohesionWeight + separationY * separationWeight;
            float vLen = sqrt(newVx * newVx + newVy * newVy);
            if (vLen > 0) {
                float targetVx = (newVx / vLen) * steering.speed;
                float targetVy = (newVy / vLen) * steering.speed;
                velocity.vx += (targetVx - velocity.vx) * steering.turnRate;
                velocity.vy += (targetVy - velocity.vy) * steering.turnRate;
            }
        } else {
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                steering.wanderTargetVx = cos(angle) * steering.speed;
                steering.wanderTargetVy = sin(angle) * steering.speed;
            }
            velocity.vx += (steering.wanderTargetVx - velocity.vx) * steering.turnRate;
            velocity.vy += (steering.wanderTargetVy - velocity.vy) * steering.turnRate;
        }
    }

    private void updateCrabSteering(int entity, Coordinator coordinator, CTransform transform, CVelocity velocity, CSteering steering, ArrayList<Integer> nearby) {
        int target = -1;
        float minDist = Float.MAX_VALUE;
        for (int other : nearby) {
            CSpecies otherS = coordinator.getComponent(other, CSpecies.class);
            if (otherS != null && otherS.type == EntityType.CORPSE) {
                CTransform otherT = coordinator.getComponent(other, CTransform.class);
                float d = dist(transform.x, transform.y, otherT.x, otherT.y);
                if (d < minDist) {
                    minDist = d;
                    target = other;
                }
            }
        }

        if (target != -1 && tryTransition(steering, State.HUNT)) {
            CTransform targetT = coordinator.getComponent(target, CTransform.class);
            float dx = targetT.x - transform.x;
            float dy = targetT.y - transform.y;
            float len = sqrt(dx * dx + dy * dy);
            float spd = effectiveSpeed(steering);
            if (len > 0) {
                float targetVx = (dx / len) * spd;
                float targetVy = (dy / len) * spd;
                velocity.vx += (targetVx - velocity.vx) * steering.turnRate;
                velocity.vy += (targetVy - velocity.vy) * steering.turnRate;
            }
        } else if (target == -1 && tryTransition(steering, State.CRUISE)) {
            CEcology ecology = coordinator.getComponent(entity, CEcology.class);
            float floorY = (ecology != null ? ecology.minDepth : 0.75f) * UIState.WORLD_HEIGHT;

            if (transform.y < floorY) {
                steering.wanderTargetVx = 0;
                steering.wanderTargetVy = steering.speed;
            } else {
                if (random(1) < 0.02f) {
                    steering.wanderTargetVx = (random(1) < 0.5f ? 1 : -1) * steering.speed;
                    steering.wanderTargetVy = 0;
                }
            }
            velocity.vx += (steering.wanderTargetVx - velocity.vx) * steering.turnRate;
            velocity.vy += (steering.wanderTargetVy - velocity.vy) * steering.turnRate;
        } else {
            steering.stateTimer++;
        }

        if (transform.y > UIState.WORLD_HEIGHT) transform.y = UIState.WORLD_HEIGHT;
    }
}

class SysPredation extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CEnergy energy = coordinator.getComponent(entity, CEnergy.class);
            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CSenses senses = coordinator.getComponent(entity, CSenses.class);
            CDiet diet = coordinator.getComponent(entity, CDiet.class);

            if (energy == null || transform == null || senses == null || diet == null) continue;
            if (energy.level > energy.max * 0.8f) continue;

            ArrayList<Integer> nearby = new ArrayList<Integer>();
            spatialTree.query(coordinator, transform.x, transform.y, senses.attackRadius, nearby);

            for (int other : nearby) {
                if (other == entity) continue;
                CSpecies otherSpecies = coordinator.getComponent(other, CSpecies.class);
                if (otherSpecies == null) continue;

                if (diet.prey.contains(otherSpecies.type)) {
                    CEnergy otherEnergy = coordinator.getComponent(other, CEnergy.class);

                    if (otherSpecies.type == EntityType.CORPSE) {
                        // Decomposer: drain corpse energy, gain equal amount (capped at energyGain/frame)
                        float gained = (otherEnergy != null) ? min(diet.energyGain, otherEnergy.level) : diet.energyGain;
                        energy.level = min(energy.max, energy.level + gained);
                        if (otherEnergy != null) otherEnergy.level -= gained;
                    } else {
                        // Consumer: take 50% of prey's energy, prey dies
                        float gained = (otherEnergy != null) ? otherEnergy.level * 0.5f : diet.energyGain;
                        energy.level = min(energy.max, energy.level + gained);
                        if (otherEnergy != null) otherEnergy.level = 0;
                    }

                    CTransform otherT = coordinator.getComponent(other, CTransform.class);
                    systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{
                        otherSpecies.type.name(), otherT.x, otherT.y, "EATEN"
                    });
                    break;
                }
            }
        }
    }
}

class SysEnvironment extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CEnergy energy = coordinator.getComponent(entity, CEnergy.class);
            CEcology ecology = coordinator.getComponent(entity, CEcology.class);
            CSpecies species = coordinator.getComponent(entity, CSpecies.class);

            // Temperature Stress — read actual temperature tolerance from JSON
            String sName = species.type.name().toLowerCase();
            float minTemp = cfgFloatOr(sName, "ecology", "minTemperature", 0.0f);
            float maxTemp = cfgFloatOr(sName, "ecology", "maxTemperature", 100.0f);
            if (UIState.temperature < minTemp || UIState.temperature > maxTemp) {
                energy.level -= energy.metabolism * 0.5f;
            }

            // Pollution Stress
            if (UIState.pollution > UIState.POLLUTION_STRESS_THRESHOLD) {
                energy.level -= (UIState.pollution - UIState.POLLUTION_STRESS_THRESHOLD) * 0.01f;
            }

            // Depth Constraint Stress — penalise entities outside their preferred depth zone
            float normalizedDepth = transform.y / UIState.WORLD_HEIGHT;
            if (normalizedDepth < ecology.minDepth || normalizedDepth > ecology.maxDepth) {
                energy.level -= energy.metabolism * 0.5f;
            }

            // Producer specific
            CProducer producer = coordinator.getComponent(entity, CProducer.class);
            if (producer != null) {
                float depthFactor = 1.0f - (transform.y / UIState.WORLD_HEIGHT);
                energy.level = min(energy.max, energy.level + producer.photosynthesisRate * depthFactor);
            }
        }
    }
}
