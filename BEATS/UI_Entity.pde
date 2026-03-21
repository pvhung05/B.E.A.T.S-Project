// UI_Entity.pde
// Renderer của frontend cho tất cả entity

class UI_Entity {

  void render(PVector pos, SpawnType type){
    PVector size = getSize(type);
    int col = getColor(type);

    rectMode(CENTER);
    noStroke();
    fill(col);
    rect(pos.x, pos.y, size.x, size.y);
  }

  boolean hitTest(PVector pos, SpawnType type, float mx, float my){
    PVector size = getSize(type);

    return mx >= pos.x - size.x/2 &&
           mx <= pos.x + size.x/2 &&
           my >= pos.y - size.y/2 &&
           my <= pos.y + size.y/2;
  }

  private int getColor(SpawnType type){
    switch(type){
      case ALGAE:   return color(0, 200, 0);
      case CRAB:    return color(200, 0, 0);
      case SARDINE: return color(150);
      case SHARK:   return color(0, 140, 200);
    }
    return color(255);
  }

  private PVector getSize(SpawnType type){
    switch(type){
      case ALGAE:   return new PVector(8, 8);
      case CRAB:    return new PVector(16, 12);
      case SARDINE: return new PVector(20, 6);
      case SHARK:   return new PVector(36, 14);
    }
    return new PVector(10, 10);
  }
}
