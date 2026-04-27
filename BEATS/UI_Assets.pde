import ddf.minim.*;

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
    static Minim minim;
    static AudioPlayer BACKGROUND_SOUND;
    static AudioSample SPAWN_SOUND;
    static AudioSample CULL_SOUND;
    static AudioSample BUTTON_SOUND;
    
    static void load(PApplet app) {
        minim = new Minim(app);

        try {
            BACKGROUND_SOUND = minim.loadFile("sound/nhacnen.mp3");
            println("✓ Âm thanh: nhacnen.mp3");
        } catch (Exception e) {
            println("✗ Lỗi nhacnen.mp3");
            BACKGROUND_SOUND = null;
        }
        
        try {
            SPAWN_SOUND = minim.loadSample("sound/amthanhspawn.mp3");
            println("✓ Âm thanh: amthanhspawn.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhspawn.mp3");
            SPAWN_SOUND = null;
        }
        
        try {
            CULL_SOUND = minim.loadSample("sound/amthanhcull.mp3");
            println("✓ Âm thanh: amthanhcull.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhcull.mp3");
            CULL_SOUND = null;
        }
        
        try {
            BUTTON_SOUND = minim.loadSample("sound/amthanhbutton.mp3");
            println("✓ Âm thanh: amthanhbutton.mp3");
        } catch (Exception e) {
            println("✗ Lỗi amthanhbutton.mp3");
            BUTTON_SOUND = null;
        }
    }

    static void setBackgroundVolume(float linearVolume) {
        if (BACKGROUND_SOUND == null) return;
        if (BACKGROUND_SOUND.hasControl(ddf.minim.Controller.GAIN)) {
            BACKGROUND_SOUND.setGain(linearToGain(linearVolume));
        }
    }

    static void setSampleVolume(AudioSample sample, float linearVolume) {
        if (sample == null) return;
        if (sample.hasControl(ddf.minim.Controller.GAIN)) {
            sample.setGain(linearToGain(linearVolume));
        }
    }

    static void setPlayerVolume(AudioPlayer player, float linearVolume) {
        if (player == null) return;
        if (player.hasControl(ddf.minim.Controller.GAIN)) {
            player.setGain(linearToGain(linearVolume));
        }
    }

    static float linearToGain(float linearVolume) {
        float clamped = constrain(linearVolume, 0.0f, 1.0f);
        if (clamped <= 0.0f) return -80.0f;
        return 20.0f * log(clamped) / log(10.0f);
    }
}
