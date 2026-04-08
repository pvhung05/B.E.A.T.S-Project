import java.util.Map;
import java.util.HashMap;

class EntityManager implements IEventListener {
    ArrayList<IObject> entities;
    QuadTree spatialTree;
    Logic simulationLogic;
    
    // Object Pooling: Storage for inactive entities by type
    Map<EntityType, ArrayList<BaseEntity>> pool;

    EntityManager() {
        entities = new ArrayList<IObject>();
        pool = new HashMap<EntityType, ArrayList<BaseEntity>>();
        simulationLogic = new Logic();
        // Mandatory Subscriptions
        systemBus.subscribe(EventType.EVENT_ENTITY_SPAWN_REQUEST, this);
        systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
    }

    /**
     * Retrieves an inactive entity from the pool if available.
     */
    BaseEntity getFromPool(EntityType type) {
        if (pool.containsKey(type)) {
            ArrayList<BaseEntity> typePool = pool.get(type);
            if (!typePool.isEmpty()) {
                BaseEntity e = typePool.remove(typePool.size() - 1);
                return e;
            }
        }
        return null;
    }

    /**
     * Returns a dead entity to the pool for later reuse.
     */
    void returnToPool(BaseEntity e) {
        e.active = false;
        if (!pool.containsKey(e.type)) {
            pool.put(e.type, new ArrayList<BaseEntity>());
        }
        pool.get(e.type).add(e);
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
                System.err.println("EntityManager: Unknown entity type '" + entityId + "' — spawn ignored.");
                return;
            }
            Organism e = entityFactory.spawn(entityType, x, y, initialEnergyPct);
            if (e != null) {
                entities.add(e);
            }
        } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
            Object[] data = (Object[]) payload;
            float x = (Float) data[1];
            float y = (Float) data[2];

            // Mark entity at this location as dead if it's there
            for (IObject e : entities) {
                if (e.isSelected(x, y)) {
                    if (e instanceof BaseEntity) {
                        ((BaseEntity)e).dead = true;
                    }
                }
            }
        }
    }

    void addEntity(IObject e) {
        entities.add(e);
    }

    /**
     * Decoupled Update Pass: Handles physics, logic, and lifecycle.
     */
    void update() {
        // 1. Rebuild spatial partitioning - only for active entities
        spatialTree = new QuadTree(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
        for (IObject e : entities) {
            if (e.isActive()) {
                spatialTree.insert(e);
            }
        }

        // 2. Global Logic Pass (Tier 2 & 3)
        simulationLogic.processRules(entities, spatialTree);

        // 3. Local Entity Updates & Lifecycle
        for (int i = entities.size() - 1; i >= 0; i--) {
            IObject e = entities.get(i);
            
            // Skip and remove if already inactive
            if (!e.isActive()) {
                entities.remove(i);
                continue;
            }

            e.update();

            // Handle transition for dead entities
            if (e.isDead()) {
                if (e instanceof Organism && !(e instanceof Corpse)) {
                    Organism o = (Organism) e;
                    // Spawn Corpse via event bus so all lifecycles go through the EventBus
                    systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{
                        "CORPSE", o.x, o.y, max(10.0f, o.energyLevel)
                    });
                }
                
                // Return to pool instead of just marking as inactive
                if (e instanceof BaseEntity) {
                    returnToPool((BaseEntity) e);
                }
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
        for (IObject e : potential) {
            if (e.isSelected(mx, my)) return e;
        }
        return null;
    }
}
