// UI_Controller.pde
// The Input Bridge: Captures raw input and translates it into simulation commands.

class Controller implements IEventListener {
  Slider activeSlider;

  Controller() {
    systemBus.subscribe(EventType.EVENT_UI_TOOL_SELECTED, this);
  }

  void onEvent(EventType type, Object payload) {
    if (type == EventType.EVENT_UI_TOOL_SELECTED) {
      // TODO[@UI]: Update UI state machines to reflect the currently selected tool.
    }
  }

  void handleMousePressed(float mx, float my, int mButton) {
    // Only process left mouse button (LEFT = 37)
    if (mButton != LEFT) return;
    
    // TODO[@UI]: Bind mouseDragged() to update the X/Y of the currently selected IObject. 
    // Ensure z-index rendering doesn't overlap the generic HUD. Interface ONLY with EntityManager.
    
    // 1. SCREEN-SPACE: Check HUD elements first (Sliders, Buttons)
    if (UIState.activeMenu == MenuType.TEMPERATURE &&
        uiManager.temperatureSlider.isHovered(mx, my)){
      activeSlider = uiManager.temperatureSlider;
      activeSlider.dragging = true;
      return;
    }
  
    if (UIState.activeMenu == MenuType.POLLUTION &&
        uiManager.pollutionSlider.isHovered(mx, my)){
      activeSlider = uiManager.pollutionSlider;
      activeSlider.dragging = true;
      return;
    }
    
    // Check UI widgets (buttons, menu items) - all in screen-space
    if (uiManager.handleMouseClick(mx, my)) {
      return;
    }
    
    // 2. WORLD-SPACE: Convert screen coordinates to world coordinates using camera parameters
    // This accounts for camera pan/zoom by incorporating cameraCenter and viewport dimensions
    PVector worldPos = screenToWorld(mx, my);

    // 3. Process world-space interactions (Spawn/Cull)
    if (UIState.activeMenu == MenuType.CULL) {
      // Find entity at world position
      IObject clickedObj = world.getObjectAt(worldPos.x, worldPos.y);
      if (clickedObj != null) {
        println("Simulation Command: Destroying Object at " + worldPos);
        // Publish EVENT_ENTITY_DESTROYED with the clicked object as payload
        // EntityManager and FX_Manager will listen to this event and handle cleanup/effects
        systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, clickedObj);
        return;
      }
    } 
    
    // Spawn entity at world position
    if (UIState.selectedSpawn != null) {
      println("Simulation Command: Spawned " + UIState.selectedSpawn + " at " + worldPos);
      systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST,
        new Object[]{
          UIState.selectedSpawn.name(),
          worldPos.x,
          worldPos.y,
          null
        }
      );
    }
  }
  void handleMouseReleased(float mx, float my, int mButton) {

    if(activeSlider != null){
      activeSlider.dragging = false;
    }
    activeSlider = null;
  }

  void handleMouseDragged(float mx, float my) {
  
    if (activeSlider != null && activeSlider.dragging) {
  
      activeSlider.value = map(
        mx,
        activeSlider.x + 10,
        activeSlider.x + activeSlider.w - 10,
        activeSlider.minVal,
        activeSlider.maxVal
      );
  
      activeSlider.value = constrain(
        activeSlider.value,
        activeSlider.minVal,
        activeSlider.maxVal
      );
  
      systemBus.publish(
        EventType.EVENT_UI_SLIDER_CHANGED,
        new Object[]{activeSlider.label, activeSlider.value, null, null}
      );
    }
  }
  void handleKeyPressed(int k, int kCode) {
    // Translate raw key press into simulation commands
    if (k == 'c' || k == 'C') {
      println("Simulation Command: Clear World");
      world.entities.clear();
    }
  }

  void handleKeyReleased(int k, int kCode) {
    // Handle key release
  }
  
  // ========== COORDINATE TRANSFORMATION ==========
  // Converts screen-space coordinates (mouse position) to world-space coordinates
  // Required for proper entity interaction when camera is panned/zoomed
  // Formula: world = screen + cameraTopLeft
  // where: cameraTopLeft = cameraCenter - (cameraWidth/2, cameraHeight/2)
  PVector screenToWorld(float sx, float sy) {
    // Calculate camera's top-left corner in world space
    float camPosX = cameraCenter.x - cameraWidth * 0.5f;
    float camPosY = cameraCenter.y - cameraHeight * 0.5f;
  
    // Add camera offset to screen coordinates to get world position
    return new PVector(
      sx + camPosX,
      sy + camPosY
    );
  }
  
  // Inverse transformation: converts world coordinates to screen-space for rendering
  PVector worldToScreen(float wx, float wy) {
    float camPosX = cameraCenter.x - cameraWidth * 0.5f;
    float camPosY = cameraCenter.y - cameraHeight * 0.5f;
    
    return new PVector(
      wx - camPosX,
      wy - camPosY
    );
  }
}

// Processing global input event hooks
// These scatter events are corralled into the Controller bridge.

void mousePressed() {
  if (uiController != null) {
    uiController.handleMousePressed(mouseX, mouseY, mouseButton);
  }
  if (mouseButton == RIGHT) {
    isDraggingCamera = true;
    lastMouse.set(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (mouseButton == RIGHT) {
    isDraggingCamera = false;
  }
}

void mouseDragged() {
  if (isDraggingCamera) {

    float dx = mouseX - lastMouse.x;
    float dy = mouseY - lastMouse.y;

    cameraCenter.x -= dx;
    cameraCenter.y -= dy;

    lastMouse.set(mouseX, mouseY);
  }
}
