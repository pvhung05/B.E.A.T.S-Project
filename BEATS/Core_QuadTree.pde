class QuadTree {
  float x, y, w, h;
  
  int capacity = 4;
  
  ArrayList<Integer> points;
  
  QuadTree nw, ne, sw, se;
  boolean divided = false;

  QuadTree(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.points = new ArrayList<Integer>();
  }

  void subdivide() {
    float hw = w / 2;
    float hh = h / 2;
    
    nw = new QuadTree(x, y, hw, hh);
    ne = new QuadTree(x + hw, y, hw, hh);
    sw = new QuadTree(x, y + hh, hw, hh);
    se = new QuadTree(x + hw, y + hh, hw, hh);
    
    divided = true;
  }

  boolean insert(Coordinator coordinator, int entity) {
    CTransform t = coordinator.getComponent(entity, CTransform.class);
    if (t == null) return false;

    if (!contains(t.x, t.y)) {
      return false;
    }

    if (points.size() < capacity) {
      points.add(entity);
      return true;
    } else {
      if (!divided) {
        subdivide();
      }
      
      if (nw.insert(coordinator, entity)) return true;
      if (ne.insert(coordinator, entity)) return true;
      if (sw.insert(coordinator, entity)) return true;
      if (se.insert(coordinator, entity)) return true;
    }
    return false;
  }

  boolean contains(float px, float py) {
    return (px >= x && px < x + w && py >= y && py < y + h);
  }

  /**
   * Query the QuadTree for all entities within a circular range.
   */
  void query(Coordinator coordinator, float cx, float cy, float cr, ArrayList<Integer> found) {
    if (!intersectsCircle(cx, cy, cr)) {
      return;
    }

    for (int entity : points) {
      CTransform t = coordinator.getComponent(entity, CTransform.class);
      if (t == null) continue;
      float dSq = (t.x - cx) * (t.x - cx) + (t.y - cy) * (t.y - cy);
      if (dSq <= cr * cr) {
        found.add(entity);
      }
    }

    if (divided) {
      nw.query(coordinator, cx, cy, cr, found);
      ne.query(coordinator, cx, cy, cr, found);
      sw.query(coordinator, cx, cy, cr, found);
      se.query(coordinator, cx, cy, cr, found);
    }
  }

  boolean intersectsCircle(float cx, float cy, float cr) {
    float closestX = Math.max(x, Math.min(cx, x + w));
    float closestY = Math.max(y, Math.min(cy, y + h));

    float distanceX = cx - closestX;
    float distanceY = cy - closestY;

    return (distanceX * distanceX + distanceY * distanceY) <= (cr * cr);
  }
}
