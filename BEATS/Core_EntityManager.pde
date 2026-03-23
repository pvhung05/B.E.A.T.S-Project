class EntityManager implements IEventListener {
  ArrayList<IObject> entities;
  QuadTree spatialTree;

  EntityManager() {
    entities = new ArrayList<IObject>();
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

      if (entityId.equals("CRAB")) {
        entities.add(new Crab(x, y, 20.0f)); // Starting energy 20
      } else if (entityId.equals("ALGAE")) {
        entities.add(new Algae(x, y, 10.0f, 40.0f, 0.0f, 0.3f)); 
      }
      // TODO: Add cases for SARDINE and SHARK
    } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
      // Logic for safe removal
    }
  }

  void addEntity(IObject e) {
    entities.add(e);
  }

  void run() {
    // Rebuild the spatial tree every frame to reflect updated positions
    // Task 2.2: Initialize the QuadTree with full world dimensions instead of screen dimensions
    spatialTree = new QuadTree(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);

    // First pass: Add all entities to the spatial tree
    for (IObject e : entities) {
      spatialTree.insert(e);
    }

    // Second pass: Update and Render
    PVector camPos = camera.getPos();
    for (int i = entities.size() - 1; i >= 0; i--) {
      IObject e = entities.get(i);
      
      // Mandatory update for all entities
      e.update();

      // Task 3.2: Frustum Culling - Only render if visible
      // Use a default radius of 30 for the check if the entity doesn't provide one
      if (isVisible(e, camPos)) {
        e.render();
      }

      // Clean up dead entities
      if (e.isDead()) {
        entities.remove(i);
      }
    }
  }

  /**
   * Task 3.1: Helper to check if an entity is within the camera's viewport.
   */
  boolean isVisible(IObject e, PVector camPos) {
    // Assuming entities are BaseEntities with x, y coordinates
    if (e instanceof BaseEntity) {
      BaseEntity be = (BaseEntity) e;
      float margin = 50; // Buffer for entity size
      return be.x > camPos.x - margin && 
             be.x < camPos.x + camera.w + margin && 
             be.y > camPos.y - margin && 
             be.y < camPos.y + camera.h + margin;
    }
    return true; // Render by default if type is unknown
  }

  /**
   * High-performance spatial query using the QuadTree.
   * Use this for schooling, hunting, and collision detection.
   */
  ArrayList<IObject> getEntitiesInRange(float x, float y, float radius) {
    ArrayList<IObject> results = new ArrayList<IObject>();
    if (spatialTree != null) {
      spatialTree.query(x, y, radius, results);
    }
    return results;
  }

  IObject getObjectAt(float mx, float my) {
    // Optimization: Use QuadTree to find objects at coordinates instead of O(N) loop
    ArrayList<IObject> potential = getEntitiesInRange(mx, my, 5.0f); // Small 5px radius for clicking
    for (IObject e : potential) {
      if (e.isSelected(mx, my)) return e;
    }
    return null;
  }
}

