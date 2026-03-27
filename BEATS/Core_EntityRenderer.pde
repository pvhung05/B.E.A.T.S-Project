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
    void render(ArrayList<IObject> entities, Camera camera) {
        PVector camPos = camera.getPos();

        for (IObject obj : entities) {
            if (!(obj instanceof BaseEntity)) continue;
            BaseEntity e = (BaseEntity) obj;

            // Frustum Culling
            if (isVisible(e, camPos, camera)) {
                drawEntity(e);
            }
        }
    }

    private void drawEntity(BaseEntity e) {
        pushMatrix();
        translate(e.x, e.y);

        switch(e.type) {
        case ALGAE:
            drawAlgae((Algae)e);
            break;
        case SARDINE:
            drawSardine((Sardine)e);
            break;
        case SHARK:
            drawShark((Shark)e);
            break;
        case CRAB:
            drawCrab((Crab)e);
            break;        
        }
        // TODO: @[FX] may need to handle corpse too
        popMatrix();
    }


    // TODO: @[FX] define drawing logics for each organism here, of course base on events, environment,
    // and freely express logics of how one should be drawn, like taking damage ex

    // this kind of decouple should allow FX to freely experiment with 3D rendering
    private void drawAlgae(Algae e) {
        noStroke();
        fill(60, 180, 80, 200);
        ellipse(0, 0, 12, 12);
    }

    private void drawSardine(Sardine e) {
        fill(150, 150, 200);
        ellipse(0, 0, 15, 8);
    }

    private void drawShark(Shark e) {
        fill(100, 100, 120);
        ellipse(0, 0, 40, 20);
    }

    private void drawCrab(Crab e) {
        fill(180, 80, 50);
        rectMode(CENTER);
        rect(0, 0, 25, 15, 4);
    }

    private boolean isVisible(BaseEntity e, PVector camPos, Camera camera) {
        final float margin = 100;
        return e.x > camPos.x - margin &&
            e.x < camPos.x + camera.w + margin &&
            e.y > camPos.y - margin &&
            e.y < camPos.y + camera.h + margin;
    }
}
