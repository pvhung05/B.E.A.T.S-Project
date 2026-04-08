// ECS_Systems.pde
// Systems handling the logic and physics for the ECS architecture.

class SysMovement extends System {
    void update(ArrayList<Entity> entities, QuadTree spatialTree) {
        for (Entity e : entities) {
            if (e.dead) continue;
            CTransform t = e.getComponent(CTransform.class);
            CVelocity v = e.getComponent(CVelocity.class);
            if (t != null && v != null) {
                t.x += v.vx;
                t.y += v.vy;

                if (t.x < 0) { t.x = 0; v.vx *= -1; }
                else if (t.x > UIState.WORLD_WIDTH) { t.x = UIState.WORLD_WIDTH; v.vx *= -1; }
                if (t.y < 0) { t.y = 0; v.vy *= -1; }
                else if (t.y > UIState.WORLD_HEIGHT) { t.y = UIState.WORLD_HEIGHT; v.vy *= -1; }

                if (v.vx != 0 || v.vy != 0) {
                    v.yAngle = atan2(v.vy, v.vx);
                }
            }
        }
    }
}

class SysMetabolism extends System {
    void update(ArrayList<Entity> entities, QuadTree spatialTree) {
        for (int i = entities.size() - 1; i >= 0; i--) {
            Entity e = entities.get(i);
            if (e.dead) continue;

            CEnergy en = e.getComponent(CEnergy.class);
            if (en != null) {
                en.level -= en.metabolism;
                if (en.level <= 0) {
                    e.dead = true;
                    spawnCorpse(e);
                    continue;
                }

                if (en.level >= en.reproduceThreshold) {
                    en.level *= 0.5f;
                    CSpecies s = e.getComponent(CSpecies.class);
                    CTransform t = e.getComponent(CTransform.class);
                    if (s != null && t != null) {
                        systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                            s.type.name(), t.x + random(-10, 10), t.y + random(-10, 10), 0.5f
                        });
                    }
                }
            }

            CCorpse c = e.getComponent(CCorpse.class);
            if (c != null) {
                if (c.lifetime <= 0) { e.dead = true; continue; }
                c.lifetime--;
            }
        }
    }

    private void spawnCorpse(Entity e) {
        CSpecies s = e.getComponent(CSpecies.class);
        if (s != null && s.type != EntityType.CORPSE) {
            CTransform t = e.getComponent(CTransform.class);
            CEnergy en = e.getComponent(CEnergy.class);
            if (t != null && en != null) {
                systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                    "CORPSE", t.x, t.y, max(10.0f, en.level)
                });
            }
        }
    }
}

class SysEnvironment extends System {
    void update(ArrayList<Entity> entities, QuadTree spatialTree) {
        for (Entity e : entities) {
            if (e.dead) continue;
            CEnergy en = e.getComponent(CEnergy.class);
            CTransform t = e.getComponent(CTransform.class);
            CEcology eco = e.getComponent(CEcology.class);

            if (en != null && eco != null) {
                if (UIState.temperature < eco.minDepth * 100 || UIState.temperature > eco.maxDepth * 100) {
                    en.level -= en.metabolism * 0.5f;
                }
                if (UIState.pollution > UIState.POLLUTION_STRESS_THRESHOLD) {
                    en.level -= (UIState.pollution - UIState.POLLUTION_STRESS_THRESHOLD) * 0.01f;
                }
            }

            CProducer p = e.getComponent(CProducer.class);
            if (p != null && en != null && t != null) {
                float depthFactor = 1.0f - (t.y / UIState.WORLD_HEIGHT);
                en.level += p.photosynthesisRate * depthFactor * 0.1f;
                en.level = min(en.max, en.level);
            }
        }
    }
}

class SysSteering extends System {
    void update(ArrayList<Entity> entities, QuadTree spatialTree) {
        if (spatialTree == null) return;
        for (Entity e : entities) {
            if (e.dead) continue;
            CSpecies s = e.getComponent(CSpecies.class);
            if (s == null) continue;

            if (s.type == EntityType.SHARK) processShark(e, spatialTree);
            else if (s.type == EntityType.SARDINE) processSardine(e, spatialTree, entities);
            else if (s.type == EntityType.CRAB) processCrab(e, spatialTree);
        }
    }

    private void processShark(Entity e, QuadTree spatialTree) {
        CTransform t = e.getComponent(CTransform.class);
        CVelocity v = e.getComponent(CVelocity.class);
        CSenses sns = e.getComponent(CSenses.class);
        CSteering st = e.getComponent(CSteering.class);
        CDiet diet = e.getComponent(CDiet.class);
        if (t == null || v == null || sns == null || st == null || diet == null) return;

        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(t.x, t.y, sns.visionRadius, nearby);
        Entity prey = findPrey(e, nearby, diet, sns.visionRadius);

        if (prey != null) {
            st.state = State.HUNT;
            CTransform pt = prey.getComponent(CTransform.class);
            float dx = pt.x - t.x;
            float dy = pt.y - t.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                v.vx = (dx / len) * st.speed;
                v.vy = (dy / len) * st.speed;
            }
        } else {
            st.state = State.CRUISE;
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                v.vx = cos(angle) * st.speed;
                v.vy = sin(angle) * st.speed;
            }
        }
    }

    private void processSardine(Entity e, QuadTree spatialTree, ArrayList<Entity> entities) {
        CTransform t = e.getComponent(CTransform.class);
        CVelocity v = e.getComponent(CVelocity.class);
        CSenses sns = e.getComponent(CSenses.class);
        CSteering st = e.getComponent(CSteering.class);
        CDiet diet = e.getComponent(CDiet.class);
        CEnergy en = e.getComponent(CEnergy.class);
        if (t == null || v == null || sns == null || st == null || diet == null || en == null) return;

        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(t.x, t.y, sns.visionRadius, nearby);

        boolean sharkNearby = false;
        for (IObject obj : nearby) {
            if (obj instanceof Entity) {
                CSpecies os = ((Entity)obj).getComponent(CSpecies.class);
                if (os != null && os.type == EntityType.SHARK && !obj.isDead()) {
                    sharkNearby = true; break;
                }
            }
        }

        if (sharkNearby) {
            st.state = State.FLEE;
            float fleeX = 0, fleeY = 0;
            int count = 0;
            for (IObject obj : nearby) {
                if (!(obj instanceof Entity)) continue;
                CSpecies os = ((Entity)obj).getComponent(CSpecies.class);
                if (os == null || os.type != EntityType.SHARK || obj.isDead()) continue;
                CTransform ot = ((Entity)obj).getComponent(CTransform.class);
                float dx = t.x - ot.x;
                float dy = t.y - ot.y;
                float d = sqrt(dx * dx + dy * dy);
                if (d > 0) { fleeX += dx / d; fleeY += dy / d; count++; }
            }
            if (count > 0) {
                float fLen = sqrt(fleeX * fleeX + fleeY * fleeY);
                if (fLen > 0) { v.vx = (fleeX / fLen) * st.speed; v.vy = (fleeY / fLen) * st.speed; }
            }
        } else if (en.level < diet.hungerThreshold) {
            st.state = State.HUNT;
            Entity prey = findPrey(e, nearby, diet, sns.visionRadius);
            if (prey != null) {
                CTransform pt = prey.getComponent(CTransform.class);
                float dx = pt.x - t.x;
                float dy = pt.y - t.y;
                float len = sqrt(dx * dx + dy * dy);
                if (len > 0) { v.vx = (dx / len) * st.speed; v.vy = (dy / len) * st.speed; }
            } else {
                st.state = State.CRUISE;
                applySardineSchooling(e, spatialTree, st, v, t);
            }
        } else {
            st.state = State.CRUISE;
            applySardineSchooling(e, spatialTree, st, v, t);
        }
    }

    private void applySardineSchooling(Entity e, QuadTree spatialTree, CSteering st, CVelocity v, CTransform t) {
        float SCHOOL_RADIUS = 60.0f;
        ArrayList<IObject> school = new ArrayList<IObject>();
        spatialTree.query(t.x, t.y, SCHOOL_RADIUS, school);

        float alignX = 0, alignY = 0;
        float cohesionX = 0, cohesionY = 0;
        float separationX = 0, separationY = 0;
        int count = 0;

        for (IObject obj : school) {
            if (!(obj instanceof Entity) || obj == e || obj.isDead()) continue;
            Entity n = (Entity) obj;
            CSpecies ns = n.getComponent(CSpecies.class);
            if (ns == null || ns.type != EntityType.SARDINE) continue;
            CTransform nt = n.getComponent(CTransform.class);
            CVelocity nv = n.getComponent(CVelocity.class);
            float d = dist(t.x, t.y, nt.x, nt.y);
            if (d == 0) continue;

            if (nv != null) { alignX += nv.vx; alignY += nv.vy; }
            cohesionX += nt.x; cohesionY += nt.y;
            if (d < SCHOOL_RADIUS * 0.3f) {
                separationX += (t.x - nt.x) / d;
                separationY += (t.y - nt.y) / d;
            }
            count++;
        }

        if (count > 0) {
            float aLen = sqrt(alignX * alignX + alignY * alignY);
            if (aLen > 0) { alignX /= aLen; alignY /= aLen; }
            float cx = cohesionX / count - t.x;
            float cy = cohesionY / count - t.y;
            float cLen = sqrt(cx * cx + cy * cy);
            if (cLen > 0) { cx /= cLen; cy /= cLen; }
            float sLen = sqrt(separationX * separationX + separationY * separationY);
            if (sLen > 0) { separationX /= sLen; separationY /= sLen; }

            float newVx = alignX * 1.0f + cx * 0.8f + separationX * 1.2f;
            float newVy = alignY * 1.0f + cy * 0.8f + separationY * 1.2f;
            float vLen = sqrt(newVx * newVx + newVy * newVy);
            if (vLen > 0) { v.vx = (newVx / vLen) * st.speed; v.vy = (newVy / vLen) * st.speed; }
        } else {
            if (random(1) < 0.02f) {
                float angle = random(TWO_PI);
                v.vx = cos(angle) * st.speed;
                v.vy = sin(angle) * st.speed;
            }
        }
    }

    private void processCrab(Entity e, QuadTree spatialTree) {
        CTransform t = e.getComponent(CTransform.class);
        CVelocity v = e.getComponent(CVelocity.class);
        CSenses sns = e.getComponent(CSenses.class);
        CSteering st = e.getComponent(CSteering.class);
        CDiet diet = e.getComponent(CDiet.class);
        if (t == null || v == null || sns == null || st == null || diet == null) return;

        ArrayList<IObject> nearby = new ArrayList<IObject>();
        spatialTree.query(t.x, t.y, sns.visionRadius, nearby);
        Entity prey = findPrey(e, nearby, diet, sns.visionRadius);

        if (prey != null) {
            CTransform pt = prey.getComponent(CTransform.class);
            float dx = pt.x - t.x;
            float dy = pt.y - t.y;
            float len = sqrt(dx * dx + dy * dy);
            if (len > 0) {
                v.vx = (dx / len) * st.speed;
                v.vy = (dy / len) * st.speed;
            }
        }
    }

    private Entity findPrey(Entity self, ArrayList<IObject> nearby, CDiet diet, float visionRadius) {
        Entity closest = null;
        float closestDist = visionRadius;
        CTransform st = self.getComponent(CTransform.class);

        for (IObject obj : nearby) {
            if (!(obj instanceof Entity) || obj == self || obj.isDead()) continue;
            Entity o = (Entity) obj;
            CSpecies os = o.getComponent(CSpecies.class);
            if (os == null || !diet.prey.contains(os.type)) continue;
            CTransform ot = o.getComponent(CTransform.class);
            float d = dist(st.x, st.y, ot.x, ot.y);
            if (d < closestDist) {
                closestDist = d;
                closest = o;
            }
        }
        return closest;
    }
}

class SysPredation extends System {
    void update(ArrayList<Entity> entities, QuadTree spatialTree) {
        if (spatialTree == null) return;
        for (Entity e : entities) {
            if (e.dead) continue;
            CEnergy en = e.getComponent(CEnergy.class);
            CDiet diet = e.getComponent(CDiet.class);
            CTransform t = e.getComponent(CTransform.class);
            CSenses sns = e.getComponent(CSenses.class);
            if (en == null || diet == null || t == null || sns == null) continue;

            if (en.level > en.max * 0.8f) continue;

            ArrayList<IObject> neighbors = new ArrayList<IObject>();
            spatialTree.query(t.x, t.y, sns.visionRadius, neighbors);

            for (IObject neighborObj : neighbors) {
                if (!(neighborObj instanceof Entity) || neighborObj == e || neighborObj.isDead()) continue;
                Entity target = (Entity) neighborObj;
                CSpecies ts = target.getComponent(CSpecies.class);
                if (ts == null || !diet.prey.contains(ts.type)) continue;

                CTransform tt = target.getComponent(CTransform.class);
                float d = dist(t.x, t.y, tt.x, tt.y);
                if (d < sns.attackRadius) {
                    handleConsumption(e, target, en, diet);
                    break;
                }
            }
        }
    }

    private void handleConsumption(Entity predator, Entity prey, CEnergy pEn, CDiet pDiet) {
        CSpecies ps = predator.getComponent(CSpecies.class);
        CSpecies preyS = prey.getComponent(CSpecies.class);
        CTransform preyT = prey.getComponent(CTransform.class);
        
        if (preyS.type == EntityType.CORPSE) {
            CEnergy preyEn = prey.getComponent(CEnergy.class);
            if (preyEn != null) {
                preyEn.level -= pDiet.energyGain;
                if (preyEn.level <= 0) prey.dead = true;
            }
        } else {
            prey.dead = true;
        }

        pEn.level = min(pEn.max, pEn.level + pDiet.energyGain);

        systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{
            preyS.type.name(), preyT.x, preyT.y, "EATEN"
        });
    }
}
