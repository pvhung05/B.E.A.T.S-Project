// Core_EntityManager.pde
// Updated to use the optimized ECS Coordinator.

class EntityManager implements IEventListener {
    Coordinator coordinator;
    QuadTree spatialTree;
    ArrayList<Integer> activeEntities;

    EntityManager() {
        coordinator = new Coordinator();
        activeEntities = new ArrayList<Integer>();
        
        // 1. Register Components
        coordinator.registerComponent(CSpecies.class);
        coordinator.registerComponent(CTransform.class);
        coordinator.registerComponent(CVelocity.class);
        coordinator.registerComponent(CEnergy.class);
        coordinator.registerComponent(CEcology.class);
        coordinator.registerComponent(CSteering.class);
        coordinator.registerComponent(CSenses.class);
        coordinator.registerComponent(CDiet.class);
        coordinator.registerComponent(CProducer.class);
        coordinator.registerComponent(CCorpse.class);
        coordinator.registerComponent(CMeat.class);

        // 2. Register Systems
        coordinator.registerSystem(SysEnvironment.class, new SysEnvironment(), 
            CTransform.class, CEnergy.class, CEcology.class);
        coordinator.registerSystem(SysSteering.class, new SysSteering(), 
            CTransform.class, CVelocity.class, CSteering.class, CSenses.class);
        coordinator.registerSystem(SysPredation.class, new SysPredation(), 
            CTransform.class, CEnergy.class, CDiet.class, CSenses.class);
        coordinator.registerSystem(SysMovement.class, new SysMovement(), 
            CTransform.class, CVelocity.class);
        coordinator.registerSystem(SysMetabolism.class, new SysMetabolism(), 
            CEnergy.class);

        // Mandatory Subscriptions
        systemBus.subscribe(EventType.EVENT_ENTITY_SPAWN_REQUEST, this);
        systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
    }

    void onEvent(EventType type, Object payload) {
        if (type == EventType.EVENT_ENTITY_SPAWN_REQUEST) {
            Object[] data = (Object[]) payload;
            String entityId = (String) data[0];
            float x = (Float) data[1];
            float y = (Float) data[2];
            float initialEnergyPct = data.length > 3 && data[3] != null ? (Float) data[3] : -1.0f;

            EntityType entityType;
            try {
                entityType = EntityType.valueOf(entityId);
            } catch (IllegalArgumentException ex) {
                java.lang.System.err.println("EntityManager: Unknown entity type '" + entityId + "' — spawn ignored.");
                return;
            }
            
            // Factory now returns an int ID
            int e = entityFactory.spawn(coordinator, entityType, x, y, initialEnergyPct);
            if (e != -1) {
                activeEntities.add(e);
            }
        } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
            Object[] data = (Object[]) payload;
            float x = (Float) data[1];
            float y = (Float) data[2];
            String cause = (data.length > 3 && data[3] != null) ? (String) data[3] : "";

            // Only immediately destroy for CULL (user action).
            // EATEN/STARVED deaths have energy set to 0 by the systems;
            // the lifecycle cleanup loop handles those and spawns Corpses.
            if (cause.equals("CULL")) {
                for (int i = activeEntities.size() - 1; i >= 0; i--) {
                    int e = activeEntities.get(i);
                    if (isSelected(e, x, y)) {
                        destroyEntity(e);
                    }
                }
            }
        }
    }

    void destroyEntity(int entity) {
        coordinator.destroyEntity(entity);
        for (int i = 0; i < activeEntities.size(); i++) {
            if (activeEntities.get(i) == entity) {
                activeEntities.remove(i);
                break;
            }
        }
    }

    /**
     * ECS Update Pass: Rebuilds QuadTree and runs all systems.
     */
    void update() {
        // 1. Rebuild spatial partitioning
        spatialTree = new QuadTree(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
        for (int e : activeEntities) {
            spatialTree.insert(coordinator, e);
        }

        // 2. Run all ECS Systems
        for (System s : coordinator.getSystems()) {
            s.update(coordinator, spatialTree);
        }

        // 3. Lifecycle Cleanup & Dead handling (Metabolism marks energy <= 0 as dead)
        for (int i = activeEntities.size() - 1; i >= 0; i--) {
            int e = activeEntities.get(i);
            CEnergy energy = coordinator.getComponent(e, CEnergy.class);
            CCorpse corpse = coordinator.getComponent(e, CCorpse.class);
            CMeat meat = coordinator.getComponent(e, CMeat.class);
            
            boolean isDead = false;
            if (energy != null && energy.level <= 0) isDead = true;
            if (corpse != null && corpse.lifetime <= 0) isDead = true;

            if (isDead) {
                // Spawn corpse if it was an organism with meat (has energy, has CMeat, and is not already a corpse)
                if (energy != null && corpse == null && meat != null) {
                    CTransform t = coordinator.getComponent(e, CTransform.class);
                    systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                        "CORPSE", t.x, t.y, energy.max
                    });
                }
                destroyEntity(e);
            }
        }
    }

    boolean isSelected(int entity, float mx, float my) {
        CTransform t = coordinator.getComponent(entity, CTransform.class);
        if (t == null) return false;
        float left = t.x - t.w / 2;
        float right = t.x + t.w / 2;
        float bottom = t.y + t.h / 2;
        float top = t.y - t.h / 2;
        return (mx >= left && mx <= right && my >= top && my <= bottom);
    }

    int getObjectAt(float mx, float my) {
        // Simple search for now, could use QuadTree
        for (int e : activeEntities) {
            if (isSelected(e, mx, my)) return e;
        }
        return -1;
    }
}
