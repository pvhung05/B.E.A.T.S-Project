// UI_Controller.pde
// The Input Bridge: Captures raw input and translates it into simulation commands.

class Controller implements IEventListener {
  Controller() {
    systemBus.subscribe(EventType.EVENT_UI_TOOL_SELECTED, this);
  }

  void onEvent(EventType type, Object payload) {
    if (type == EventType.EVENT_UI_TOOL_SELECTED) {
      // TODO[@UI]: Update UI state machines to reflect the currently selected tool.
    }
  }

  void handleMousePressed(float mx, float my, int mButton) {
  
    if (mButton != LEFT) return;
  
    // 1. Let UI consume first
    if (uiManager.handleMouseClick(mx, my)) {
      return;
    }
  
    // 2. Convert to world-space
    PVector worldPos = screenToWorld(mx, my);
  
    // 3. Cull
    if (UIState.activeMenu == MenuType.CULL) {
      IObject clickedObj = world.getObjectAt(worldPos.x, worldPos.y);
      if (clickedObj != null) {
        systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, clickedObj);
        return;
      }
    }
  
    // 4. Spawn
    if (UIState.selectedSpawn != null) {
      println(
        "Spawned " + UIState.selectedSpawn.name() +
        " at (" + worldPos.x + ", " + worldPos.y + ")"
      );
      
      systemBus.publish(
        EventType.EVENT_ENTITY_SPAWN_REQUEST,
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
      
      SubMenu menu = uiManager.subMenus.get(UIState.activeMenu);
      if (menu != null) {
        menu.handleMouseReleased();
      }
  
    }

  void handleMouseDragged(float mx, float my) {
    
    SubMenu menu = uiManager.subMenus.get(UIState.activeMenu);
    if (menu != null) {
      menu.handleMouseDragged(mx, my);
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

  if (mouseButton == RIGHT) {
    isDraggingCamera = true;
    lastMouse.set(mouseX, mouseY);
    return;
  }

  if (uiController != null) {
    uiController.handleMousePressed(mouseX, mouseY, mouseButton);
  }
}

void mouseReleased() {

  if (mouseButton == RIGHT) {
    isDraggingCamera = false;
  }

  if (uiController != null) {
    uiController.handleMouseReleased(mouseX, mouseY, mouseButton);
  }
}

void mouseDragged() {
  if (uiController != null) {
    uiController.handleMouseDragged(mouseX, mouseY);
  }
  
  if (isDraggingCamera) {

    float dx = mouseX - lastMouse.x;
    float dy = mouseY - lastMouse.y;

    cameraCenter.x -= dx;
    cameraCenter.y -= dy;

    lastMouse.set(mouseX, mouseY);
  }
}
