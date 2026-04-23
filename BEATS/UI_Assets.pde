import processing.sound.*;

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

static class SoundAssets {
    static SoundFile BACKGROUND_SOUND;
    static SoundFile SPAWN_SOUND;
    static SoundFile CULL_SOUND;
    static SoundFile BUTTON_SOUND;
    
    static void load(PApplet app) {
        try {
            BACKGROUND_SOUND = new SoundFile(app, "sound/nhacnen.mp3");
            println("✓ Âm thanh: nhacnen.mp3");
        } catch (Exception e) {
            println("✗ Lỗi nhacnen.mp3");
            BACKGROUND_SOUND = null;
        }
        
        try {
            SPAWN_SOUND = new SoundFile(app, "sound/amthanhspawn.mp3");
            println("✓ Âm thanh: amthanhspawn.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhspawn.mp3");
            SPAWN_SOUND = null;
        }
        
        try {
            CULL_SOUND = new SoundFile(app, "sound/amthanhcull.mp3");
            println("✓ Âm thanh: amthanhcull.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhcull.mp3");
            CULL_SOUND = null;
        }
        
        try {
            BUTTON_SOUND = new SoundFile(app, "sound/amthanhbutton.mp3");
            println("✓ Âm thanh: amthanhbutton.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhbutton.mp3");
            BUTTON_SOUND = null;
        }
    }
}
