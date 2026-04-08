class EntityManager implements IEventListener {
    ArrayList<Entity> entities;
    ArrayList<System> systems;
    QuadTree spatialTree;

    EntityManager() {
        entities = new ArrayList<Entity>();
        systems = new ArrayList<System>();
        
        // Initialize ECS Systems
        systems.add(new SysEnvironment());
        systems.add(new SysSteering());
        systems.add(new SysPredation());
        systems.add(new SysMovement());
        systems.add(new SysMetabolism());

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
            Entity e = entityFactory.spawn(entityType, x, y, initialEnergyPct);
            if (e != null) {
                entities.add(e);
            }
        } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
            Object[] data = (Object[]) payload;
            float x = (Float) data[1];
            float y = (Float) data[2];

            // Mark entity at this location as dead if it's there
            for (Entity e : entities) {
                if (e.isSelected(x, y)) {
                    e.dead = true;
                }
            }
        }
    }

    void addEntity(Entity e) {
        entities.add(e);
    }

    /**
     * ECS Update Pass: Rebuilds QuadTree and runs all systems.
     */
    void update() {
        // 1. Rebuild spatial partitioning
        spatialTree = new QuadTree(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
        for (Entity e : entities) {
            spatialTree.insert(e);
        }

        // 2. Run all ECS Systems
        for (System s : systems) {
            s.update(entities, spatialTree);
        }

        // 3. Lifecycle Cleanup
        for (int i = entities.size() - 1; i >= 0; i--) {
            Entity e = entities.get(i);
            if (e.isDead()) {
                entities.remove(i);
            }
        }
    }

    ArrayList<IObject> getEntitiesInRange(float x, float y, float radius) {
        ArrayList<IObject> results = new ArrayList<IObject>();
        if (spatialTree != null) {
            spatialTree.query(x, y, radius, results);
        }
        return results;
    }

    IObject getObjectAt(float mx, float my) {
        ArrayList<IObject> potential = getEntitiesInRange(mx, my, 5.0f);
        for (IObject obj : potential) {
            if (obj.isSelected(mx, my)) return obj;
        }
        return null;
    }
}
