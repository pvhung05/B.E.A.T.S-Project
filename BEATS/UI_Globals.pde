
static class UIState {

  static boolean sidebarOpen = false;
  static boolean cullToolActive = false;

  static MenuType activeMenu = MenuType.NONE;
  static SpawnType selectedSpawn = null;

  static float sidebarX = 40;
  static float sidebarY = 70;

  static float buttonW = 160;
  static float buttonH = 30;
  static float gap = 2;

  static float temperature = 20;
  static float pollution = 10;

  static int MENU_BG;
  static int MENU_HOVER;
  static int MENU_TEXT;

  static void initColors(PApplet app){
    MENU_BG = app.color(37,37,38);
    MENU_HOVER = app.color(62,62,64);
    MENU_TEXT = app.color(220);
  }
  
  static PImage getSpawnCursor(SpawnType type){
    switch(type){
      case ALGAE: return Assets.ALGAE;
      case CRAB: return Assets.CRAB;
      case SARDINE: return Assets.SARDINE;
      case SHARK: return Assets.SHARK;
    }
    return null;
  }
}

enum MenuType{
  NONE,
  SPAWN,
  CULL,
  TEMPERATURE,
  POLLUTION
}

enum SpawnType{
  ALGAE,
  CRAB,
  SARDINE,
  SHARK
}
