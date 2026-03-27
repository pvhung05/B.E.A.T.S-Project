interface IEventListener {
    /**
     * Called by the EventBus when a subscribed event occurs.
     * @param type The EventType triggered.
     * @param payload Optional data associated with the event (e.g., Entity ID, Vector, JSON String).
     */
    void onEvent(EventType type, Object payload);
}
