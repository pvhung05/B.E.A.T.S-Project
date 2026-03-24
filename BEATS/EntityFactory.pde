// EntityFactory.pde
// Loads JSON definitions and spawns concrete entities

static class EntityFactory {
  static HashMap<String, JSONObject> blueprints = new HashMap<String, JSONObject>();

  static void init(PApplet app, JSONArray speciesArray) {
    for (int i = 0; i < speciesArray.size(); i++) {
      String s = speciesArray.getString(i);
      try {
        blueprints.put(s.toLowerCase(), app.loadJSONObject(s.toLowerCase() + ".json"));
      } catch (Exception e) {
        System.err.println("Failed to load blueprint for: " + s);
      }
    }
  }

  static Organism spawn(String species, float x, float y, float initialEnergyPct) {
    species = species.toLowerCase();
    JSONObject bp = blueprints.get(species);
    if (bp == null) {
      System.err.println("Blueprint not found for: " + species);
      return null;
    }

    JSONObject energy = bp.getJSONObject("energy");
    JSONObject ecology = bp.getJSONObject("ecology");

    float maxEnergy = energy.getFloat("maxEnergy");
    float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;
    float minD = ecology.getFloat("minDepth");
    float maxD = ecology.getFloat("maxDepth");

    if (species.equals("crab")) {
      return new Crab(x, y, currentEnergy, maxEnergy, minD, maxD);
    } else if (species.equals("algae")) {
      return new Algae(x, y, currentEnergy, maxEnergy, minD, maxD);
    } else if (species.equals("shark")) {
      return new Shark(x, y, currentEnergy, maxEnergy, minD, maxD);
    } else if (species.equals("sardine")) {
      return new Sardine(x, y, currentEnergy, maxEnergy, minD, maxD);
    }
    return null;
  }
}
