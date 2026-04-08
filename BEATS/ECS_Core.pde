// ECS_Core.pde
// Core classes for the Entity-Component-System architecture.

abstract class Component {
}

class Entity implements IObject {
    HashMap<Class<?>, Component> components = new HashMap<Class<?>, Component>();
    boolean dead = false;

    Entity() {
    }

    <T extends Component> void addComponent(T component) {
        components.put(component.getClass(), component);
    }

    <T extends Component> T getComponent(Class<T> type) {
        return type.cast(components.get(type));
    }

    boolean hasComponent(Class<?> type) {
        return components.containsKey(type);
    }

    void removeComponent(Class<?> type) {
        components.remove(type);
    }

    // From IObject
    boolean isSelected(float mx, float my) {
        if (hasComponent(CTransform.class)) {
            CTransform t = getComponent(CTransform.class);
            float left = t.x - t.w / 2;
            float right = t.x + t.w / 2;
            float bottom = t.y + t.h / 2;
            float top = t.y - t.h / 2;
            return (mx >= left && mx <= right && my >= top && my <= bottom);
        }
        return false;
    }

    boolean isDead() {
        return dead;
    }
}

abstract class System {
    abstract void update(ArrayList<Entity> entities, QuadTree spatialTree);
}
