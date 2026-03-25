class Rectangle {
  float x, y, w, h;
  Rectangle(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }
  boolean contains(IObject p) {
    return (p.getX() >= x - w && p.getX() < x + w &&
            p.getY() >= y - h && p.getY() < y + h);
  }
  boolean intersects(Rectangle range) {
    return !(range.x - range.w > x + w ||
             range.x + range.w < x - w ||
             range.y - range.h > y + h ||
             range.y + range.h < y - h);
  }
}

class QuadTree {
  Rectangle boundary;
  int capacity;
  ArrayList<IObject> points;
  boolean divided;
  QuadTree northeast, northwest, southeast, southwest;

  QuadTree(Rectangle boundary, int capacity) {
    this.boundary = boundary;
    this.capacity = capacity;
    this.points = new ArrayList<IObject>();
    this.divided = false;
  }

  void insert(IObject p) {
    if (!boundary.contains(p)) return;
    if (points.size() < capacity && !divided) {
      points.add(p);
    } else {
      if (!divided) subdivide();
      northeast.insert(p);
      northwest.insert(p);
      southeast.insert(p);
      southwest.insert(p);
    }
  }

  void subdivide() {
    float x = boundary.x;
    float y = boundary.y;
    float w = boundary.w / 2;
    float h = boundary.h / 2;
    northeast = new QuadTree(new Rectangle(x + w, y - h, w, h), capacity);
    northwest = new QuadTree(new Rectangle(x - w, y - h, w, h), capacity);
    southeast = new QuadTree(new Rectangle(x + w, y + h, w, h), capacity);
    southwest = new QuadTree(new Rectangle(x - w, y + h, w, h), capacity);
    divided = true;
    for (IObject p : points) {
      northeast.insert(p); northwest.insert(p); southeast.insert(p); southwest.insert(p);
    }
    points.clear();
  }

  ArrayList<IObject> query(Rectangle range, ArrayList<IObject> found) {
    if (found == null) found = new ArrayList<IObject>();
    if (!boundary.intersects(range)) return found;
    for (IObject p : points) {
      if (range.contains(p)) found.add(p);
    }
    if (divided) {
      northwest.query(range, found);
      northeast.query(range, found);
      southwest.query(range, found);
      southeast.query(range, found);
    }
    return found;
  }
}
