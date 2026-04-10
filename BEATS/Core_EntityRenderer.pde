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
            drawAlgae(coordinator, e, t);
            break;
        case SARDINE:
            drawSardine(coordinator, e, t);
            break;
        case SHARK:
            drawShark(coordinator, e, t);
            break;
        case CRAB:
            drawCrab(coordinator, e, t);
            break;
        case CORPSE:
            drawCorpse(coordinator, e, t);
            break;
        }
        popMatrix();
        popStyle();
    }

    private void drawAlgae(Coordinator coordinator, int e, CTransform t) {
        float stress = envVisuals.stressFactor(t.x, t.y);
        float alpha = 160 + (1.0f - stress) * 60.0f;
        float sway = sin((frameCount * 0.06f) + (t.x * 0.01f)) * 2.0f;
        noStroke();
        fill(60, 180, 80, alpha);
        ellipse(0, 0, 12, 12);
        fill(40, 140, 60, alpha - 40);
        ellipse(sway, -5, 8, 12);
        drawStressOverlay(stress);
    }

    private void drawSardine(Coordinator coordinator, int e, CTransform t) {
        CVelocity v = coordinator.getComponent(e, CVelocity.class);
        CSteering st = coordinator.getComponent(e, CSteering.class);
        if (v != null) rotate(v.yAngle);
        float stress = envVisuals.stressFactor(t.x, t.y);
        int bodyTone = (int)max(90, 170 - stress * 65);
        noStroke();
        fill(bodyTone, bodyTone, 215, 220);
        ellipse(0, 0, 15, 8);
        triangle(-7, 0, -12, -3, -12, 3);

        if (st != null && st.state == State.FLEE) {
            stroke(255, 190, 120, 140);
            noFill();
            ellipse(0, 0, 19, 12);
        }
        drawStressOverlay(stress);
    }

    private void drawShark(Coordinator coordinator, int e, CTransform t) {
        CVelocity v = coordinator.getComponent(e, CVelocity.class);
        CSteering st = coordinator.getComponent(e, CSteering.class);
        if (v != null) rotate(v.yAngle);
        float stress = envVisuals.stressFactor(t.x, t.y);
        noStroke();
        fill(100, 100, 120, 230);
        ellipse(0, 0, 40, 20);
        triangle(-18, 0, -28, -8, -28, 8);
        triangle(2, -8, -3, -17, 8, -8);

        if (st != null && st.state == State.HUNT) {
            stroke(255, 90, 70, 150);
            noFill();
            ellipse(0, 0, 46, 25);
        }
        drawStressOverlay(stress);
    }

    private void drawCrab(Coordinator coordinator, int e, CTransform t) {
        float stress = envVisuals.stressFactor(t.x, t.y);
        float pulse = 1.0f + sin((frameCount + t.x) * 0.12f) * 0.06f;
        scale(pulse);
        fill(180, 80, 50);
        stroke(100, 40, 20);
        rectMode(CENTER);
        rect(0, 0, 25, 15, 4);
        line(-12, -7, -18, -12);
        line(12, -7, 18, -12);
        drawStressOverlay(stress);
    }

    private void drawCorpse(Coordinator coordinator, int e, CTransform t) {
        CCorpse c = coordinator.getComponent(e, CCorpse.class);
        noStroke();
        float lifeRatio = (c != null) ? constrain(c.lifetime / 300.0f, 0, 1) : 0;
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

    private boolean isVisible(CTransform t, PVector camPos, Camera camera) {
        final float margin = 100;
        return t.x > camPos.x - margin &&
            t.x < camPos.x + camera.w + margin &&
            t.y > camPos.y - margin &&
            t.y < camPos.y + camera.h + margin;
    }
}
