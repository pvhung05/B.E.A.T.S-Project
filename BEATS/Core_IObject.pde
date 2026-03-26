interface IObject {
  // TODO[@Core]: Concrete implementations must use Processing native primitives (rect(), ellipse()). 
  // Explicitly ban the use of global variables. Handle generic internal state mutation 
  // (e.g., scalar values for energy, mass, or velocity).
  
  void update();
  
  void render();
  
  boolean isSelected(float mx, float my);
  
  boolean isDead();
}
