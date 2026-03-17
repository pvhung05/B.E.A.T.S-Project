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
    
    IObject clickedObj = world.getObjectAt(mx, my);

    if (clickedObj != null) {
      println("Simulation Command: Selected Object");
      // TODO[@UI]: Publish EVENT_UI_TOOL_SELECTED to the bus.
      systemBus.publish(EventType.EVENT_UI_TOOL_SELECTED, new Object[]{"CULL", null, null, null});
    } 
    else if (clickedObj == null && UIState.selectedSpawn != null) {
      println("Simulation Command: Spawned " + UIState.selectedSpawn);
      systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{UIState.selectedSpawn.name(), mx, my, null}
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

// Processing global input event hooks
// These scatter events are corralled into the Controller bridge.

void mousePressed() {
  if (uiController != null) {
    uiController.handleMousePressed(mouseX, mouseY, mouseButton);
  }
}

void mouseReleased() {
  if (uiController != null) {
    uiController.handleMouseReleased(mouseX, mouseY, mouseButton);
  }
}

void mouseDragged() {
  if (uiController != null) {
    uiController.handleMouseDragged(mouseX, mouseY);
  }
}

void keyPressed() {
  if (uiController != null) uiController.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  if (uiController != null) uiController.handleKeyReleased(key, keyCode);
}
