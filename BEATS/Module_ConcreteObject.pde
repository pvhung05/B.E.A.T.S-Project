// Module_ConcreteObject.pde
// Where all the final classes are defined

final class Crab extends Decomposer {  
    
    Crab(float x, float y, float energyLevel) {
        super(x, y, energyLevel, 50.0f, 0.75f, 1.0f);
    }
    
    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        // TODO: implement movement logic for crab (e.g., random walk, or move towards food if detected).
    }

    @Override
    void render() {
        if (isDead()) return;
        pushStyle();
        fill(180, 80, 50);
        stroke(100, 40, 20);
        rectMode(CENTER);
        rect(x, y, 25, 15, 4);
        line(x-12, y-7, x-18, y-12);
        line(x+12, y-7, x+18, y-12);
        popStyle();
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 15;
    }

    @Override
    boolean canConsume(Organism target) {
        return target.isDead();
    }

    @Override
    void consumeCorpse(Organism target) {
        energyLevel = min(maxEnergy, energyLevel + 15);
        target.dead = true;
    }

    @Override
    void searchCorpse() {
        // TODO: implement corpse searching logic
    }
}

final class Algae extends Producer { 
    
    Algae(float x, float y, float energy, float maxE, float dMin, float dMax) {
        super(x, y, energy, maxE, dMin, dMax);
    }

    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        photosynthesis();  
        checkReproduction();
    }

    @Override
    void render() {
        if (isDead()) return;
        pushStyle();
        noStroke();
        fill(60, 180, 80, 200);
        ellipse(x, y, 12, 12);
        fill(40, 140, 60, 150);
        ellipse(x, y-5, 8, 12);
        popStyle();
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 10;
    }

    @Override
    boolean canConsume(Organism target) {
        return false;
    }

    @Override
    void photosynthesis() {
        energyLevel = min(maxEnergy, energyLevel + 0.15f);
    }

    void checkReproduction() {
        if (energyLevel >= maxEnergy * 0.9f) {
            energyLevel *= 0.5f;
            systemBus.publish(EventType.EVENT_ENTITY_SPAWN_REQUEST, new Object[]{"ALGAE", x + random(-20, 20), y + random(-20, 20), null});
        }
    }
}

final class Sardine extends Organism {
    Sardine(float x, float y, float energy) {
        super(x, y, energy, 30.0f, 0.2f, 0.6f);
    }

    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        // TODO: Schooling behavior
    }

    @Override
    void render() {
        if (isDead()) return;
        pushStyle();
        fill(150, 190, 220);
        stroke(100, 140, 170);
        ellipse(x, y, 20, 8);
        triangle(x-10, y, x-15, y-5, x-15, y+5);
        popStyle();
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 12;
    }

    @Override
    boolean canConsume(Organism target) {
        return target instanceof Algae && !target.isDead();
    }
}

final class Shark extends Organism {
    Shark(float x, float y, float energy) {
        super(x, y, energy, 200.0f, 0.3f, 0.9f);
    }

    @Override
    void update() {
        if (isDead()) return;
        updateBiologicalState();
        // TODO: Hunting behavior
    }

    @Override
    void render() {
        if (isDead()) return;
        pushStyle();
        fill(100, 110, 130);
        stroke(60, 70, 80);
        ellipse(x, y, 50, 20);
        triangle(x, y-10, x-5, y-25, x+15, y-10); // Fin
        triangle(x-25, y, x-35, y-10, x-35, y+10); // Tail
        popStyle();
    }

    @Override
    boolean isSelected(float mx, float my) {
        return dist(mx, my, x, y) < 25;
    }

    @Override
    boolean canConsume(Organism target) {
        return (target instanceof Sardine) && !target.isDead();
    }
}
