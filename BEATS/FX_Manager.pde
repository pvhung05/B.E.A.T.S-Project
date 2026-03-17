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

    for(int i = particles.size()-1; i >= 0; i--) {

      FX_Particle p = particles.get(i);

      p.update();
      p.render();

      if(p.isDead()) {

        particles.remove(i);

      }

    }

  }

}
