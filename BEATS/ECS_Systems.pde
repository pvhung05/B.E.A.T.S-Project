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
            if (transform.x < 0) { transform.x = 0; velocity.vx *= -1; }
            else if (transform.x > UIState.WORLD_WIDTH) { transform.x = UIState.WORLD_WIDTH; velocity.vx *= -1; }
            
            if (transform.y < 0) { transform.y = 0; velocity.vy *= -1; }
            else if (transform.y > UIState.WORLD_HEIGHT) { transform.y = UIState.WORLD_HEIGHT; velocity.vy *= -1; }

            if (velocity.vx != 0 || velocity.vy != 0) {
                velocity.yAngle = atan2(velocity.vy, velocity.vx);
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
                
                systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                    s.type.name(), t.x + random(-10, 10), t.y + random(-10, 10), 0.5f
                });
            }
        }
    }
}

class SysSteering extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CVelocity velocity = coordinator.getComponent(entity, CVelocity.class);
            CSteering steering = coordinator.getComponent(entity, CSteering.class);
            CSenses senses = coordinator.getComponent(entity, CSenses.class);
            CDiet diet = coordinator.getComponent(entity, CDiet.class);
            CSpecies species = coordinator.getComponent(entity, CSpecies.class);

            ArrayList<Integer> nearby = new ArrayList<Integer>();
            spatialTree.query(coordinator, transform.x, transform.y, senses.visionRadius, nearby);

            // Behavioral logic based on species
            if (species.type == EntityType.SHARK) {
                updateSharkSteering(entity, coordinator, transform, velocity, steering, nearby);
            } else if (species.type == EntityType.SARDINE) {
                updateSardineSteering(entity, coordinator, transform, velocity, steering, nearby);
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

        if (target != -1) {
            steering.state = State.HUNT;
            CTransform targetT = coordinator.getComponent(target, CTransform.class);
            float dx = targetT.x - transform.x;
            float dy = targetT.y - transform.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                velocity.vx = (dx / len) * steering.speed;
                velocity.vy = (dy / len) * steering.speed;
            }
        } else {
            steering.state = State.CRUISE;
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                velocity.vx = cos(angle) * steering.speed;
                velocity.vy = sin(angle) * steering.speed;
            }
        }
    }

    private void updateSardineSteering(int entity, Coordinator coordinator, CTransform transform, CVelocity velocity, CSteering steering, ArrayList<Integer> nearby) {
        // Schooling + Fleeing
        boolean sharkNearby = false;
        float fleeX = 0, fleeY = 0;
        int sharkCount = 0;

        for (int other : nearby) {
            CSpecies s = coordinator.getComponent(other, CSpecies.class);
            if (s != null && s.type == EntityType.SHARK) {
                sharkNearby = true;
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

        if (sharkNearby && sharkCount > 0) {
            steering.state = State.FLEE;
            float fLen = sqrt(fleeX * fleeX + fleeY * fleeY);
            if (fLen > 0) {
                velocity.vx = (fleeX / fLen) * steering.speed;
                velocity.vy = (fleeY / fLen) * steering.speed;
            }
        } else {
            steering.state = State.CRUISE;
            // Schooling logic simplified for brevity
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                velocity.vx = cos(angle) * steering.speed;
                velocity.vy = sin(angle) * steering.speed;
            }
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

        if (target != -1) {
            CTransform targetT = coordinator.getComponent(target, CTransform.class);
            float dx = targetT.x - transform.x;
            float dy = targetT.y - transform.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                velocity.vx = (dx / len) * steering.speed;
                velocity.vy = (dy / len) * steering.speed;
            }
        }
    }
}

class SysPredation extends System {
    @Override
    void update(Coordinator coordinator, QuadTree spatialTree) {
        ArrayList<Integer> copy = new ArrayList<Integer>(entities);
        for (int entity : copy) {
            CEnergy energy = coordinator.getComponent(entity, CEnergy.class);
            if (energy.level > energy.max * 0.8f) continue;

            CTransform transform = coordinator.getComponent(entity, CTransform.class);
            CSenses senses = coordinator.getComponent(entity, CSenses.class);
            CDiet diet = coordinator.getComponent(entity, CDiet.class);

            ArrayList<Integer> nearby = new ArrayList<Integer>();
            spatialTree.query(coordinator, transform.x, transform.y, senses.attackRadius, nearby);

            for (int other : nearby) {
                if (other == entity) continue;
                CSpecies otherSpecies = coordinator.getComponent(other, CSpecies.class);
                if (otherSpecies == null) continue;

                if (diet.prey.contains(otherSpecies.type)) {
                    // Eat
                    energy.level = min(energy.max, energy.level + diet.energyGain);
                    
                    if (otherSpecies.type == EntityType.CORPSE) {
                        CEnergy otherEnergy = coordinator.getComponent(other, CEnergy.class);
                        otherEnergy.level -= diet.energyGain;
                    } else {
                        // Kill
                        CEnergy otherEnergy = coordinator.getComponent(other, CEnergy.class);
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

            // Temperature Stress
            if (UIState.temperature < ecology.minDepth * 100 || UIState.temperature > ecology.maxDepth * 100) {
                energy.level -= energy.metabolism * 0.5f;
            }

            // Pollution Stress
            if (UIState.pollution > UIState.POLLUTION_STRESS_THRESHOLD) {
                energy.level -= (UIState.pollution - UIState.POLLUTION_STRESS_THRESHOLD) * 0.01f;
            }

            // Producer specific
            CProducer producer = coordinator.getComponent(entity, CProducer.class);
            if (producer != null) {
                float depthFactor = 1.0f - (transform.y / UIState.WORLD_HEIGHT);
                energy.level = min(energy.max, energy.level + producer.photosynthesisRate * depthFactor);
            }
            
            // Corpse specific
            CCorpse corpse = coordinator.getComponent(entity, CCorpse.class);
            if (corpse != null) {
                corpse.lifetime--;
            }
        }
    }
}
