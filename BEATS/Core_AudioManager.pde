class AudioManager implements IEventListener {
    AudioManager() {
        systemBus.subscribe(EventType.EVENT_AUDIO_PLAY, this);
    }

    void onEvent(EventType type, Object payload) {
        // TODO @[FX]: Process EVENT_AUDIO_PLAY_SAMPLE. Map audio volume/pitch to normalized
        // physics impact data (0.0 to 1.0) passed in the payload.
        // Also please contact @[SysDes] to design mp3/wav/ogg data location before implement
        if (type == EventType.EVENT_AUDIO_PLAY) {
            Object[] p = (Object[]) payload;
            println("Playing procedural audio sample: " + p[0] + " at volume: " + p[1]);
        }
    }
}
