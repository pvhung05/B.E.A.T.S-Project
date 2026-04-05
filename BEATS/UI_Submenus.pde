abstract class SubMenu {

    float x, y, w;

    SubMenu(float x, float y, float w) {
        this.x = x;
        this.y = y;
        this.w = w;
    }

    abstract void render();
    abstract boolean handleMousePressed(float mx, float my);
    abstract void handleMouseReleased();
    abstract void handleMouseDragged(float mx, float my);
}

class TemperatureSubMenu extends SubMenu {

    Slider slider;

    TemperatureSubMenu(float x, float y, float w) {
        super(x, y, w);

        slider = new Slider(
            x, y, w, UIState.buttonH,
            "Temperature",
            -20, 50,
            UIState.temperature
            );
    }

    void render() {
        slider.render();
        UIState.temperature = slider.value;
    }

    boolean handleMousePressed(float mx, float my) {
        if (slider.isHovered(mx, my)) {
            slider.dragging = true;
            return true;
        }
        return false;
    }

    void handleMouseReleased() {
        slider.dragging = false;
    }

    void handleMouseDragged(float mx, float my) {
        if (!slider.dragging) return;

        float clampedX = constrain(
            mx,
            slider.x + 10,
            slider.x + slider.w - 10
            );

        slider.value = map(
            clampedX,
            slider.x + 10,
            slider.x + slider.w - 10,
            slider.minVal,
            slider.maxVal
            );
    }
}

class PollutionSubMenu extends SubMenu {

    Slider slider;

    PollutionSubMenu(float x, float y, float w) {
        super(x, y, w);

        slider = new Slider(
            x, y, w, UIState.buttonH,
            "Pollution",
            0, 100,
            UIState.pollution
            );
    }

    void render() {
        slider.render();
        UIState.pollution = slider.value;
    }

    boolean handleMousePressed(float mx, float my) {
        if (slider.isHovered(mx, my)) {
            slider.dragging = true;
            return true;
        }
        return false;
    }

    void handleMouseReleased() {
        slider.dragging = false;
    }

    void handleMouseDragged(float mx, float my) {
        if (!slider.dragging) return;

        float clampedX = constrain(
            mx,
            slider.x + 10,
            slider.x + slider.w - 10
            );

        slider.value = map(
            clampedX,
            slider.x + 10,
            slider.x + slider.w - 10,
            slider.minVal,
            slider.maxVal
            );
    }
}

class SpawnSubMenu extends SubMenu {

    ArrayList<Button> spawnButtons = new ArrayList<Button>();

    SpawnSubMenu(float x, float y, float w) {
        super(x, y, w);

        float by = y;

        for (SpawnType t : SpawnType.values()) {

            spawnButtons.add(
                new Button(
                    x, by, w, UIState.buttonH,
                    t.name(),
                    () -> {

                        String toolName = t.name();

                        // toggle
                        if (UIState.selectedSpawn == t) {
                            toolName = "NONE";
                        }

                        systemBus.publish(
                          EventType.EVENT_UI_TOOL_SELECTED,
                          new Object[]{
                              (UIState.selectedSpawn == t) ? "NONE" : "SPAWN_" + t.name(),
                              null, null, null
                          }
                      );
                    }
                )
            );

            by += UIState.buttonH + UIState.gap;
        }
    }

    void render() {
        for (Button b : spawnButtons) {
            b.update();
            b.render();
        }
    }

    boolean handleMousePressed(float mx, float my) {
        for (Button b : spawnButtons) {
            if (b.isHovered(mx, my)) {
                b.onClick();
                return true;
            }
        }
        return false;
    }

    void handleMouseReleased() {}
    void handleMouseDragged(float mx, float my) {}
}

class CullSubMenu extends SubMenu {

    ArrayList<Button> cullButtons = new ArrayList<Button>();

    CullSubMenu(float x, float y, float w) {
        super(x, y, w);

        float by = y;

        for (CullType t : CullType.values()) {

            cullButtons.add(
                new Button(
                    x, by, w, UIState.buttonH,
                    t.name(),
                    () -> {

                        String tool = UIState.cullActive ? "NONE" : "CULL";

                        systemBus.publish(
                          EventType.EVENT_UI_TOOL_SELECTED,
                          new Object[]{
                              UIState.cullActive ? "NONE" : "CULL",
                              null, null, null
                          }
                      );
                    }
                )
            );

            by += UIState.buttonH + UIState.gap;
        }
    }

    void render() {
        for (Button b : cullButtons) {
            b.update();
            b.render();
        }
    }

    boolean handleMousePressed(float mx, float my) {
        for (Button b : cullButtons) {
            if (b.isHovered(mx, my)) {
                b.onClick();
                return true;
            }
        }
        return false;
    }

    void handleMouseReleased() {}
    void handleMouseDragged(float mx, float my) {}
}
