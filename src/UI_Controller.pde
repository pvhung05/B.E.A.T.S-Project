// UI_Controller.pde
// The Input Bridge: Captures raw input and translates it into simulation commands.

class Controller {

  Controller() {
  }

  void handleMousePressed(float mx, float my, int mButton) {
    // TODO[@UI]: Bind mouseDragged() to update the X/Y of the currently selected IObject. 
    // Ensure z-index rendering doesn't overlap the generic HUD. Interface ONLY with EntityManager.
    
    if (uiManager.handleMouseClick(mx, my)) {
      return;
    }

    IObject clickedObj = world.getObjectAt(mx, my);

    if (clickedObj != null) {
      println("Simulation Command: Selected Object");
      // Handle selection logic here
    } else {
      println("Simulation Command: Spawned Object");
      // Example integration: spawn a concrete sandbox item
      world.addEntity(new BasicEntity(mx, my));
    }
  }

  void handleMouseReleased(float mx, float my, int mButton) {
    // Handle release
  }

  void handleMouseDragged(float mx, float my) {
    // Handle dragging objects or camera
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
  if (uiController != null) uiController.handleMousePressed(mouseX, mouseY, mouseButton);
}

void mouseReleased() {
  if (uiController != null) uiController.handleMouseReleased(mouseX, mouseY, mouseButton);
}

void mouseDragged() {
  if (uiController != null) uiController.handleMouseDragged(mouseX, mouseY);
}

void keyPressed() {
  if (uiController != null) uiController.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  if (uiController != null) uiController.handleKeyReleased(key, keyCode);
}
