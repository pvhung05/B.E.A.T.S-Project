class FX_Manager implements IEventListener {
  FX_Manager() {
    systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
  }

  void onEvent(EventType type, Object payload) {
    // TODO[@Tech-Art]: Process EVENT_ENTITY_DESTROYED payload.
    // Trigger procedural particle emission or screen shake. Map visual output to normalized 0.0-1.0 states.
    if (type == EventType.EVENT_ENTITY_DESTROYED) {
       Object[] p = (Object[]) payload;
       spawnParticles(new PVector((Float)p[1], (Float)p[2]));
    }
  }
  
  void spawnParticles(PVector loc) { /* Procedural Magic */ }
}
