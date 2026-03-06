EntityManager world;
Controller uiController;
Manager uiManager;
Logic logicEngine;
Renderer fxRenderer;

void setup() {
  size(1280, 720); 
  frameRate(60);   
  
  // TODO[@Sys-Design]: Define the JSON schema for this entity's initial parameters and extract 
  // instantiation logic to parse from data/scenario_01.json.
  
  world = new EntityManager();
  logicEngine = new Logic();
  fxRenderer = new Renderer();

  uiController = new Controller();
  uiManager = new Manager();
  
  uiManager.addWidget(new Button(20, 70, 150, 40, "Toggle FX"));
  
  // waiting requirement description
}

void draw() {
  background(240);
  
  logicEngine.processRules(world.entities);
  
  fxRenderer.renderGlobalParticles();
  
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
