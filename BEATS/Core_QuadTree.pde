class QuadTree {
  float x, y, w, h;
  
  int capacity = 4;
  
  ArrayList<IObject> points;
  
  QuadTree nw, ne, sw, se;
  boolean divided = false;

  QuadTree(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.points = new ArrayList<IObject>();
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

  boolean insert(IObject obj) {
    if (!(obj instanceof Entity)) return false;
    Entity entity = (Entity) obj;
    CTransform t = entity.getComponent(CTransform.class);
    if (t == null) return false;

    if (!contains(t.x, t.y)) {
      return false;
    }

    if (points.size() < capacity) {
      points.add(obj);
      return true;
    } else {
      if (!divided) {
        subdivide();
      }
      
      if (nw.insert(obj)) return true;
      if (ne.insert(obj)) return true;
      if (sw.insert(obj)) return true;
      if (se.insert(obj)) return true;
    }
    return false;
  }

  boolean contains(float px, float py) {
    return (px >= x && px < x + w && py >= y && py < y + h);
  }

  /**
   * Query the QuadTree for all entities within a circular range.
   */
  void query(float cx, float cy, float cr, ArrayList<IObject> found) {
    if (!intersectsCircle(cx, cy, cr)) {
      return;
    }

    for (IObject p : points) {
      if (!(p instanceof Entity)) continue;
      Entity e = (Entity) p;
      CTransform t = e.getComponent(CTransform.class);
      if (t == null) continue;
      float dSq = (t.x - cx) * (t.x - cx) + (t.y - cy) * (t.y - cy);
      if (dSq <= cr * cr) {
        found.add(p);
      }
    }

    if (divided) {
      nw.query(cx, cy, cr, found);
      ne.query(cx, cy, cr, found);
      sw.query(cx, cy, cr, found);
      se.query(cx, cy, cr, found);
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
