abstract class BaseEntity implements IObject {
  // PURE DATA. NO PROCESSING CORE LIBRARIES ALLOWED.
  
  // Tagging: Essential for the System_Renderer to identify the payload type.
  final EntityType type; 
  
  // Kinematics
  float x, y;
  float velocityX, velocityY;
  
  // Lifecycle state
  boolean dead = false;

  BaseEntity(EntityType type, float x, float y) {
    this.type = type;
    this.x = x;
    this.y = y;
  }

  // The strict mathematical tick. 
  abstract void update();

  boolean isDead() {
    return dead;
  }

  void markForDeletion() {
    this.dead = true;
  }
}