class EntityManager implements IEventListener {
  ArrayList<IObject> entities;
  QuadTree spatialTree;
  Logic simulationLogic;

  EntityManager() {
    entities = new ArrayList<IObject>();
    simulationLogic = new Logic();
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

      Organism e = entityFactory.spawn(entityId, x, y, initialEnergyPct);
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
    // 1. Rebuild spatial partitioning
    spatialTree = new QuadTree(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
    for (IObject e : entities) {
      spatialTree.insert(e);
    }

    // 2. Global Logic Pass (Tier 2 & 3)
    simulationLogic.processRules(entities, spatialTree);

    // 3. Local Entity Updates & Lifecycle
    for (int i = entities.size() - 1; i >= 0; i--) {
      IObject e = entities.get(i);
      e.update();
      
      // Remove dead entities during the update pass
      if (e.isDead()) {
        entities.remove(i);
      }
    }
  }

  /**
   * Decoupled Render Pass: Handles drawing and frustum culling.
   */
  void render() {
    PVector camPos = camera.getPos();
    for (IObject e : entities) {
      // Frustum Culling - Only render if visible
      if (isVisible(e, camPos)) {
        e.render();
      }
    }
  }

  boolean isVisible(IObject e, PVector camPos) {
    if (e instanceof BaseEntity) {
      BaseEntity be = (BaseEntity) e;
      float margin = 100; // Increased margin
      return be.x > camPos.x - margin && 
             be.x < camPos.x + camera.w + margin && 
             be.y > camPos.y - margin && 
             be.y < camPos.y + camera.h + margin;
    }
    return true;
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
