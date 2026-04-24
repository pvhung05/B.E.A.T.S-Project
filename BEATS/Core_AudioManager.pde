class AudioManager implements IEventListener {
    AudioManager() {
        systemBus.subscribe(EventType.EVENT_AUDIO_PLAY, this);
        systemBus.subscribe(EventType.EVENT_ENTITY_DESTROYED, this);
    }

    void onEvent(EventType type, Object payload) {
        if (type == EventType.EVENT_AUDIO_PLAY) {
            handleAudioPlay(payload);
        } else if (type == EventType.EVENT_ENTITY_DESTROYED) {
            handleCullSound(payload);
        }
    }

    private void handleAudioPlay(Object payload) {
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
        
        // Map filename to Minim sample/player and play
        playAudioSample(sampleName, normalizedVolume);
    }
    
    private void playAudioSample(String filename, float volume) {
        AudioSample sample = null;
        AudioPlayer player = null;
        float finalVolume = volume;
        
        if ("amthanhbutton.mp3".equals(filename)) {
            sample = SoundAssets.BUTTON_SOUND;
            finalVolume = volume * UIState.sfxVolume;  // Apply SFX volume
        } else if ("amthanhspawn.mp3".equals(filename)) {
            sample = SoundAssets.SPAWN_SOUND;
            finalVolume = volume * UIState.sfxVolume;  // Apply SFX volume
        } else if ("amthanhcull.mp3".equals(filename)) {
            sample = SoundAssets.CULL_SOUND;
            finalVolume = volume * UIState.sfxVolume;  // Apply SFX volume
        } else if ("nhacnen.mp3".equals(filename)) {
            player = SoundAssets.BACKGROUND_SOUND;
            finalVolume = volume * UIState.musicVolume;  // Apply Music volume
        }
        
        finalVolume = constrain(finalVolume, 0, 1);
        
        if (sample != null) {
            SoundAssets.setSampleVolume(sample, finalVolume);
            sample.trigger();
        } else if (player != null) {
            SoundAssets.setPlayerVolume(player, finalVolume);
            if (!player.isPlaying()) {
                player.play();
            }
        }
    }
    
    void setMusicVolume(float vol) {
        float finalVol = constrain(vol, 0, 1);
        if (SoundAssets.BACKGROUND_SOUND != null) {
            SoundAssets.setBackgroundVolume(finalVol);
            
            if (!isPaused && !SoundAssets.BACKGROUND_SOUND.isPlaying()) {
                SoundAssets.BACKGROUND_SOUND.loop();
            }
            
            println("Music volume: " + nf(finalVol, 0, 2));
        }
    }

    private void handleCullSound(Object payload) {
        if (!(payload instanceof Object[])) return;
        Object[] data = (Object[]) payload;
        
        // Check if this is user cull (4th parameter = "CULL")
        if (data.length > 3 && "CULL".equals(data[3])) {
            playAudioSample("amthanhcull.mp3", 1.0f);
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