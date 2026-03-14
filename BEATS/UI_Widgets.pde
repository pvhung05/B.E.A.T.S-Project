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
      UIState.sidebarX + UIState.buttonW,
      UIState.sidebarY + (UIState.buttonH + UIState.gap) * 2,
      200,
      UIState.buttonH,
      "Temperature",
      -20,
      50,
      UIState.temperature
    );
  
    pollutionSlider = new Slider(
      UIState.sidebarX + UIState.buttonW,
      UIState.sidebarY + (UIState.buttonH + UIState.gap) * 3,
      200,
      UIState.buttonH,
      "Pollution",
      0,
      100,
      UIState.pollution
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

    if(!UIState.sidebarOpen) return;

    // Main menu panel
    fill(UIState.MENU_BG);
    noStroke();
    rect(UIState.sidebarX,UIState.sidebarY,UIState.buttonW,(UIState.buttonH+UIState.gap)*4);

    for(Widget w:widgets){
      if(!(w instanceof ToggleButton)){
        w.update();
        w.render();
      }
    }

    renderSubMenu();
  }

  void renderSubMenu(){

    float subX = UIState.sidebarX + UIState.buttonW;
    float subY = UIState.sidebarY;
    
    if(UIState.activeMenu == MenuType.SPAWN)
      subY = UIState.sidebarY + (UIState.buttonH + UIState.gap) * 0;
    
    if(UIState.activeMenu == MenuType.TEMPERATURE)
      subY = UIState.sidebarY + (UIState.buttonH + UIState.gap) * 2;
    
    if(UIState.activeMenu == MenuType.POLLUTION)
      subY = UIState.sidebarY + (UIState.buttonH + UIState.gap) * 3;
  
    //  SPAWN 
    if(UIState.activeMenu == MenuType.SPAWN){
  
      SpawnType[] items = SpawnType.values();
  
      fill(UIState.MENU_BG);
      rect(subX,subY,UIState.buttonW,(UIState.buttonH+UIState.gap)*items.length);
  
      for(int i=0;i<items.length;i++){
  
        float y=subY+i*(UIState.buttonH+UIState.gap);
  
        if(mouseX>subX && mouseX<subX+UIState.buttonW &&
           mouseY>y && mouseY<y+UIState.buttonH){
  
          fill(UIState.MENU_HOVER);
          rect(subX,y,UIState.buttonW,UIState.buttonH);
        }
  
        fill(UIState.MENU_TEXT);
        textAlign(LEFT,CENTER);
        text(items[i].name(), subX+10, y+UIState.buttonH/2);
      }
    }
    
    // CULL
    if(UIState.activeMenu == MenuType.CULL) {
      
    }
  
    //  TEMPERATURE 
    if(UIState.activeMenu == MenuType.TEMPERATURE){
    
      temperatureSlider.update();
      temperatureSlider.render();
    
      UIState.temperature = temperatureSlider.value;
    }

  
    //  POLLUTION 
    if(UIState.activeMenu == MenuType.POLLUTION){
    
      pollutionSlider.update();
      pollutionSlider.render();
    
      UIState.pollution = pollutionSlider.value;
    }
  }
  boolean handleMouseClick(float mx,float my){

  for(Widget w:widgets){
    if(w.isHovered(mx,my)){
      w.onClick();
      return true;
    }
  }

  float subX = UIState.sidebarX + UIState.buttonW;
  float subY = UIState.sidebarY;

  if(UIState.activeMenu == MenuType.SPAWN)
    subY = UIState.sidebarY;

  if(UIState.activeMenu == MenuType.TEMPERATURE)
    subY = UIState.sidebarY + (UIState.buttonH + UIState.gap) * 2;

  if(UIState.activeMenu == MenuType.POLLUTION)
    subY = UIState.sidebarY + (UIState.buttonH + UIState.gap) * 3;

  if(UIState.activeMenu == MenuType.SPAWN){

    SpawnType[] items = SpawnType.values();

    for(int i=0;i<items.length;i++){

      float y = subY + i*(UIState.buttonH + UIState.gap);

      if(mx>subX && mx<subX+UIState.buttonW &&
         my>y && my<y+UIState.buttonH){

        if(UIState.selectedSpawn == items[i]){
          UIState.selectedSpawn = null;   // bỏ chọn tool
          cursor(ARROW);
        }
        else{
          UIState.selectedSpawn = items[i]; // chọn tool
          cursor(UIState.getSpawnCursor(items[i]));
        }
      
        return true;
      }
    }
  }

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

    if(UIState.sidebarOpen){
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
    UIState.sidebarOpen=!UIState.sidebarOpen;
    UIState.activeMenu=MenuType.NONE;
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
      fill(UIState.MENU_HOVER);
    }
    else{
      fill(UIState.MENU_BG);
    }

    noStroke();
    rect(x,y,w,h);

    fill(UIState.MENU_TEXT);
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
      UIState.activeMenu = UIState.activeMenu==MenuType.SPAWN ? MenuType.NONE : MenuType.SPAWN;
      return;
    }
    
    if(label.equals("Cull Tool")){

      UIState.cullToolActive = !UIState.cullToolActive;
    
      if(UIState.cullToolActive){
        UIState.selectedSpawn = null;
        cursor(Assets.FISHING);   // tạm dùng crosshair
      }else{
        cursor(ARROW);
      }
    
      return;
    }

    if(label.equals("Temperature")){
      UIState.activeMenu = UIState.activeMenu==MenuType.TEMPERATURE ? MenuType.NONE : MenuType.TEMPERATURE;
      return;
    }

    if(label.equals("Pollution")){
      UIState.activeMenu = UIState.activeMenu==MenuType.POLLUTION ? MenuType.NONE : MenuType.POLLUTION;
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
    fill(UIState.MENU_BG);
    rect(x,y,w,h);

    // label
    fill(UIState.MENU_TEXT);
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
