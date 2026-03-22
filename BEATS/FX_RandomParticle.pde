final class FX_RandomParticle extends FX_Particle {

  FX_RandomParticle(PVector start) {
    super(start);

    vel = PVector.random2D().mult(random(1,3));
    life = 60;
  }

  void update() {
    pos.add(vel);
    vel.mult(0.98);
    life--;
  }

  void render() {
    PVector s = worldView.worldToScreenFX(pos.x, pos.y);
    noStroke();
    fill(255, 80, 80, life * 4);
    ellipse(s.x, s.y, 4, 4);
  }

}
