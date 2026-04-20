static class ImageAssets {
    static PImage ALGAE;
    static PImage CRAB;
    static PImage SARDINE;
    static PImage SHARK;
    static PImage CORPSE;
    static PImage FISHING;
    static PImage BACKGROUND;
    // TODO: @[UI] you may need to load SFX or Music too, so refactor the name 
    // so that it have format, or rename the class to ImageAssets instead, 
    // and have AudioAssets class for sfx/music purpose
    static void load(PApplet app) {
        ALGAE = app.loadImage("assets/Algae_0.png");
        CRAB = app.loadImage("assets/Crab_0.png");
        SARDINE = app.loadImage("assets/Sardine_0.png");
        SHARK = app.loadImage("assets/Shark_0.png");
        CORPSE = app.loadImage("assets/Corpse.png");
        FISHING = app.loadImage("assets/fishing.png");
        BACKGROUND = app.loadImage("assets/BackGround.png");
    }
}
