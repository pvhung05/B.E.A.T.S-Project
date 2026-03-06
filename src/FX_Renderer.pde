// FX_Renderer.pde
// The Aesthetics: Applies procedural "juice" (glows, particles, aesthetic layers) to objects.

class Renderer {
  // TODO[@Tech-Art]: Enforce procedural math for visuals. Map visual output (color gradients, 
  // particle emission rates) to normalized state values (0.0 to 1.0) provided by the components. 
  // Explicitly ban PImage.
  
  boolean highGraphicsEnabled = true;
  
  Renderer() {
  }
  
  // Example of a procedural visual effect
  void renderGlow(float x, float y, float radius, color c) {
    if (!highGraphicsEnabled) return; // Respect the performance toggle
    
    noStroke();
    // Layered semi-transparent circles create a procedural glow effect
    for (int i = 0; i < 5; i++) {
      fill(red(c), green(c), blue(c), 40 - i * 8);
      ellipse(x, y, radius + i * 10, radius + i * 10);
    }
  }
  
  void renderGlobalParticles() {
    if (!highGraphicsEnabled) return;
    
    // Draw global weather, ambient dust, or screen-space effects here
  }
  
  void toggleGraphics() {
    highGraphicsEnabled = !highGraphicsEnabled;
    println("Renderer: High Graphics is now " + (highGraphicsEnabled ? "ON" : "OFF"));
  }
}
