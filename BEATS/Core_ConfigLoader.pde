// Core_ConfigLoader.pde
// Static configuration utility for species-specific parameters

static class ConfigLoader {
    private static HashMap<String, JSONObject> cache = new HashMap<String, JSONObject>();
    private static PApplet app;

    static void init(PApplet _app) {
        app = _app;
    }

    /**
     * Returns the cached JSONObject for the given species name.
     * Loads from data/organisms/<name>.json on first call.
     */
    static JSONObject load(String species) {
        species = species.toLowerCase();
        if (!cache.containsKey(species)) {
            // Processing's loadJSONObject is available via the app instance
            cache.put(species, app.loadJSONObject("organisms/" + species + ".json"));
        }
        return cache.get(species);
    }
}

// Global static helpers for easy access to species configuration
static float cfgFloat(String species, String section, String key) {
    return ConfigLoader.load(species).getJSONObject(section).getFloat(key);
}

static float cfgFloatOr(String species, String section, String key, float defaultVal) {
    JSONObject speciesJson = ConfigLoader.load(species);
    if (speciesJson == null || !speciesJson.hasKey(section)) return defaultVal;
    JSONObject obj = speciesJson.getJSONObject(section);
    if (obj == null) return defaultVal;
    return obj.hasKey(key) ? obj.getFloat(key) : defaultVal;
}

static int cfgInt(String species, String section, String key) {
    return ConfigLoader.load(species).getJSONObject(section).getInt(key);
}

static boolean cfgBool(String species, String section, String key) {
    return ConfigLoader.load(species).getJSONObject(section).getBoolean(key);
}
