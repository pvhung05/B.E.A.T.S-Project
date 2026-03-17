static class Assets{
  static PImage ALGAE;
  static PImage CRAB;
  static PImage SARDINE;
  static PImage SHARK;
  static PImage FISHING;
  
  static void load(PApplet app){
    ALGAE = app.loadImage("assets/algae.png");
    CRAB = app.loadImage("assets/crab.png");
    SARDINE = app.loadImage("assets/sardine.png");
    SHARK = app.loadImage("assets/shark.png");
    FISHING = app.loadImage("assets/fishing.png");
  }
}
