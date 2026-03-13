boolean sidebarOpen=false;

enum MenuType{
  NONE,
  SPAWN,
  TEMPERATURE,
  POLLUTION
}

MenuType activeMenu=MenuType.NONE;

float sidebarX=40;
float sidebarY=70;

float buttonW=160;
float buttonH=30;
float gap=2;

float temperature = 20;
float pollution = 10;

boolean draggingTemperature = false;
boolean draggingPollution = false;

// VSCode colors
color MENU_BG=color(37,37,38);
color MENU_HOVER=color(62,62,64);
color MENU_TEXT=color(220);
