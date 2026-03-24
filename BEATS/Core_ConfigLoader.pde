// Core_ConfigLoader.pde

class ConfigLoader {
    private HashMap<String, JSONObject> cache;

    ConfigLoader() {
        cache = new HashMap<String, JSONObject>();
    }

    /**
     * Returns the cached JSONObject for the given species name.
     * Loads from data/organisms/<name>.json on first call.
     */
    JSONObject load(String species) {
        if (!cache.containsKey(species)) {
            cache.put(species, loadJSONObject("organisms/" + species + ".json"));
        }
        return cache.get(species);
    }
}


float cfgFloat(String species, String section, String key) {
    return configLoader.load(species).getJSONObject(section).getFloat(key);
}

// Returns defaultVal when the key is absent
float cfgFloatOr(String species, String section, String key, float defaultVal) {
    JSONObject obj = configLoader.load(species).getJSONObject(section);
    return obj.hasKey(key) ? obj.getFloat(key) : defaultVal;
}

int cfgInt(String species, String section, String key) {
    return configLoader.load(species).getJSONObject(section).getInt(key);
}

boolean cfgBool(String species, String section, String key) {
    return configLoader.load(species).getJSONObject(section).getBoolean(key);
}
