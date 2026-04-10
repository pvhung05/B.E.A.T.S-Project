// UI_PopulationGraphs.pde

class PopulationGraphs {
    int maxHistory = 100;
    IntList algaeHistory = new IntList();
    IntList sardineHistory = new IntList();
    IntList crabHistory = new IntList();
    IntList sharkHistory = new IntList();
    
    int lastUpdate = 0;
    int updateInterval = 500; // ms
    
    void update(EntityManager world) {
        if (millis() - lastUpdate > updateInterval) {
            lastUpdate = millis();
            int algaeCount = 0;
            int sardineCount = 0;
            int crabCount = 0;
            int sharkCount = 0;
            
            for (int e : world.activeEntities) {
                CSpecies s = world.coordinator.getComponent(e, CSpecies.class);
                if (s == null) continue;
                
                if (s.type == EntityType.ALGAE) algaeCount++;
                else if (s.type == EntityType.SARDINE) sardineCount++;
                else if (s.type == EntityType.CRAB) crabCount++;
                else if (s.type == EntityType.SHARK) sharkCount++;
            }
            
            addValue(algaeHistory, algaeCount);
            addValue(sardineHistory, sardineCount);
            addValue(crabHistory, crabCount);
            addValue(sharkHistory, sharkCount);
        }
    }
    
    void addValue(IntList list, int val) {
        list.append(val);
        if (list.size() > maxHistory) {
            list.remove(0);
        }
    }
    
    void render() {
        pushStyle();
        float graphWidth = 150;
        float graphHeight = 80;
        float x = width - graphWidth - 20;
        float startY = 20;
        float gap = 20;
        
        drawGraph(x, startY, graphWidth, graphHeight, algaeHistory, "Algae", color(50, 200, 50));
        drawGraph(x, startY + graphHeight + gap, graphWidth, graphHeight, sardineHistory, "Sardine", color(50, 150, 255));
        drawGraph(x, startY + (graphHeight + gap) * 2, graphWidth, graphHeight, crabHistory, "Crab", color(255, 100, 50));
        drawGraph(x, startY + (graphHeight + gap) * 3, graphWidth, graphHeight, sharkHistory, "Shark", color(200, 50, 50));
        popStyle();
    }
    
    void drawGraph(float x, float y, float w, float h, IntList history, String label, int col) {
        fill(30, 30, 30, 200);
        noStroke();
        rect(x, y, w, h);
        
        fill(255);
        textAlign(LEFT, TOP);
        int currentCount = history.size() > 0 ? history.get(history.size()-1) : 0;
        text(label + ": " + currentCount, x + 5, y + 5);
        
        if (history.size() < 2) return;
        
        int maxVal = 1;
        for (int i = 0; i < history.size(); i++) {
            if (history.get(i) > maxVal) maxVal = history.get(i);
        }
        
        stroke(col);
        strokeWeight(2);
        noFill();
        beginShape();
        for (int i = 0; i < history.size(); i++) {
            float px = x + map(i, 0, maxHistory - 1, 0, w);
            float py = y + h - map(history.get(i), 0, maxVal, 0, h - 25) - 5; // reserve top 20px and bottom 5px
            vertex(px, py);
        }
        endShape();
    }
}
