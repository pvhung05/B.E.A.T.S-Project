class EntityManager {
  ArrayList<IObject> entities;
  
  EntityManager() {
    entities = new ArrayList<IObject>();
  }
  
  void addEntity(IObject e) {
    entities.add(e);
  }
  
  void run() {
    // FIXME[@Architect]: Optimize this ArrayList iteration. The current O(N^2) entity interaction check 
    // will bottleneck at >100 entities. Consider spatial partitioning (e.g., QuadTree) for the final build.
    for (int i = entities.size() - 1; i >= 0; i--) {
      IObject e = entities.get(i);
      
      if (e.isDead()) {
        entities.remove(i);
        continue;
      }
      
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
