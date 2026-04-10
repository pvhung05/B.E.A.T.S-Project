/**
 * Core_EntityRenderer.pde
 * Centralized rendering system for all entities.
 * Decouples visual representation from simulation logic.
 */
class EntityRenderer {
    FX_EnvironmentVisuals envVisuals;

    EntityRenderer() {
        envVisuals = new FX_EnvironmentVisuals();
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
        pushStyle();
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
        case CORPSE:
            drawCorpse((Corpse)e);
            break;
        }
        popMatrix();
        popStyle();
    }


    private void drawAlgae(Algae e) {
        float stress = envVisuals.stressFactor(e.x, e.y);
        float alpha = 160 + (1.0f - stress) * 60.0f;
        float sway = sin((frameCount * 0.06f) + (e.x * 0.01f)) * 2.0f;
        noStroke();
        fill(60, 180, 80, alpha);
        ellipse(0, 0, 12, 12);
        fill(40, 140, 60, alpha - 40);
        ellipse(sway, -5, 8, 12);
        drawStressOverlay(stress);
    }

    private void drawSardine(Sardine e) {
        rotate(e.yAngle);
        float stress = envVisuals.stressFactor(e.x, e.y);
        int bodyTone = (int)max(90, 170 - stress * 65);
        noStroke();
        fill(bodyTone, bodyTone, 215, 220);
        ellipse(0, 0, 15, 8);
        triangle(-7, 0, -12, -3, -12, 3);

        if (e.state == State.FLEE) {
            stroke(255, 190, 120, 140);
            noFill();
            ellipse(0, 0, 19, 12);
        }
        drawStressOverlay(stress);
    }

    private void drawShark(Shark e) {
        rotate(e.yAngle);
        float stress = envVisuals.stressFactor(e.x, e.y);
        noStroke();
        fill(100, 100, 120, 230);
        ellipse(0, 0, 40, 20);
        triangle(-18, 0, -28, -8, -28, 8);
        triangle(2, -8, -3, -17, 8, -8);

        if (e.state == State.HUNT) {
            stroke(255, 90, 70, 150);
            noFill();
            ellipse(0, 0, 46, 25);
        }
        drawStressOverlay(stress);
    }

    private void drawCrab(Crab e) {
        float stress = envVisuals.stressFactor(e.x, e.y);
        float pulse = 1.0f + sin((frameCount + e.x) * 0.12f) * 0.06f;
        scale(pulse);
        fill(180, 80, 50);
        stroke(100, 40, 20);
        rectMode(CENTER);
        rect(0, 0, 25, 15, 4);
        line(-12, -7, -18, -12);
        line(12, -7, 18, -12);
        drawStressOverlay(stress);
    }

    private void drawCorpse(Corpse e) {
        noStroke();
        float lifeRatio = constrain(e.corpseLifetime / 300.0f, 0, 1);
        fill(105, 85, 70, 60 + lifeRatio * 80);
        ellipse(0, 0, 18, 10);
        stroke(130, 110, 90, 80);
        line(-6, -2, 6, 2);
    }

    private void drawStressOverlay(float stress) {
        if (stress < 0.08f) return;
        noFill();
        strokeWeight(1.3f);
        stroke(255, 90, 50, min(180, 60 + stress * 140));
        float r = 10 + stress * 14 + sin(frameCount * 0.2f) * 1.2f;
        ellipse(0, 0, r, r);
    }

    private boolean isVisible(BaseEntity e, PVector camPos, Camera camera) {
        final float margin = 100;
        return e.x > camPos.x - margin &&
            e.x < camPos.x + camera.w + margin &&
            e.y > camPos.y - margin &&
            e.y < camPos.y + camera.h + margin;
    }
}
