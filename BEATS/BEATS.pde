EventBus systemBus;
EntityManager world;
Controller uiController;
Manager uiManager;
FX_Manager fxManager;
AudioManager audioManager;
boolean isPaused = false;

void setup() {
  surface.setTitle("Biological Equilibrium & Trophic Simulator");
  size(1280, 720);
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
  
  uiManager.addWidget(new ToggleButton(0,70,30));

  uiManager.addWidget(new Button(sidebarX,sidebarY,buttonW,buttonH,"Spawn Tool",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(sidebarX,sidebarY+(buttonH+gap)*1,buttonW,buttonH,"Cull Tool",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(sidebarX,sidebarY+(buttonH+gap)*2,buttonW,buttonH,"Temperature",EventType.EVENT_UI_TOOL_SELECTED));
  uiManager.addWidget(new Button(sidebarX,sidebarY+(buttonH+gap)*3,buttonW,buttonH,"Pollution",EventType.EVENT_UI_TOOL_SELECTED));
  
  // TODO[@Sys-Design]: Trigger initial EVENT_ENTITY_SPAWN_REQUEST events by parsing data/scenario_01.json.
}

void draw() {
  if (isPaused) return;
  
  background(240);
  
  // TODO[@Architect]: The relationship evaluation loop (Logic) must now publish 
  // EVENT_PHYSICS_COLLISION_ENTER to the systemBus instead of calling managers directly.
  
  world.run();
  
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
