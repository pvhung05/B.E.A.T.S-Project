// UI_Widgets.pde
// The HUD: Handles drawing of buttons, sliders, toolbars using purely mathematical primitives.

interface Widget {
  // TODO[@UI]: Instruct them to interface ONLY with EntityManager to add/remove/select objects. 
  // The UI must remain agnostic to the entity's underlying logic.
  
  void render();
  void update();
  boolean isHovered(float mx, float my);
  void onClick();
}

class Manager {
  ArrayList<Widget> widgets;
  
  Manager() {
    widgets = new ArrayList<Widget>();
  }
  
  void addWidget(Widget w) {
    widgets.add(w);
  }
  
  void render() {
    for (Widget w : widgets) {
      w.update();
      w.render();
    }
  }
  
  boolean handleMouseClick(float mx, float my) {
    for (Widget w : widgets) {
      if (w.isHovered(mx, my)) {
        w.onClick();
        return true;
      }
    }
    return false;
  }
}


class Button implements Widget {
  float x, y, w, h;
  String label;
  
  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  void update() {
    
  }
  
  void render() {
    
    if (isHovered(mouseX, mouseY)) {
      fill(200);
    } else {
      fill(150);
    }
    stroke(0);
    strokeWeight(2);
    rect(x, y, w, h, 5); 
    
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isHovered(float mx, float my) {
    return mx >= x && mx <= x + w && my >= y && my <= y + h;
  }
  
  void onClick() {
    
    if (label.equals("Toggle FX")) {
      // TODO[@UI]: Publish user input to the bus.
      systemBus.publish(EventType.EVENT_UI_WIDGET_CLICKED, label);
    }
  }
}
