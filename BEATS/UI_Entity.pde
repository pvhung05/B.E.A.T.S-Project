// ======================================================
// UI_Entity.pde
// Test entities used for UI spawn/delete validation
// Safe to use alongside core-engine implementations
// ======================================================
// -------------------------
// Base class
// -------------------------
abstract class BaseEntityTest implements IObject {
  float x, y;
  float size;
  boolean dead = false;

  BaseEntityTest(float x, float y, float size) {
    this.x = x;
    this.y = y;
    this.size = size;
  }

  public boolean isSelected(float mx, float my) {
    return dist(mx, my, x, y) < size * 0.5;
  }

  public boolean isDead() {
    return dead;
  }
}

// ======================================================
// ALGAE TEST
// ======================================================
class AlgaeTest extends BaseEntityTest {

  AlgaeTest(float x, float y) {
    super(x, y, 12);
  }

  public void update() {
    // static
  }

  public void render() {
    fill(0, 200, 100);
    ellipse(x, y, size, size);
  }
}

// ======================================================
// CRAB TEST
// ======================================================
class CrabTest extends BaseEntityTest {

  float dir = 1;

  CrabTest(float x, float y) {
    super(x, y, 20);
  }

  public void update() {
    x += dir * 0.5;
    if (random(1) < 0.01) dir *= -1;
  }

  public void render() {
    pushStyle();
    fill(200, 80, 60);
    rectMode(CENTER);
    rect(x, y, size, size * 0.6);
    popStyle();
  }
}

// ======================================================
// SARDINE TEST
// ======================================================
class SardineTest extends BaseEntityTest {

  SardineTest(float x, float y) {
    super(x, y, 16);
  }

  public void update() {
    x += 1;
  }

  public void render() {
    pushStyle();
    fill(100, 150, 255);
    ellipse(x, y, size, size * 0.5);
    pushStyle();
  }
}

// ======================================================
// SHARK TEST
// ======================================================
class SharkTest extends BaseEntityTest {

  SharkTest(float x, float y) {
    super(x, y, 40);
  }

  public void update() {
    x += 0.3;
  }

  public void render() {
    pushStyle();
    fill(120);
    ellipse(x, y, size, size * 0.5);

    triangle(
      x - size * 0.5, y,
      x - size, y - size * 0.3,
      x - size, y + size * 0.3
    );
    popStyle();
  }
}

// ======================================================
// Factory for UI testing
// ======================================================
class EntityFactoryTest {

  IObject create(String type, float x, float y) {

    switch(type) {
    case "ALGAE":
      return new AlgaeTest(x, y);

    case "CRAB":
      return new CrabTest(x, y);

    case "SARDINE":
      return new SardineTest(x, y);

    case "SHARK":
      return new SharkTest(x, y);
    }

    println("Unknown test entity: " + type);
    return null;
  }
}

// ======================================================
// HUMAN TEST - player controlled entity
// ======================================================
class HumanTest extends BaseEntityTest {

  float speed = 2.0;

  float targetX;
  float targetY;

  HumanTest(float x, float y) {
    super(x, y, 24);
    targetX = x;
    targetY = y;
  }

  // Called by UI when right click occurs
  void setMoveTarget(float tx, float ty) {
    targetX = tx;
    targetY = ty;
  }

  public void update() {

    float dx = targetX - x;
    float dy = targetY - y;
    float distToTarget = sqrt(dx*dx + dy*dy);

    if (distToTarget > 1) {
      x += dx / distToTarget * speed;
      y += dy / distToTarget * speed;
    }
  }

  public void render() {
    pushStyle();

    fill(255, 220, 120);
    ellipse(x, y, size, size);

    // direction indicator
    stroke(0);
    line(x, y, targetX, targetY);

    popStyle();
  }
}
