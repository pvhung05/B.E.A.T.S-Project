/**
 * Core_Camera.pde
 * Manages the simulation's viewport and coordinate transformations.
 * Implements IObject to allow for potential debugging and integration with core loops.
 */
class Camera implements IObject {
  PVector center;
  float w, h;
  float baseW, baseH;
  float viewportScale = 1.0f; // 1.0 = 100% of base resolution
  
  boolean isDragging;
  PVector lastMouse;

  Camera(float startX, float startY, float viewportW, float viewportH) {
    center = new PVector(startX, startY);
    baseW = viewportW;
    baseH = viewportH;
    w = baseW;
    h = baseH;
    isDragging = false;
    lastMouse = new PVector();
  }

  // Calculate the top-left corner of the camera in world space
  PVector getPos() {
    return new PVector(center.x - w * 0.5f, center.y - h * 0.5f);
  }

  void update() {
    // Maintain aspect ratio and update w/h based on scale
    w = baseW * viewportScale;
    h = baseH * viewportScale;

    // Basic clamping to world boundaries
    // Ensure we don't pan out of bounds, but also don't zoom out further than the world size
    float minW = UIState.WORLD_WIDTH;
    float minH = UIState.WORLD_HEIGHT;
    
    // If the camera is larger than the world, center it and disable panning
    if (w > UIState.WORLD_WIDTH) {
       center.x = UIState.WORLD_WIDTH * 0.5f;
    } else {
       center.x = constrain(center.x, w * 0.5f, UIState.WORLD_WIDTH - w * 0.5f);
    }
    
    if (h > UIState.WORLD_HEIGHT) {
       center.y = UIState.WORLD_HEIGHT * 0.5f;
    } else {
       center.y = constrain(center.y, h * 0.5f, UIState.WORLD_HEIGHT - h * 0.5f);
    }
  }

  void render() {
    // Debug view: Draw the camera center or boundaries in screen space if needed
  }

  boolean isSelected(float mx, float my) {
    return false; // Camera itself cannot be selected in the simulation
  }

  boolean isDead() {
    return false; // Camera exists for the duration of the application
  }

  // Coordinate Transformations
  // Formula: world = (screen / screen_dim) * camera_dim + camera_top_left
  // Since Processing's translate() handles the visual mapping, we only need to map 
  // raw screen mouse coords to world coords here.
  PVector screenToWorld(float sx, float sy) {
    PVector pos = getPos();
    // sx/sy are in pixels from 0..width, 0..height.
    // We need to scale these relative to the current camera viewport size.
    float normalizedX = sx / baseW;
    float normalizedY = sy / baseH;
    
    return new PVector(
      pos.x + normalizedX * w,
      pos.y + normalizedY * h
    );
  }

  PVector worldToScreen(float wx, float wy) {
    PVector pos = getPos();
    float normalizedX = (wx - pos.x) / w;
    float normalizedY = (wy - pos.y) / h;
    
    return new PVector(
      normalizedX * baseW,
      normalizedY * baseH
    );
  }

  // Interaction Logic
  void startDrag(float mx, float my) {
    isDragging = true;
    lastMouse.set(mx, my);
  }

  void drag(float mx, float my) {
    if (isDragging) {
      // Dragging needs to be proportional to the zoom level
      float dx = (mx - lastMouse.x) * viewportScale;
      float dy = (my - lastMouse.y) * viewportScale;
      
      center.x -= dx;
      center.y -= dy;
      
      lastMouse.set(mx, my);
    }
  }

  void stopDrag() {
    isDragging = false;
  }

  void handleZoom(float count) {
    // count is negative for scroll up (zoom in), positive for scroll down (zoom out)
    viewportScale += count * UIState.ZOOM_SPEED;
    
    // Clamp zoom: Min zoom, Max zoom (fit world)
    float maxScale = min(UIState.WORLD_WIDTH / baseW, UIState.WORLD_HEIGHT / baseH);
    viewportScale = constrain(viewportScale, UIState.MIN_SCALE, maxScale);
  }
}
