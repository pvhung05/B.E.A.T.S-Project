import processing.sound.*;

static class ImageAssets {
    static PImage ALGAE;
    static PImage CRAB;
    static PImage SARDINE;
    static PImage SHARK;
    static PImage FISHING;
    
    static void load(PApplet app) {
        ALGAE = app.loadImage("assets/algae.png");
        CRAB = app.loadImage("assets/crab.png");
        SARDINE = app.loadImage("assets/sardine.png");
        SHARK = app.loadImage("assets/shark.png");
        FISHING = app.loadImage("assets/fishing.png");
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