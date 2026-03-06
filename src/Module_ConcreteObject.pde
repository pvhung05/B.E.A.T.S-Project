// Module_ConcreteObject.pde
// Where all the final classes are defined

class BasicEntity implements IObject {
  // TODO[@Comp-Eng]: Implement update() logic for internal state mutation based on environmental deltas. 
  // DO NOT declare variables outside this class. Handle generic internal state mutation.
  
  float x, y;
  float size;
  boolean dead = false;
  boolean selected = false;
  
  BasicEntity(float x, float y) {
    this.x = x;
    this.y = y;
    this.size = 30;
  }
  
  void update() {
    // Localized logic: e.g., orbit rotation, state degradation, local animation
  }
  
  void render() {
    // TODO[@Tech-Art]: Replace this solid fill() with a procedural lerpColor() driven by the component's 
    // normalized active state. Target 60 FPS.
    
    // TODO[@Comp-Eng]: Concrete objects will process their internal state here.
    
    if (selected) {
      stroke(255, 0, 0);
      strokeWeight(3);
    } else {
      stroke(0);
      strokeWeight(2);
    }
    
    fill(100, 150, 255);
    ellipse(x, y, size, size); // Primitive shape
  }
  
  boolean isSelected(float mx, float my) {
    // Simple radius bounding box check
    float d = dist(x, y, mx, my);
    return d <= size / 2;
  }
  
  boolean isDead() {
    return dead;
  }
  
  void markForDeletion() {
    this.dead = true;
  }
}
