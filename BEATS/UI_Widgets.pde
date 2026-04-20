// UI_Widgets.pde
// The HUD: Handles drawing of buttons, sliders, toolbars using purely mathematical primitives.

interface Widget {
    void render();
    void update();
    boolean isHovered(float mx, float my);
    void onClick();
}

class Manager {

    HashMap<MenuType, SubMenu> subMenus;
    ArrayList<Widget> widgets;

    Manager() {

        widgets = new ArrayList<Widget>();
        subMenus = new HashMap<MenuType, SubMenu>();
        float subX = UIState.sidebarX + UIState.buttonW;



        widgets.add(new ToggleButton(
            UIState.sidebarX - 40,
            UIState.sidebarY,
            30
            ));

        widgets.add(new Button(
            UIState.sidebarX,
            UIState.sidebarY,
            UIState.buttonW,
            UIState.buttonH,
            "Spawn Tool",
            () -> UIState.activeMenu = MenuType.SPAWN
            ));

        widgets.add(new Button(
            UIState.sidebarX,
            UIState.sidebarY + UIState.buttonH + UIState.gap,
            UIState.buttonW,
            UIState.buttonH,
            "Cull Tool",
            () -> UIState.activeMenu = MenuType.CULL
            ));

        widgets.add(new Button(
            UIState.sidebarX,
            UIState.sidebarY + (UIState.buttonH + UIState.gap) * 2,
            UIState.buttonW,
            UIState.buttonH,
            "Temperature",
            () -> UIState.activeMenu = MenuType.TEMPERATURE
            ));

        widgets.add(new Button(
            UIState.sidebarX,
            UIState.sidebarY + (UIState.buttonH + UIState.gap) * 3,
            UIState.buttonW,
            UIState.buttonH,
            "Pollution",
            () -> UIState.activeMenu = MenuType.POLLUTION
            ));

        subMenus.put(
            MenuType.SPAWN,
            new SpawnSubMenu(
            subX,
            UIState.sidebarY,
            UIState.buttonW
            )
            );

        subMenus.put(
            MenuType.CULL,
            new CullSubMenu(
            subX,
            UIState.sidebarY + (UIState.buttonH + UIState.gap),
            UIState.buttonW
            )
            );

        subMenus.put(
            MenuType.TEMPERATURE,
            new TemperatureSubMenu(
            subX,
            UIState.sidebarY + (UIState.buttonH + UIState.gap) * 2,
            UIState.buttonW
            )
            );

        subMenus.put(
            MenuType.POLLUTION,
            new PollutionSubMenu(
            subX,
            UIState.sidebarY + (UIState.buttonH + UIState.gap) * 3,
            UIState.buttonW
            )
            );
    }

    void render() {

        for (Widget w : widgets) {
            if (w instanceof ToggleButton) {
                w.render();
            }
        }

        if (!UIState.sidebarOpen) return;

        fill(UIState.MENU_BG);
        rect(UIState.sidebarX, UIState.sidebarY, UIState.buttonW, (UIState.buttonH + UIState.gap) * 4);

        for (Widget w : widgets) {
            if (!(w instanceof ToggleButton)) {
                w.update();
                w.render();
            }
        }

        SubMenu menu = subMenus.get(UIState.activeMenu);
        if (menu != null) {
            menu.render();
        }
    }

    boolean handleMouseClick(float mx, float my) {

        for (Widget w : widgets) {
            if (w.isHovered(mx, my)) {
                w.onClick();
                return true;
            }
        }

        SubMenu menu = subMenus.get(UIState.activeMenu);
        if (menu != null) {
            return menu.handleMousePressed(mx, my);
        }

        return false;
    }

    void handleMouseReleased() {
        SubMenu menu = subMenus.get(UIState.activeMenu);
        if (menu != null) {
            menu.handleMouseReleased();
        }
    }

    void handleMouseDragged(float mx, float my) {
        SubMenu menu = subMenus.get(UIState.activeMenu);
        if (menu != null) {
            menu.handleMouseDragged(mx, my);
        }
    }
}

//toggle button

class ToggleButton implements Widget {

    float x, y, size;

    ToggleButton(float x, float y, float size) {
        this.x=x;
        this.y=y;
        this.size=size;
    }

    void update() {
    }

    void render() {

        fill(180);
        stroke(0);
        rect(x, y, size, size);

        fill(0);

        if (UIState.sidebarOpen) {
            triangle(x+8, y+6, x+8, y+size-6, x+size-8, y+size/2);
        } else {
            triangle(x+size-8, y+6, x+size-8, y+size-6, x+8, y+size/2);
        }
    }

    boolean isHovered(float mx, float my) {
        return mx>=x && mx<=x+size && my>=y && my<=y+size;
    }

    void onClick() {
        UIState.sidebarOpen=!UIState.sidebarOpen;
        UIState.activeMenu=MenuType.NONE;
    }
}

//menu button
class Button implements Widget {

    float x, y, w, h;
    String label;
    Runnable command;

    Button(float x, float y, float w, float h, String label, Runnable command) {
        this.x=x;
        this.y=y;
        this.w=w;
        this.h=h;
        this.label=label;
        this.command = command;
    }

    void update() {
    }

    void render() {
        if (isHovered(mouseX, mouseY)) {
            fill(UIState.MENU_HOVER);
        } else {
            fill(UIState.MENU_BG);
        }

        rect(x, y, w, h);

        fill(UIState.MENU_TEXT);
        textAlign(LEFT, CENTER);
        text(label, x+10, y+h/2);
    }

    boolean isHovered(float mx, float my) {
        return mx>=x && mx<=x+w && my>=y && my<=y+h;
    }

    void onClick() {
        // Play button sound
        if (SoundAssets.BUTTON_SOUND != null) {
            SoundAssets.BUTTON_SOUND.stop();
            SoundAssets.BUTTON_SOUND.play();
        }
        
        if (command != null) {
            command.run();
        }
    }
}
// Slider
class Slider implements Widget {

    float x, y, w, h;

    float minVal, maxVal;
    float value;

    String label;

    boolean dragging = false;

    Slider(float x, float y, float w, float h,
           String label,
           float minVal, float maxVal, float value) {

        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;

        this.label = label;

        this.minVal = minVal;
        this.maxVal = maxVal;
        this.value = value;
    }

    void update() {
        if (dragging) {
            float newX = constrain(mouseX, x + 10, x + w - 10);
            value = map(newX, x + 10, x + w - 10, minVal, maxVal);
        }
    }

    void render() {

        // background
        fill(UIState.MENU_BG);
        rect(x, y, w, h);

        // label (bên trái)
        fill(UIState.MENU_TEXT);
        textAlign(RIGHT, CENTER);
        text(label, x - 10, y + h / 2);

        // value (bên phải)
        textAlign(LEFT, CENTER);
        text(nf(value, 1, 1), x + w + 10, y + h / 2);

        // slider line
        float lineY = y + h / 2;

        stroke(160);
        line(x + 10, lineY, x + w - 10, lineY);

        // knob position
        float knobX = map(value, minVal, maxVal, x + 10, x + w - 10);

        if (dragging)
            fill(255);
        else
            fill(200);

        ellipse(knobX, lineY, 12, 12);
    }

    boolean isHovered(float mx, float my) {
        return mx >= x && mx <= x + w &&
               my >= y && my <= y + h;
    }

    void onClick() {
        float knobX = map(value, minVal, maxVal, x + 10, x + w - 10);
        float knobY = y + h / 2;

        if (dist(mouseX, mouseY, knobX, knobY) < 10) {
            dragging = true;
        }
    }

    void stopDragging() {
        dragging = false;
    }
}
