final class FX_RandomParticle extends FX_Particle { // TODO: @[FX] I suggest moving all this FX_<ex>Particle classes to a single Module_Particles.pde file

    FX_RandomParticle(PVector start) {
        super(start);

        vel = PVector.random2D().mult(random(1, 3));
        life = 60;
    }

    void update() {
        pos.add(vel);
        vel.mult(0.98);
        life--;
    }

    void render() {
        noStroke();
        fill(255, 80, 80, life * 4);
        ellipse(pos.x, pos.y, 4, 4);
    }
}
