abstract class FX_Particle {

  PVector pos;
  PVector vel;
  float life;

  FX_Particle(PVector start) {
    pos = start.copy();
  }

  abstract void update();
  abstract void render();

  boolean isDead() {
    return life <= 0;
  }

}
