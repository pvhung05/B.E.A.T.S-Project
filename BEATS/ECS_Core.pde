// ECS_Core.pde
// Core classes for the Entity-Component-System architecture.
// Optimized for O(1) operations using Sparse Sets (Array-based mapping).

import java.util.BitSet;
import java.util.Set;
import java.util.HashSet;
import java.util.Queue;
import java.util.ArrayDeque;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Collection;

final int MAX_ENTITIES = 10000;
final int MAX_COMPONENTS = 32;

abstract class Component {
}

class EntityRegistry {
    private Queue<Integer> availableEntities;
    private BitSet[] signatures;
    private int livingEntityCount = 0;

    EntityRegistry() {
        availableEntities = new ArrayDeque<Integer>();
        for (int i = 0; i < MAX_ENTITIES; i++) {
            availableEntities.add(i);
        }
        signatures = new BitSet[MAX_ENTITIES];
        for (int i = 0; i < MAX_ENTITIES; i++) {
            signatures[i] = new BitSet(MAX_COMPONENTS);
        }
    }

    int createEntity() {
        if (availableEntities.isEmpty()) {
            java.lang.System.err.println("Max entities reached!");
            return -1;
        }
        int id = availableEntities.poll();
        livingEntityCount++;
        return id;
    }

    void destroyEntity(int entity) {
        signatures[entity].clear();
        availableEntities.add(entity);
        livingEntityCount--;
    }

    void setSignature(int entity, BitSet signature) {
        signatures[entity] = (BitSet) signature.clone();
    }

    BitSet getSignature(int entity) {
        return signatures[entity];
    }
}

interface IComponentArray {
    void entityDestroyed(int entity);
}

class ComponentArray<T> implements IComponentArray {
    private Object[] componentArray;
    private int[] entityToIndexMap;
    private int[] indexToEntityMap;
    private int size = 0;

    ComponentArray() {
        componentArray = new Object[MAX_ENTITIES];
        entityToIndexMap = new int[MAX_ENTITIES];
        indexToEntityMap = new int[MAX_ENTITIES];
        java.util.Arrays.fill(entityToIndexMap, -1);
    }

    void insertData(int entity, T component) {
        int newIndex = size;
        entityToIndexMap[entity] = newIndex;
        indexToEntityMap[newIndex] = entity;
        componentArray[newIndex] = component;
        size++;
    }

    void removeData(int entity) {
        int indexOfRemovedEntity = entityToIndexMap[entity];
        int indexOfLastElement = size - 1;
        
        // Move last element to the hole
        componentArray[indexOfRemovedEntity] = componentArray[indexOfLastElement];

        int entityOfLastElement = indexToEntityMap[indexOfLastElement];
        entityToIndexMap[entityOfLastElement] = indexOfRemovedEntity;
        indexToEntityMap[indexOfRemovedEntity] = entityOfLastElement;

        entityToIndexMap[entity] = -1;
        componentArray[indexOfLastElement] = null; // Clean up for GC
        size--;
    }

    T getData(int entity) {
        int index = entityToIndexMap[entity];
        if (index == -1) return null;
        return (T) componentArray[index];
    }

    @Override
    public void entityDestroyed(int entity) {
        if (entityToIndexMap[entity] != -1) {
            removeData(entity);
        }
    }
}

class ComponentManager {
    private Map<Class<?>, Integer> componentTypes = new HashMap<Class<?>, Integer>();
    private Map<Class<?>, IComponentArray> componentArrays = new HashMap<Class<?>, IComponentArray>();
    private int nextComponentType = 0;

    <T> void registerComponent(Class<T> type) {
        componentTypes.put(type, nextComponentType++);
        componentArrays.put(type, new ComponentArray<T>());
    }

    <T> int getComponentType(Class<T> type) {
        return componentTypes.get(type);
    }

    <T> void addComponent(int entity, T component) {
        getComponentArray((Class<T>) component.getClass()).insertData(entity, component);
    }

    <T> void removeComponent(int entity, Class<T> type) {
        getComponentArray(type).removeData(entity);
    }

    <T> T getComponent(int entity, Class<T> type) {
        return getComponentArray(type).getData(entity);
    }

    private <T> ComponentArray<T> getComponentArray(Class<T> type) {
        return (ComponentArray<T>) componentArrays.get(type);
    }

    void entityDestroyed(int entity) {
        for (IComponentArray array : componentArrays.values()) {
            array.entityDestroyed(entity);
        }
    }
}

abstract class System {
    public Set<Integer> entities = new HashSet<Integer>();
    public abstract void update(Coordinator coordinator, QuadTree spatialTree);
}

class SystemManager {
    private Map<Class<?>, BitSet> signatures = new LinkedHashMap<Class<?>, BitSet>();
    private Map<Class<?>, System> systems = new LinkedHashMap<Class<?>, System>();

    <T extends System> void registerSystem(Class<T> type, T system) {
        systems.put(type, system);
    }

    <T extends System> void setSignature(Class<T> type, BitSet signature) {
        signatures.put(type, signature);
    }

    void entityDestroyed(int entity) {
        for (System system : systems.values()) {
            system.entities.remove(entity);
        }
    }

    void entitySignatureChanged(int entity, BitSet entitySignature) {
        for (Map.Entry<Class<?>, System> entry : systems.entrySet()) {
            Class<?> type = entry.getKey();
            System system = entry.getValue();
            BitSet systemSignature = signatures.get(type);

            // Check if entitySignature contains all bits of systemSignature
            BitSet check = (BitSet) systemSignature.clone();
            check.andNot(entitySignature);
            
            if (check.isEmpty()) {
                system.entities.add(entity);
            } else {
                system.entities.remove(entity);
            }
        }
    }
    
    Collection<System> getSystems() {
        return systems.values();
    }
}

class Coordinator {
    private EntityRegistry entityRegistry;
    private ComponentManager componentManager;
    private SystemManager systemManager;

    Coordinator() {
        entityRegistry = new EntityRegistry();
        componentManager = new ComponentManager();
        systemManager = new SystemManager();
    }

    int createEntity() {
        return entityRegistry.createEntity();
    }

    void destroyEntity(int entity) {
        entityRegistry.destroyEntity(entity);
        componentManager.entityDestroyed(entity);
        systemManager.entityDestroyed(entity);
    }

    <T> void registerComponent(Class<T> type) {
        componentManager.registerComponent(type);
    }

    <T> void addComponent(int entity, T component) {
        componentManager.addComponent(entity, component);
        BitSet signature = entityRegistry.getSignature(entity);
        signature.set(componentManager.getComponentType(component.getClass()));
        entityRegistry.setSignature(entity, signature);
        systemManager.entitySignatureChanged(entity, signature);
    }

    <T> void removeComponent(int entity, Class<T> type) {
        componentManager.removeComponent(entity, type);
        BitSet signature = entityRegistry.getSignature(entity);
        signature.clear(componentManager.getComponentType(type));
        entityRegistry.setSignature(entity, signature);
        systemManager.entitySignatureChanged(entity, signature);
    }

    <T> T getComponent(int entity, Class<T> type) {
        return componentManager.getComponent(entity, type);
    }
    
    <T> int getComponentType(Class<T> type) {
        return componentManager.getComponentType(type);
    }

    <T extends System> void registerSystem(Class<T> type, T system, Class<?>... componentTypes) {
        systemManager.registerSystem(type, system);
        BitSet signature = new BitSet(MAX_COMPONENTS);
        for (Class<?> ct : componentTypes) {
            signature.set(componentManager.getComponentType(ct));
        }
        systemManager.setSignature(type, signature);
    }
    
    Collection<System> getSystems() {
        return systemManager.getSystems();
    }
}
