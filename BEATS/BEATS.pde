EventBus systemBus;
EntityManager world;
Camera camera;
ConfigLoader configLoader;
Controller uiController;
Manager uiManager;
FX_Manager fxManager;
AudioManager audioManager;
boolean isPaused = false;

void setup() {
  surface.setTitle("Biological Equilibrium & Trophic Simulator");
  size(1280, 720);
  
  UIState.initColors(this);
  Assets.load(this);
  frameRate(60);

  // --- BEGIN NEW CONFIG LOADING ---
  try {
    JSONObject config = loadJSONObject("data/config.json");
    
    // 1. Load UI and Global Params
    UIState.loadConfig(this, config);
    
    // 2. Adjust frame rate from config
    JSONObject appCfg = config.getJSONObject("app");
    frameRate(appCfg.getInt("frameRate"));

    // 3. Initialize Factory with species list
    JSONObject registry = config.getJSONObject("registry");
    EntityFactory.init(this, registry.getJSONArray("speciesList"));
    
    // 4. Load Initial Scenario
    loadScenario("data/init/scenarios/scenario_mvp.json");
    
  } catch (Exception e) {
    println("Critical Config Error: " + e.getMessage());
    // Fallback if config is missing
    EntityFactory.init(this, new JSONArray().append("shark").append("crab").append("algae").append("sardine"));
  }
  // --- END NEW CONFIG LOADING ---

  // Initialize Global Routing Hub First
  systemBus = new EventBus();

  configLoader = new ConfigLoader();

  // Initialize Global Camera
  camera = new Camera(UIState.WORLD_WIDTH/2, UIState.WORLD_HEIGHT/2, width, height);
  
  // Initialize Subscribers (Subscribers handle their own bus registration in constructors)
  world = new EntityManager();
  uiController = new Controller();
  uiManager = new Manager();
  fxManager = new FX_Manager();
  audioManager = new AudioManager();
  
  // src.pde acts as the Application Orchestrator
  systemBus.subscribe(EventType.EVENT_APP_PAUSE, new IEventListener() {
    void onEvent(EventType type, Object payload) {
      isPaused = true;
    }
  });
  systemBus.subscribe(EventType.EVENT_APP_RESUME, new IEventListener() {
    void onEvent(EventType type, Object payload) {
      isPaused = false;
    }
  });
}

void loadScenario(String path) {
  try {
    JSONObject scenario = loadJSONObject(path);
    JSONArray spawns = scenario.getJSONArray("spawns");
    
    for (int i = 0; i < spawns.size(); i++) {
        JSONObject s = spawns.getJSONObject(i);
        String species = s.getString("species");
        int count = s.getInt("count");
        float energy = s.hasKey("initialEnergy") ? s.getFloat("initialEnergy") : 1.0f;
        
        // Default to full world if no region specified
        float spawnX = 50, spawnY = 50;
        float spawnW = UIState.WORLD_WIDTH - 100;
        float spawnH = UIState.WORLD_HEIGHT - 100;
        
        if (s.hasKey("region")) {
            JSONObject reg = s.getJSONObject("region");
            spawnX = reg.getFloat("x") * UIState.WORLD_WIDTH;
            spawnY = reg.getFloat("y") * UIState.WORLD_HEIGHT;
            spawnW = reg.getFloat("w") * UIState.WORLD_WIDTH;
            spawnH = reg.getFloat("h") * UIState.WORLD_HEIGHT;
        }
        
        for (int n = 0; n < count; n++) {
            float rx = random(spawnX, spawnX + spawnW);
            float ry = random(spawnY, spawnY + spawnH);
            systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{species, rx, ry, energy});
        }
    }
  } catch (Exception e) {
    println("Scenario Loading Error: " + e.getMessage());
  }
}

void draw() {
  if (isPaused) return;
  
  background(240);
  
  camera.update();
  
  // ========== WORLD-SPACE RENDERING ==========
  // Camera-dependent rendering: entities, effects, particle systems
  // All positions are in world coordinates and adjusted by camera offset
  pushMatrix();
  
  // Apply Zoom: Scale world to fit screen dimensions
  scale(camera.baseW / camera.w);
  
  PVector camPos = camera.getPos();
  translate(-camPos.x, -camPos.y);
  
  // Verification Object: Large World-Space Reference (Fixed at world center)
  drawWorldMarkers();
  
  world.run();
  fxManager.run();
  
  popMatrix();
  
  // ========== SCREEN-SPACE RENDERING ==========
  // Camera-independent rendering: UI, HUD, overlays
  // All positions are in screen coordinates (0,0 = top-left of viewport)
  // This ensures Toolbar, Buttons, and Sliders always stay pinned to screen
  uiManager.render();
  
  displayDebugInfo();
}

void drawWorldMarkers() {
  pushStyle();
  stroke(200);
  strokeWeight(5);
  noFill();
  
  // Draw large cross across the entire world center
  float midX = UIState.WORLD_WIDTH / 2;
  float midY = UIState.WORLD_HEIGHT / 2;
  float size = 500;
  
  line(midX - size, midY - size, midX + size, midY + size);
  line(midX + size, midY - size, midX - size, midY + size);
  rect(midX - size, midY - size, size * 2, size * 2);
  
  // World Boundaries
  stroke(255, 0, 0);
  rect(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
  popStyle();
}

void displayDebugInfo() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  text("FPS: " + int(frameRate), 20, 20);
  text("Entities: " + world.entities.size(), 20, 40);
  text("Cam Center: " + nfc(camera.center.x, 1) + ", " + nfc(camera.center.y, 1), 20, 60);
  text("Cam Size: " + int(camera.w) + " x " + int(camera.h) + " (" + nfc(1.0/camera.viewportScale, 2) + "x)", 20, 80);
}

// Processing global input event hooks
// These scatter events are corralled into the Controller bridge.

void mousePressed() {
  if (uiController != null) {
    uiController.handleMousePressed(mouseX, mouseY, mouseButton);
  }
  
  if (mouseButton == RIGHT) {
    camera.startDrag(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (uiController != null) {
    uiController.handleMouseReleased(mouseX, mouseY, mouseButton);
  }
  
  if (mouseButton == RIGHT) {
    camera.stopDrag();
  }
}

void mouseDragged() {
  if (camera != null && camera.isDragging) {
    camera.drag(mouseX, mouseY);
  } else if (uiController != null) {
    uiController.handleMouseDragged(mouseX, mouseY);
  }
}

void mouseWheel(MouseEvent event) {
  if (camera != null) {
    camera.handleZoom(event.getCount());
  }
}

void keyPressed() {
  if (uiController != null) uiController.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  if (uiController != null) uiController.handleKeyReleased(key, keyCode);
}
