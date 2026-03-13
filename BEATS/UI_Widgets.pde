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
  Slider temperatureSlider;
  Slider pollutionSlider;

  Manager(){

    widgets = new ArrayList<Widget>();
  
    temperatureSlider = new Slider(
      sidebarX + buttonW,
      sidebarY + (buttonH + gap) * 2,
      200,
      buttonH,
      "Temperature",
      -20,
      50,
      temperature
    );
  
    pollutionSlider = new Slider(
      sidebarX + buttonW,
      sidebarY + (buttonH + gap) * 3,
      200,
      buttonH,
      "Pollution",
      0,
      100,
      pollution
    );
  }

  void addWidget(Widget w){
    widgets.add(w);
  }

  void render(){

    // Toggle luôn render
    for(Widget w:widgets){
      if(w instanceof ToggleButton){
        w.render();
      }
    }

    if(!sidebarOpen) return;

    // Main menu panel
    fill(MENU_BG);
    noStroke();
    rect(sidebarX,sidebarY,buttonW,(buttonH+gap)*4);

    for(Widget w:widgets){
      if(!(w instanceof ToggleButton)){
        w.update();
        w.render();
      }
    }

    renderSubMenu();
  }

  void renderSubMenu(){

    float subX = sidebarX + buttonW;
    float subY = sidebarY;
    
    if(activeMenu == MenuType.SPAWN)
      subY = sidebarY + (buttonH + gap) * 0;
    
    if(activeMenu == MenuType.TEMPERATURE)
      subY = sidebarY + (buttonH + gap) * 2;
    
    if(activeMenu == MenuType.POLLUTION)
      subY = sidebarY + (buttonH + gap) * 3;
  
    // ================= SPAWN =================
    if(activeMenu == MenuType.SPAWN){
  
      String[] items={"Fish","Plant","Predator"};
  
      fill(MENU_BG);
      rect(subX,subY,buttonW,(buttonH+gap)*items.length);
  
      for(int i=0;i<items.length;i++){
  
        float y=subY+i*(buttonH+gap);
  
        if(mouseX>subX && mouseX<subX+buttonW &&
           mouseY>y && mouseY<y+buttonH){
  
          fill(MENU_HOVER);
          rect(subX,y,buttonW,buttonH);
        }
  
        fill(MENU_TEXT);
        textAlign(LEFT,CENTER);
        text(items[i],subX+10,y+buttonH/2);
      }
    }
  
    // ================= TEMPERATURE =================
    if(activeMenu == MenuType.TEMPERATURE){
    
      temperatureSlider.update();
      temperatureSlider.render();
    
      temperature = temperatureSlider.value;
    }

  
    // ================= POLLUTION =================
    if(activeMenu == MenuType.POLLUTION){
    
      pollutionSlider.update();
      pollutionSlider.render();
    
      pollution = pollutionSlider.value;
    }
  }
  boolean handleMouseClick(float mx,float my){

    for(Widget w:widgets){
      if(w.isHovered(mx,my)){
        w.onClick();
        return true;
      }
    }
  
    float subX = sidebarX + buttonW;
  
    return false;
  }
}

//toggle button

class ToggleButton implements Widget {

  float x,y,size;

  ToggleButton(float x,float y,float size){
    this.x=x;
    this.y=y;
    this.size=size;
  }

  void update(){}

  void render(){

    fill(180);
    stroke(0);
    rect(x,y,size,size);

    fill(0);

    if(sidebarOpen){
      triangle(x+8,y+6,x+8,y+size-6,x+size-8,y+size/2);
    }
    else{
      triangle(x+size-8,y+6,x+size-8,y+size-6,x+8,y+size/2);
    }
  }

  boolean isHovered(float mx,float my){
    return mx>=x && mx<=x+size && my>=y && my<=y+size;
  }

  void onClick(){
    sidebarOpen=!sidebarOpen;
    activeMenu=MenuType.NONE;
  }
}

//menu button
class Button implements Widget {

  float x,y,w,h;
  String label;
  EventType eventType;

  Button(float x,float y,float w,float h,String label,EventType eventType){

    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.label=label;
    this.eventType=eventType;
  }

  void update(){}

  void render(){

    if(isHovered(mouseX,mouseY)){
      fill(MENU_HOVER);
    }
    else{
      fill(MENU_BG);
    }

    noStroke();
    rect(x,y,w,h);

    fill(MENU_TEXT);
    textAlign(LEFT,CENTER);
    text(label,x+10,y+h/2);

    if(label.equals("Spawn Tool") ||
       label.equals("Temperature") ||
       label.equals("Pollution")){

      textAlign(RIGHT,CENTER);
      text(">",x+w-10,y+h/2);
    }
  }

  boolean isHovered(float mx,float my){
    return mx>=x && mx<=x+w && my>=y && my<=y+h;
  }

  void onClick(){

    if(label.equals("Spawn Tool")){
      activeMenu = activeMenu==MenuType.SPAWN ? MenuType.NONE : MenuType.SPAWN;
      return;
    }

    if(label.equals("Temperature")){
      activeMenu = activeMenu==MenuType.TEMPERATURE ? MenuType.NONE : MenuType.TEMPERATURE;
      return;
    }

    if(label.equals("Pollution")){
      activeMenu = activeMenu==MenuType.POLLUTION ? MenuType.NONE : MenuType.POLLUTION;
      return;
    }

    systemBus.publish(
      eventType,
      new Object[]{label,null,null,null}
    );
  }
}

// Slider
class Slider implements Widget {

  float x,y,w,h;

  float minVal,maxVal;
  float value;

  String label;

  boolean dragging=false;

  Slider(float x,float y,float w,float h,
         String label,
         float minVal,float maxVal,float value){

    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;

    this.label=label;

    this.minVal=minVal;
    this.maxVal=maxVal;
    this.value=value;
  }

  void update(){
  }

  void render(){

    // background
    fill(MENU_BG);
    rect(x,y,w,h);

    // label
    fill(MENU_TEXT);
    textAlign(LEFT,CENTER);
    text(nf(value,1,1),x+8,y+h/3);

    // slider line
    float lineY = y + h - 10;

    stroke(160);
    line(x+10,lineY,x+w-10,lineY);

    // knob position
    float knobX = map(value,minVal,maxVal,x+10,x+w-10);

    if(dragging)
      fill(255);
    else
      fill(200);

    ellipse(knobX,lineY,12,12);
  }

  boolean isHovered(float mx,float my){
    return mx>=x && mx<=x+w &&
           my>=y && my<=y+h;
  }

  void onClick(){
    dragging=true;
  }

  void stopDragging(){
    dragging=false;
  }

}
