import java.util.Map;
import java.util.HashMap;

class EventBus {
  private HashMap<EventType, ArrayList<IEventListener>> subscribers;

  EventBus() {
    subscribers = new HashMap<EventType, ArrayList<IEventListener>>();
    for (EventType type : EventType.values()) {
      subscribers.put(type, new ArrayList<IEventListener>());
    }
  }

  void subscribe(EventType type, IEventListener listener) {
    if (!subscribers.get(type).contains(listener)) {
      subscribers.get(type).add(listener);
    }
  }

  void publish(EventType type, Object payload) {
    ArrayList<IEventListener> listeners = subscribers.get(type);
    for (IEventListener listener : listeners) {
      listener.onEvent(type, payload);
    }
  }
}
