class FX_Manager implements IEventListener {

  ArrayList<FX_Particle> particles = new ArrayList<FX_Particle>();
  java.util.HashMap<Integer, Integer> stressFxCooldown = new java.util.HashMap<Integer, Integer>();
  FX_EnvironmentVisuals envVisuals = new FX_EnvironmentVisuals();

  FX_Manager() {
    systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
  }

  void onEvent(EventType type, Object payload) {
    if (type == EventType.EVENT_ENTITY_DESTROYED) {
      Object[] p = (Object[]) payload;
      float x = (Float)p[1];
      float y = (Float)p[2];
      spawnParticles(new PVector(x, y));
    }
  }

  /** loc: world space */
  void spawnParticles(PVector loc) {
    for (int i = 0; i < 20; i++) {
      particles.add(new FX_RandomParticle(loc.copy()));
    }
  }

  void spawnStressBurst(PVector worldLoc, float intensity, String mode) {
    int n = max(3, (int)(8 + intensity * 14));
    intensity = constrain(intensity, 0, 1);
    for (int i = 0; i < n; i++) {
      PVector o = worldLoc.copy();
      o.add(PVector.random2D().mult(random(2, 8) * intensity));
      int r = 255, g = 120, b = 60;
      if ("POLLUTION".equals(mode)) {
        r = 80;
        g = 200;
        b = 120;
      } else if ("BOTH".equals(mode)) {
        r = 200;
        g = 80;
        b = 200;
      }
      particles.add(new FX_StressParticle(o, r, g, b));
    }
  }

  void run() {
    worldView.frameCountForFx = frameCount;

    for (int i = particles.size() - 1; i >= 0; i--) {
      FX_Particle p = particles.get(i);
      p.update();
      p.render();
      if (p.isDead()) {
        particles.remove(i);
      }
    }

    if (world != null) {
      updateStressParticlesFromEntities();
      drawStressRings();
    }
  }

  void updateStressParticlesFromEntities() {
    for (int i = 0; i < world.entities.size(); i++) {
      IObject o = world.entities.get(i);
      if (!(o instanceof BaseEntity)) continue;
      BaseEntity be = (BaseEntity)o;
      if (be.isDead()) continue;

      float stress = envVisuals.stressFactor(be.x, be.y);
      if (stress < 0.35f) continue;

      int id = System.identityHashCode(be);
      Integer last = stressFxCooldown.get(id);
      if (last != null && frameCount - last < 10) continue;
      stressFxCooldown.put(id, frameCount);

      String mode = envVisuals.dominantMode(be.x, be.y);
      spawnStressBurst(new PVector(be.x, be.y), stress, mode);
    }
  }

  void drawStressRings() {
    pushStyle();
    for (int i = 0; i < world.entities.size(); i++) {
      IObject o = world.entities.get(i);
      if (!(o instanceof BaseEntity)) continue;
      BaseEntity be = (BaseEntity)o;
      if (be.isDead()) continue;

      float envStressFactor = envVisuals.stressFactor(be.x, be.y);
      if (envStressFactor < 0.05f) continue;

      PVector s = worldView.worldToScreen(be.x, be.y);
      float pulse = 14 + sin(frameCount * 0.18f) * 5f + envStressFactor * 18f;
      noFill();
      stroke(255, 90, 50, 160 * envStressFactor);
      strokeWeight(2);
      ellipse(s.x, s.y, pulse, pulse);
      if (envStressFactor > 0.45f) {
        stroke(80, 200, 120, 130 * envStressFactor);
        ellipse(s.x, s.y, pulse * 0.65f, pulse * 0.65f);
      }
    }
    popStyle();
  }
}
