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
    
    // 1. UI Handling: Let Manager handle Widgets and SubMenus
    if (uiManager.handleMouseClick(mx, my)) {
      return;
    }
    
    // 2. WORLD-SPACE: Convert screen coordinates to world coordinates
    PVector worldPos = camera.screenToWorld(mx, my);

    // 3. Process world-space interactions (Spawn/Cull)
    IObject clickedObj = world.getObjectAt(worldPos.x, worldPos.y);

    if (clickedObj != null) {
      if (UIState.cullActive) {
         // Publish EVENT_ENTITY_DESTROYED as per EVENT_DICTIONARY.md: [String ID, Float X, Float Y, String Cause]
         String id = clickedObj.getClass().getSimpleName().toUpperCase();
         // Use worldPos as the interaction point
         float targetX = worldPos.x;
         float targetY = worldPos.y;
         
         systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{id, targetX, targetY, "CULL"});
      }
    } 
    else if (clickedObj == null && UIState.selectedSpawn != null) {
      println("Simulation Command: Spawned " + UIState.selectedSpawn + " at " + worldPos);
      systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{UIState.selectedSpawn.name(), worldPos.x, worldPos.y, null}
     );
    }
  }
  
  void handleMouseReleased(float mx, float my, int mButton) {
    uiManager.handleMouseReleased();
  }

  void handleMouseDragged(float mx, float my) {
    uiManager.handleMouseDragged(mx, my);
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
}
