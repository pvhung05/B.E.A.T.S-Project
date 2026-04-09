/**
 * Core_EntityRenderer.pde
 * Centralized rendering system for all entities.
 * Decouples visual representation from simulation logic.
 */
class EntityRenderer {

    EntityRenderer() {
    }

    /**
     * Main render loop for a list of entities.
     */
    void render(Coordinator coordinator, ArrayList<Integer> entities, Camera camera) {
        PVector camPos = camera.getPos();

        for (int e : entities) {
            CTransform t = coordinator.getComponent(e, CTransform.class);
            CSpecies s = coordinator.getComponent(e, CSpecies.class);
            if (t == null || s == null) continue;

            // Frustum Culling
            if (isVisible(t, camPos, camera)) {
                drawEntity(coordinator, e, t, s);
            }
        }
    }

    private void drawEntity(Coordinator coordinator, int e, CTransform t, CSpecies s) {
        pushStyle();
        pushMatrix();
        translate(t.x, t.y);

        switch(s.type) {
        case ALGAE:
            drawAlgae();
            break;
        case SARDINE:
            drawSardine();
            break;
        case SHARK:
            drawShark();
            break;
        case CRAB:
            drawCrab();
            break;        
        case CORPSE:
            drawCorpse();
            break;
        }
        popMatrix();
        popStyle();
    }

    private void drawAlgae() {
        noStroke();
        fill(60, 180, 80, 200);
        ellipse(0, 0, 12, 12);
        fill(40, 140, 60, 150);
        ellipse(0, -5, 8, 12);
    }

    private void drawSardine() {
        fill(150, 150, 200);
        ellipse(0, 0, 15, 8);
    }

    private void drawShark() {
        fill(100, 100, 120);
        ellipse(0, 0, 40, 20);
    }

    private void drawCrab() {
        fill(180, 80, 50);
        stroke(100, 40, 20);
        rectMode(CENTER);
        rect(0, 0, 25, 15, 4);
        line(-12, -7, -18, -12);
        line(12, -7, 18, -12);
    }
    
    private void drawCorpse() {
        fill(120, 120, 120, 150);
        rectMode(CENTER);
        rect(0, 0, 18, 10, 2);
    }

    private boolean isVisible(CTransform t, PVector camPos, Camera camera) {
        final float margin = 100;
        return t.x > camPos.x - margin &&
            t.x < camPos.x + camera.w + margin &&
            t.y > camPos.y - margin &&
            t.y < camPos.y + camera.h + margin;
    }
}
