
abstract class BaseEntity implements IObject {
    EntityType type;
    float x, y;
    float velocityX, velocityY;
    boolean dead = false;
    boolean active = true;


    BaseEntity(EntityType type, float x, float y) {
        this.x = x;
        this.y = y;
        this.type = type;
    }

    abstract void update();

    boolean isDead() {
        return dead;
    }

    boolean isActive() {
        return active;
    }

    void markForDeletion() {
        this.dead = true;
    }
}
