static class ImageAssets {
    static PImage ALGAE;
    static PImage CRAB;
    static PImage SARDINE;
    static PImage SHARK;
    static PImage FISHING;
    // TODO: @[UI] you may need to load SFX or Music too, so refactor the name 
    // so that it have format, or rename the class to ImageAssets instead, 
    // and have AudioAssets class for sfx/music purpose
    static void load(PApplet app) {
        ALGAE = app.loadImage("assets/algae.png");
        CRAB = app.loadImage("assets/crab.png");
        SARDINE = app.loadImage("assets/sardine.png");
        SHARK = app.loadImage("assets/shark.png");
        FISHING = app.loadImage("assets/fishing.png");
    }
}
