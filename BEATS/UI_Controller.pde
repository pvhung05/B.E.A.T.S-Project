// UI_Controller.pde
// The Input Bridge: Captures raw input and translates it into simulation commands.

class Controller implements IEventListener {
    PApplet app;

    Controller(PApplet app) {
        this.app = app;
        systemBus.subscribe(EventType.EVENT_UI_TOOL_SELECTED, this);
    }

    void onEvent(EventType type, Object payload) {
     if (type != EventType.EVENT_UI_TOOL_SELECTED) return;
    
        Object[] data = (Object[]) payload;
    
        String toolId = (String) data[0];
    
        println("Selected Tool: " + toolId);
    
        // reset
        UIState.selectedSpawn = null;
        UIState.cullActive = false;
    
        if ("NONE".equals(toolId)) {
            cursor(ARROW);
            return;
        }
    
        if ("CULL".equals(toolId)) {
            UIState.cullActive = true;
            cursor((ImageAssets.FISHING)); // hoặc type mặc định
            return;
        }
    
        // SPAWN_xxx
        if (toolId.startsWith("SPAWN_")) {
            String typeName = toolId.replace("SPAWN_", "");
            SpawnType spawnType = SpawnType.valueOf(typeName);
    
            UIState.selectedSpawn = spawnType;
            cursor(UIState.getSpawnCursor(app, spawnType));
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
        int clickedEntity = world.getObjectAt(worldPos.x, worldPos.y);

        if (UIState.cullActive) {
            if (clickedEntity != -1) {
                CSpecies s = world.coordinator.getComponent(clickedEntity, CSpecies.class);
                CTransform t = world.coordinator.getComponent(clickedEntity, CTransform.class);
                if (s != null && t != null) {
                    systemBus.publish(EventType.EVENT_ENTITY_DESTROYED, new Object[]{s.type.name(), t.x, t.y, "CULL"});
                }
            }
        } else if (clickedEntity == -1 && UIState.selectedSpawn != null) {
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
            for (int i = world.activeEntities.size() - 1; i >= 0; i--) {
                world.destroyEntity(world.activeEntities.get(i));
            }
        }
    } 

    void handleKeyReleased(int k, int kCode) {
        // Handle key release
    }
}
