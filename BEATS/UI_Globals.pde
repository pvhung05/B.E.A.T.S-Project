
static class UIState {

    static boolean sidebarOpen = false;
    static boolean cullActive = false;
    static MenuType activeMenu = MenuType.NONE;
    static SpawnType selectedSpawn = null;

    static float sidebarX = 40;
    static float sidebarY = 70;

    static float buttonW = 160;
    static float buttonH = 30;
    static float gap = 2;

    static float temperature = 20;
    static float pollution = 10;

    // Environment Logic thresholds
    static float OPTIMAL_TEMP_MIN = 16.0;
    static float OPTIMAL_TEMP_MAX = 26.0;
    static float POLLUTION_STRESS_THRESHOLD = 38.0;

    // Camera settings
    static float ZOOM_SPEED = 0.05;
    static float MIN_SCALE = 0.25;

    // World Simulation Boundaries
    static float WORLD_WIDTH = 1280 * 3;
    static float WORLD_HEIGHT = 720 * 3;

    static int MENU_BG;
    static int MENU_HOVER;
    static int MENU_TEXT;

    static void loadConfig(PApplet app, JSONObject json) {
        // World dimensions
        JSONObject world = json.getJSONObject("world");
        JSONObject dims = world.getJSONObject("dimensions");
        WORLD_WIDTH = dims.getFloat("width");
        WORLD_HEIGHT = dims.getFloat("height");

        // Initial Parameters
        JSONObject initParams = world.getJSONObject("initialParameters");
        temperature = initParams.getFloat("temperature");
        pollution = initParams.getFloat("pollution");

        // Environment logic thresholds
        JSONObject envLogic = json.getJSONObject("environmentLogic");
        OPTIMAL_TEMP_MIN = envLogic.getFloat("optimalTempMin");
        OPTIMAL_TEMP_MAX = envLogic.getFloat("optimalTempMax");
        POLLUTION_STRESS_THRESHOLD = envLogic.getFloat("pollutionStressThreshold");

        // Camera settings
        JSONObject camera = json.getJSONObject("camera");
        ZOOM_SPEED = camera.getFloat("zoomSpeed");
        MIN_SCALE = camera.getFloat("minScale");

        // UI Layout
        JSONObject ui = json.getJSONObject("ui");
        JSONObject layout = ui.getJSONObject("layout");
        sidebarX = layout.getFloat("sidebarX");
        sidebarY = layout.getFloat("sidebarY");
        buttonW = layout.getFloat("buttonW");
        buttonH = layout.getFloat("buttonH");
        gap = layout.getFloat("gap");

        // UI Colors
        JSONObject colors = ui.getJSONObject("colors");
        JSONArray bg = colors.getJSONArray("menuBg");
        JSONArray hover = colors.getJSONArray("menuHover");
        JSONArray text = colors.getJSONArray("menuText");

        MENU_BG = app.color(bg.getInt(0), bg.getInt(1), bg.getInt(2));
        MENU_HOVER = app.color(hover.getInt(0), hover.getInt(1), hover.getInt(2));
        MENU_TEXT = app.color(text.getInt(0), text.getInt(1), text.getInt(2));
    }

    static void initColors(PApplet app) {
        // Fallback if loadConfig wasn't called
        if (MENU_BG == 0) {
            MENU_BG = app.color(37, 37, 38);
            MENU_HOVER = app.color(62, 62, 64);
            MENU_TEXT = app.color(220);
        }
    }

    static PImage getSpawnCursor(SpawnType type) {
        switch(type) {
        case ALGAE:
            return ImageAssets.ALGAE;
        case CRAB:
            return ImageAssets.CRAB;
        case SARDINE:
            return ImageAssets.SARDINE;
        case SHARK:
            return ImageAssets.SHARK;
        }
        return null;
    }
    static PImage getCullCursor(CullType type) {
        switch(type) {
        case FISHING:
            return ImageAssets.FISHING;
        }
        return null;
    }
}

enum MenuType {
    NONE,
        SPAWN,
        CULL,
        TEMPERATURE,
        POLLUTION
}

enum SpawnType {
    ALGAE,
        CRAB,
        SARDINE,
        SHARK
}

enum CullType {
    FISHING
}
