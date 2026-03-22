final class FX_StressParticle extends FX_Particle {

  int r, g, b;

  FX_StressParticle(PVector start, int cr, int cg, int cb) {
    super(start);
    r = cr;
    g = cg;
    b = cb;
    vel = PVector.random2D().mult(random(0.4f, 2.2f));
    life = 25 + (int)random(18);
  }

  void update() {
    pos.add(vel);
    vel.mult(0.96f);
    life--;
  }

  void render() {
    PVector s = worldView.worldToScreenFX(pos.x, pos.y);
    noStroke();
    fill(r, g, b, min(255, life * 8));
    ellipse(s.x, s.y, 3.5f, 3.5f);
  }
}
