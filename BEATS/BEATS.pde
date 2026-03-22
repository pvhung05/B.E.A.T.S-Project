EventBus systemBus;
EntityManager world;
Controller uiController;
Manager uiManager;
FX_Manager fxManager;
AudioManager audioManager;
boolean isPaused = false;
PVector cameraCenter;
float cameraWidth;
float cameraHeight;
boolean isDraggingCamera = false;
PVector lastMouse = new PVector();


void setup() {
  surface.setTitle("Biological Equilibrium & Trophic Simulator");
  size(1280, 720);
  
  cameraWidth  = width;
  cameraHeight = height;
  cameraCenter = new PVector(width/2, height/2);
  
  UIState.initColors(this);
  Assets.load(this);
  frameRate(60);
  

  // Initialize Global Routing Hub First
  systemBus = new EventBus();
  
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
  
  uiManager.addWidget(new ToggleButton(5, UIState.sidebarY, 30));
  uiManager.addWidget(new Button(UIState.sidebarX,UIState.sidebarY,UIState.buttonW,UIState.buttonH,"Spawn Tool",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(UIState.sidebarX,UIState.sidebarY+(UIState.buttonH+UIState.gap)*1,UIState.buttonW,UIState.buttonH,"Cull Tool",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(UIState.sidebarX,UIState.sidebarY+(UIState.buttonH+UIState.gap)*2,UIState.buttonW,UIState.buttonH,"Temperature",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(UIState.sidebarX,UIState.sidebarY+(UIState.buttonH+UIState.gap)*3,UIState.buttonW,UIState.buttonH,"Pollution",EventType.EVENT_UI_TOOL_SELECTED));
  
  // TODO[@Sys-Design]: Trigger initial EVENT_ENTITY_SPAWN_REQUEST events by parsing data/scenario_01.json.
}

PVector getCameraPos() {
  return new PVector(
    cameraCenter.x - cameraWidth * 0.5f,
    cameraCenter.y - cameraHeight * 0.5f
  );
}

void draw() {
  // TODO[@Architect]: The relationship evaluation loop (Logic) must now publish 
  // EVENT_PHYSICS_COLLISION_ENTER to the systemBus instead of calling managers directly.
  if (isPaused) return;
  
  background(240);
  
  // ========== WORLD-SPACE RENDERING ==========
  // Camera-dependent rendering: entities, effects, particle systems
  // All positions are in world coordinates and adjusted by camera offset
  pushMatrix();
  
  PVector cam = getCameraPos();
  translate(-cam.x, -cam.y);
  

  
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

void displayDebugInfo() {
  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  text("FPS: " + int(frameRate), 20, 20);
  text("Entities: " + world.entities.size(), 20, 40);
}

void keyPressed() {
  if (uiController != null) {
    uiController.handleKeyPressed(key, keyCode);
  }
}

void keyReleased() {
  if (uiController != null) {
    uiController.handleKeyReleased(key, keyCode);
  }
}
