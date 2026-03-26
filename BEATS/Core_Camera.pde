/**
 * Core_Camera.pde
 * Manages the simulation's viewport and coordinate transformations using Processing's matrix system.
 * Refactored to leverage built-in PMatrix2D for precision and decoupling.
 */
class Camera implements IObject {
  PVector center;
  float viewportScale = 1.0f; // 1.0 = 100% zoom level (1 pixel world = 1 pixel screen)
  
  float baseW, baseH;
  float w, h; // Current world-space width/height of viewport
  
  PMatrix2D matrix = new PMatrix2D();
  
  boolean isDragging;
  PVector lastMouse;

  Camera(float startX, float startY, float vW, float vH) {
    center = new PVector(startX, startY);
    baseW = vW;
    baseH = vH;
    isDragging = false;
    lastMouse = new PVector();
    update();
  }

  /**
   * Updates viewport dimensions and recalculates the transformation matrix.
   */
  void update() {
    // World size of the viewport: as we zoom in (scale < 1), we see less of the world
    w = baseW * viewportScale;
    h = baseH * viewportScale;

    // Clamping: Ensure camera doesn't pan outside world boundaries
    if (w >= UIState.WORLD_WIDTH) {
       center.x = UIState.WORLD_WIDTH * 0.5f;
    } else {
       center.x = constrain(center.x, w * 0.5f, UIState.WORLD_WIDTH - w * 0.5f);
    }
    
    if (h >= UIState.WORLD_HEIGHT) {
       center.y = UIState.WORLD_HEIGHT * 0.5f;
    } else {
       center.y = constrain(center.y, h * 0.5f, UIState.WORLD_HEIGHT - h * 0.5f);
    }

    // Recalculate Matrix: Screen = Matrix * World
    // 1. Center the view on screen
    // 2. Scale by inverse of viewportScale (zoom in = larger scale)
    // 3. Offset by negative camera world position
    matrix.reset();
    matrix.translate(baseW / 2.0f, baseH / 2.0f);
    matrix.scale(1.0f / viewportScale);
    matrix.translate(-center.x, -center.y);
  }

  /**
   * Applies the camera's transformation matrix to the current sketch context.
   */
  void apply() {
    applyMatrix(matrix.m00, matrix.m01, matrix.m02, 
                matrix.m10, matrix.m11, matrix.m12);
  }

  /**
   * Calculates the top-left corner of the camera in world space.
   * Useful for frustum culling.
   */
  PVector getPos() {
    return new PVector(center.x - w * 0.5f, center.y - h * 0.5f);
  }

  /**
   * Converts screen coordinates (pixels) to world coordinates.
   * Uses inverted matrix for precision.
   */
  PVector screenToWorld(float sx, float sy) {
    PMatrix2D inv = matrix.get();
    inv.invert();
    return new PVector(inv.multX(sx, sy), inv.multY(sx, sy));
  }

  /**
   * Converts world coordinates to screen coordinates (pixels).
   */
  PVector worldToScreen(float wx, float wy) {
    return new PVector(matrix.multX(wx, wy), matrix.multY(wx, wy));
  }

  void startDrag(float mx, float my) {
    isDragging = true;
    lastMouse.set(mx, my);
  }

  void drag(float mx, float my) {
    if (isDragging) {
      // Delta in screen space, scaled by viewport level to move correctly in world space
      float dx = (mx - lastMouse.x) * viewportScale;
      float dy = (my - lastMouse.y) * viewportScale;
      
      center.x -= dx;
      center.y -= dy;
      
      update();
      lastMouse.set(mx, my);
    }
  }

  void stopDrag() {
    isDragging = false;
  }

  void handleZoom(float count) {
    viewportScale += count * UIState.ZOOM_SPEED;
    
    // Max scale defined by world bounds (cannot zoom out more than world size)
    float maxScale = max(UIState.WORLD_WIDTH / baseW, UIState.WORLD_HEIGHT / baseH);
    viewportScale = constrain(viewportScale, UIState.MIN_SCALE, maxScale);
    update();
  }
  
  // IObject implementation stubs
  void render() { /* Debug markers could go here */ }
  boolean isSelected(float mx, float my) { return false; }
  boolean isDead() { return false; }
}
