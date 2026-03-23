class FX_Manager implements IEventListener {

  ArrayList<FX_Particle> particles = new ArrayList<FX_Particle>();

  FX_Manager() {

    systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);

  }

  void onEvent(EventType type, Object payload) {

    if (type == EventType.EVENT_ENTITY_DESTROYED) {

      Object[] p = (Object[]) payload;

      float x = (Float)p[1];   
      float y = (Float)p[2];   

      spawnParticles(new PVector(x,y));

    }

  }

  // tạo particle
  void spawnParticles(PVector loc) {

    for(int i = 0; i < 20; i++) {

      particles.add(new FX_RandomParticle(loc.copy()));

    }

  }

  // update, render particle mỗi frame
  void run() {
    PVector camPos = camera.getPos();

    for(int i = particles.size()-1; i >= 0; i--) {

      FX_Particle p = particles.get(i);

      p.update();
      
      // Task 3.3: Frustum Culling for particles
      if (isVisible(p, camPos)) {
        p.render();
      }

      if(p.isDead()) {
        particles.remove(i);
      }
    }
  }

  boolean isVisible(FX_Particle p, PVector camPos) {
    float margin = 10; // Particles are small
    return p.pos.x > camPos.x - margin && 
           p.pos.x < camPos.x + camera.w + margin && 
           p.pos.y > camPos.y - margin && 
           p.pos.y < camPos.y + camera.h + margin;
  }
}
