// FORMAT: EVENT_<category>_<event>

enum EventType {
    // System State
    EVENT_APP_PAUSE,
    EVENT_APP_RESUME,

    // UI & Environment Input (Frontend)
    EVENT_UI_TOOL_SELECTED,
    EVENT_ENV_PARAM_CHANGED,
    EVENT_UI_SLIDER_CHANGED,

    // Entity Lifecycle (Frontend/Core Engineer)
    EVENT_ENTITY_SPAWN_REQUEST,
    EVENT_ENTITY_DESTROYED,

    // Audiovisual (Tech Art)
    EVENT_AUDIO_PLAY
}
