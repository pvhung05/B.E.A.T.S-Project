class GameMenu {

    Slider sfxSlider;
    Slider musicSlider;
    boolean visible = false;
    ArrayList<Button> buttons = new ArrayList<Button>();

    GameMenu() {}

    void openMenu() {
        visible = true;
        systemBus.publish(EventType.EVENT_APP_PAUSE, new Object[]{null, null, null, null});
    }

    void closeMenu() {
        visible = false;
        systemBus.publish(EventType.EVENT_APP_RESUME, new Object[]{null, null, null, null});
    }

    void togglePause() {
        if (visible) closeMenu();
        else openMenu();
    }


    void init() {
        buttons.clear();

        // TODO: @[SysDes] @[UI] Auto-Save Config - System Designer needs to define the naming and location of the config save file. UI needs to save SFX/Music volume to this file on mouse release instead of using a save button, and load it immediately on startup.
        float centerX = width / 2;
        float startY = height / 2 - 80;

        float btnW = 160;
        float btnH = 40;

        // Resume
        buttons.add(new Button(
            centerX - btnW / 2, startY,
            btnW, btnH,
            "Resume",
            () -> closeMenu()
        ));

        // SFX slider
        sfxSlider = new Slider(
            centerX - 100, startY + 70,
            200, 40,
            "SFX",
            0, 1,
            0.5
        );

        // Music slider
        musicSlider = new Slider(
            centerX - 100, startY + 130,
            200, 40,
            "Music",
            0, 1,
            0.5
        );

        // Quit
        buttons.add(new Button(
            centerX - btnW / 2, startY + 200,
            btnW, btnH,
            "Quit",
            () -> exit()
        ));
    }

    boolean isVisible() {
        return visible;
    }

    void render() {
        if (!visible) return;

        // overlay
        fill(0, 150);
        rect(0, 0, width, height);

        // title
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(24);
        text("PAUSED", width / 2, height / 2 - 140);

        // buttons
        for (Button b : buttons) {
            b.render();
        }

        // sliders
        sfxSlider.update();
        musicSlider.update();

        sfxSlider.render();
        musicSlider.render();
    }

    void handleMousePressed() {
        if (!visible) return;

        for (Button b : buttons) {
            if (b.isHovered(mouseX, mouseY)) {
                b.onClick();
            }
        }

        if (sfxSlider.isHovered(mouseX, mouseY)) {
            sfxSlider.onClick();
        }

        if (musicSlider.isHovered(mouseX, mouseY)) {
            musicSlider.onClick();
        }
    }

    void handleMouseReleased() {
        sfxSlider.stopDragging();
        musicSlider.stopDragging();
    }
}
