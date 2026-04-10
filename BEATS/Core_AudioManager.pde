class AudioManager implements IEventListener {
    AudioManager() {
        systemBus.subscribe(EventType.EVENT_AUDIO_PLAY, this);
    }

    void onEvent(EventType type, Object payload) {
        if (type == EventType.EVENT_AUDIO_PLAY) {
            if (!(payload instanceof Object[])) return;
            Object[] p = (Object[]) payload;
            if (p.length == 0 || p[0] == null) return;

            String sampleName = String.valueOf(p[0]);

            // Accept normalized (0..1) or legacy percentage (0..100) as payload[1].
            float rawVolume = 1.0f;
            if (p.length > 1 && p[1] != null) {
                rawVolume = toFloat(p[1], 1.0f);
            }
            float normalizedVolume = normalizeScalar(rawVolume);

            // Optional payload[2]: pitch/intensity scalar (normalized or percentage).
            float rawPitch = 0.5f;
            if (p.length > 2 && p[2] != null) {
                rawPitch = toFloat(p[2], 0.5f);
            }
            float normalizedPitch = normalizeScalar(rawPitch);

            println(
                "Audio sample=" + sampleName +
                " volumeN=" + nf(normalizedVolume, 0, 2) +
                " pitchN=" + nf(normalizedPitch, 0, 2)
            );
        }
    }

    private float normalizeScalar(float v) {
        if (v > 1.0f) return constrain(v / 100.0f, 0, 1);
        return constrain(v, 0, 1);
    }

    private float toFloat(Object value, float fallback) {
        if (value instanceof Float) return (Float)value;
        if (value instanceof Integer) return (float)((Integer)value).intValue();
        if (value instanceof Double) return (float)((Double)value).doubleValue();
        return fallback;
    }
}
