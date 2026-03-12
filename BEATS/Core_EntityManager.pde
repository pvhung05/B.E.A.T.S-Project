class EntityManager implements IEventListener {
  ArrayList<IObject> entities;
  
  EntityManager() {
    entities = new ArrayList<IObject>();
    // Mandatory Subscriptions
    systemBus.subscribe(EventType.EVENT_ENTITY_SPAWN_REQUEST, this);
    systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
  }
  
  void onEvent(EventType type, Object payload) {
    if (type == EventType.EVENT_ENTITY_SPAWN_REQUEST) {
      // TODO[@Sys-Design]: Parse JSON payload to extract initial spatial coordinates/parameters.
      // Example: entities.add(new BasicEntity(...));
    } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
      // Logic for safe removal
    }
  }
  
  void addEntity(IObject e) {
    entities.add(e);
  }
  
  void run() {
    // FIXME[@Architect]: Optimize this ArrayList iteration. The current O(N^2) entity interaction check 
    // will bottleneck at >100 entities. Consider spatial partitioning (e.g., QuadTree) for the final build.
    for (int i = entities.size() - 1; i >= 0; i--) {
      IObject e = entities.get(i);
            
      e.update();
      e.render();
    }
  }
  
  IObject getObjectAt(float mx, float my) {
    for (IObject e : entities) {
      if (e.isSelected(mx, my)) return e;
    }
    return null;
  }
}
