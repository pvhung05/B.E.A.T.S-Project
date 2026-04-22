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
        
        pushMatrix();
        translate(sway, 0);
        tint(255, alpha);
        if (ImageAssets.ALGAE != null) {
            float scaleX = t.w / ImageAssets.ALGAE.width;
            float scaleY = t.h / ImageAssets.ALGAE.height;
            scale(scaleX, scaleY);
            image(ImageAssets.ALGAE, -ImageAssets.ALGAE.width/2, -ImageAssets.ALGAE.height/2);
        }
        popMatrix();
        drawStressOverlay(stress);
    }

    private void drawSardine(Coordinator coordinator, int e, CTransform t) {
        CVelocity v = coordinator.getComponent(e, CVelocity.class);
        CSteering st = coordinator.getComponent(e, CSteering.class);
        if (v != null) rotate(v.yAngle);
        float stress = envVisuals.stressFactor(t.x, t.y);
        
        tint(255, 220);
        if (ImageAssets.SARDINE != null) {
            float scaleX = t.w / ImageAssets.SARDINE.width;
            float scaleY = t.h / ImageAssets.SARDINE.height;
            scale(scaleX, scaleY);
            image(ImageAssets.SARDINE, -ImageAssets.SARDINE.width/2, -ImageAssets.SARDINE.height/2);
        }

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
        
        tint(255, 230);
        if (ImageAssets.SHARK != null) {
            float scaleX = t.w / ImageAssets.SHARK.width;
            float scaleY = t.h / ImageAssets.SHARK.height;
            scale(scaleX, scaleY);
            image(ImageAssets.SHARK, -ImageAssets.SHARK.width/2, -ImageAssets.SHARK.height/2);
        }

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
        
        tint(255, 255);
        if (ImageAssets.CRAB != null) {
            float scaleX = t.w / ImageAssets.CRAB.width;
            float scaleY = t.h / ImageAssets.CRAB.height;
            scale(scaleX, scaleY);
            image(ImageAssets.CRAB, -ImageAssets.CRAB.width/2, -ImageAssets.CRAB.height/2);
        }
        drawStressOverlay(stress);
    }

    private void drawCorpse(Coordinator coordinator, int e, CTransform t) {
        CCorpse c = coordinator.getComponent(e, CCorpse.class);
        float lifeRatio = (c != null) ? constrain(c.lifetime / 300.0f, 0, 1) : 0;
        float alpha = 60 + lifeRatio * 80;
        
        tint(255, alpha);
        if (ImageAssets.CORPSE != null) {
            float scaleX = t.w / ImageAssets.CORPSE.width;
            float scaleY = t.h / ImageAssets.CORPSE.height;
            scale(scaleX, scaleY);
            image(ImageAssets.CORPSE, -ImageAssets.CORPSE.width/2, -ImageAssets.CORPSE.height/2);
        }
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
