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
    // TODO[@UI]: Bind mouseDragged() to update the X/Y of the currently selected IObject. 
    // Ensure z-index rendering doesn't overlap the generic HUD. Interface ONLY with EntityManager.
    
    if (UIState.activeMenu == MenuType.TEMPERATURE &&
        uiManager.temperatureSlider.isHovered(mx,my)){
  
      activeSlider = uiManager.temperatureSlider;
      activeSlider.dragging = true;
      return;
    }
  
    if (UIState.activeMenu == MenuType.POLLUTION &&
        uiManager.pollutionSlider.isHovered(mx,my)){
  
      activeSlider = uiManager.pollutionSlider;
      activeSlider.dragging = true;
      return;
    }
    
    if (uiManager.handleMouseClick(mx, my)) {
      return;
    }
    
    // 2. WORLD-SPACE: Convert screen coordinates to world coordinates
    PVector worldPos = camera.screenToWorld(mx, my);

    // 3. Process world-space interactions (Spawn/Cull)
    IObject clickedObj = world.getObjectAt(worldPos.x, worldPos.y);

    if (clickedObj != null) {
      println("Simulation Command: Selected Object");
      // TODO[@UI]: Publish EVENT_UI_TOOL_SELECTED to the bus.
      systemBus.publish(EventType.EVENT_UI_TOOL_SELECTED, new Object[]{"CULL", null, null, null});
    } 
    else if (clickedObj == null && UIState.selectedSpawn != null) {
      println("Simulation Command: Spawned " + UIState.selectedSpawn + " at " + worldPos);
      systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{UIState.selectedSpawn.name(), worldPos.x, worldPos.y, null}
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
}
