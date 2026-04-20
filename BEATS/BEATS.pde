EventBus systemBus;
Camera camera;
GameMenu gameMenu;
EntityManager world;
EntityFactory entityFactory;
EntityRenderer entityRenderer;

Controller uiController;
Manager uiManager;

FX_Manager fxManager;
AudioManager audioManager;
PopulationGraphs popGraphs;

boolean isPaused = false;

void settings()
{
    fullScreen(P3D);
}

void setup() {
    surface.setTitle("Biological Equilibrium & Trophic Simulator");

    UIState.initColors(this);
    ImageAssets.load(this);

    // 1. Initialize Global Routing Hub First
    systemBus = new EventBus();
    int targetFrameRate = 60;
    // 2. Initialize Config Loader (PR 33 static)
    ConfigLoader.init(this);

    // 3. Load Global Configuration (PR 34)
    try {
        JSONObject config = loadJSONObject("data/config.json");
        UIState.loadConfig(this, config);
        JSONObject appCfg = config.getJSONObject("app");
        targetFrameRate = appCfg.getInt("frameRate");
    }
    catch (Exception e) {
        println("Critical Config Error: " + e.getMessage());
    }

    // 4. Initialize Global Camera
    camera = new Camera(UIState.WORLD_WIDTH/2, UIState.WORLD_HEIGHT/2, width, height);

    // 5. Initialize Managers
    entityRenderer = new EntityRenderer();
    entityFactory = new EntityFactory();
    world = new EntityManager();
    uiController = new Controller(this);
    uiManager = new Manager();
    fxManager = new FX_Manager();
    audioManager = new AudioManager();
    popGraphs = new PopulationGraphs();

    // 6. Load Initial Scenario (Triggers Spawns via systemBus)
    loadScenario("data/init/scenarios/scenario_01.json");
    
    // 7. Initialize menu when press ESC
    gameMenu = new GameMenu();
    gameMenu.init();

    // App orchestration subscriptions
    systemBus.subscribe(EventType.EVENT_APP_PAUSE, new IEventListener() {
        void onEvent(EventType type, Object payload) {
            isPaused = true;
        }
    }
    );
    systemBus.subscribe(EventType.EVENT_APP_RESUME, new IEventListener() {
        void onEvent(EventType type, Object payload) {
            isPaused = false;
        }
    }
    );

    frameRate(targetFrameRate);

    println("Setup Done");
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
    }
    catch (Exception e) {
        println("Scenario Loading Error: " + e.getMessage());
    }
}

void draw() {
    // Clear background with solid color first
    background(240);

    // Update camera state (clamping, matrix recalculation)
    // Update logic
    if (!isPaused) {  
        world.update();
        fxManager.update();
    }
    // World-space rendering
    pushMatrix();
    camera.apply(g);
    
    // Draw background image in world space
    if (ImageAssets.BACKGROUND != null) {
        // When zoomed out to minimum (viewportScale >= 14.3), fill viewport
        if (camera.viewportScale >= 14.3f) {
            // Fill full viewport
            image(ImageAssets.BACKGROUND, 0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);
        } else {
            // Center mode (normal zoom)
            float bgRatio = (float)ImageAssets.BACKGROUND.width / ImageAssets.BACKGROUND.height;
            float worldRatio = UIState.WORLD_WIDTH / UIState.WORLD_HEIGHT;
            
            float drawWidth, drawHeight;
            float offsetX = 0, offsetY = 0;
            
            if (bgRatio > worldRatio) {
                // Background is wider than world - fit to height
                drawHeight = UIState.WORLD_HEIGHT;
                drawWidth = drawHeight * bgRatio;
                offsetX = (UIState.WORLD_WIDTH - drawWidth) / 2;
            } else {
                // Background is taller than world - fit to width
                drawWidth = UIState.WORLD_WIDTH;
                drawHeight = drawWidth / bgRatio;
                offsetY = (UIState.WORLD_HEIGHT - drawHeight) / 2;
            }
            
            // Center the background image
            image(ImageAssets.BACKGROUND, offsetX, offsetY, drawWidth, drawHeight);
        }
    }
    
    entityRenderer.render(world.coordinator, world.activeEntities, camera);
    // For test camera only, look like we got a race condition with global matrix stack 
    // if we try to zoom early on at the beginning
    // drawWorldMarkers(); 
    fxManager.render();
    popMatrix();

    // screen-space redering
    uiManager.render();
    gameMenu.render();
    if (!isPaused) {
        popGraphs.update(world);
    }
    popGraphs.render();
    displayDebugInfo();
}

void drawWorldMarkers() {
    pushStyle();
    strokeWeight(5);
    noFill();

    stroke(255, 0, 0);
    rect(0, 0, UIState.WORLD_WIDTH, UIState.WORLD_HEIGHT);


    stroke(200);
    float midX = UIState.WORLD_WIDTH / 2;
    float midY = UIState.WORLD_HEIGHT / 2;
    float size = 500;

    line(midX - size, midY - size, midX + size, midY + size);
    line(midX + size, midY - size, midX - size, midY + size);
    rect(midX - size, midY - size, size * 2, size * 2);

    popStyle();
}

void displayDebugInfo() {
    fill(0);
    textAlign(LEFT, BOTTOM);
    textSize(14);
    text("FPS: " + int(frameRate), 20, 20);
    text("Entities: " + world.activeEntities.size(), 20, 40);
    text("Cam Center: " + nfc(camera.center.x, 1) + ", " + nfc(camera.center.y, 1), 20, 60);
    text("Viewport Scale: " + nfc(1.0/camera.viewportScale, 2) + "x", 20, 80);
}

void mousePressed() {
    if (gameMenu.isVisible()) {
        gameMenu.handleMousePressed();
        return; 
    }

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
    gameMenu.handleMouseReleased();
}

void mouseDragged() {
    if (gameMenu.isVisible()) {
        return; 
    }

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
  if (key == ESC) {
        key = 0; 
        gameMenu.togglePause();
        return;
    }

    if (uiController != null) {
        uiController.handleKeyPressed(key, keyCode);
    }
}

void keyReleased() {
    if (uiController != null) uiController.handleKeyReleased(key, keyCode);
}
