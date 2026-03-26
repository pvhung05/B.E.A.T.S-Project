
abstract class BaseEntity implements IObject {
  // TODO[@Comp-Eng]: Implement update() logic for internal state mutation based on environmental deltas.
  // DO NOT declare variables outside this class. Handle generic internal state mutation.

  float x, y;
  float velocityX, velocityY;
  boolean dead = false;

  BaseEntity(float x, float y) {
    this.x = x;
    this.y = y;
  }

  // void update() {
  // Localized logic: e.g., orbit rotation, state degradation, local animation
  // }

  // void render() {
  // TODO[@Tech-Art]: Replace this solid fill() with a procedural lerpColor() driven by the component's
  // normalized active state. Target 60 FPS.

  // TODO[@Comp-Eng]: Concrete objects will process their internal state here.
  // }

  boolean isDead() {
    return dead;
  }

  void markForDeletion() {
    this.dead = true;
  }
}