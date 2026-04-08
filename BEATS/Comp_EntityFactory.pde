// Comp_EntityFactory.pde
// Loads JSON definitions and builds Entity objects composed of components.

class EntityFactory {

    Entity spawn(EntityType species, float x, float y, float initialEnergyPct) {
        Entity e = new Entity();
        e.addComponent(new CSpecies(species));

        if (species == EntityType.CORPSE) {
            e.addComponent(new CTransform(x, y, 20, 20));
            e.addComponent(new CEnergy(initialEnergyPct, initialEnergyPct, 0, Float.MAX_VALUE));
            e.addComponent(new CCorpse(300));
            return e;
        }

        String s = species.name().toLowerCase();
        
        // Transform
        float w = 20, h = 20;
        if (species == EntityType.SHARK) { w = 40; h = 20; }
        else if (species == EntityType.SARDINE) { w = 15; h = 10; }
        else if (species == EntityType.ALGAE) { w = 10; h = 10; }
        e.addComponent(new CTransform(x, y, w, h));

        // Ecology
        e.addComponent(new CEcology(cfgFloat(s, "ecology", "minDepth"), cfgFloat(s, "ecology", "maxDepth")));

        // Energy
        float maxEnergy = cfgFloat(s, "energy", "maxEnergy");
        float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;
        e.addComponent(new CEnergy(currentEnergy, maxEnergy, cfgFloat(s, "energy", "metabolismRate"), cfgFloat(s, "reproduction", "energyThreshold")));

        // Locomotion & Senses & Diet
        if (species != EntityType.ALGAE) {
            float speed = cfgFloat(s, "movement", "speed");
            float turnRate = cfgFloat(s, "movement", "turnRate");
            e.addComponent(new CVelocity(random(-speed, speed), random(-speed, speed)));
            e.addComponent(new CSteering(speed, turnRate));
            
            float vision = cfgFloat(s, "feeding", "visionRadius");
            float attack = 15;
            if (species == EntityType.SHARK) attack = cfgFloat(s, "feeding", "attackRadius");
            else if (species == EntityType.SARDINE) attack = cfgFloatOr(s, "feeding", "attackRadius", 8.0f);
            else if (species == EntityType.CRAB) attack = cfgFloat(s, "feeding", "consumeRadius");
            e.addComponent(new CSenses(vision, attack));

            float hunger = cfgFloatOr(s, "energy", "hungerThreshold", 0.0f);
            float gain = cfgFloat(s, "energy", "energyGain");
            
            if (species == EntityType.SHARK) {
                e.addComponent(new CDiet(hunger, gain, EntityType.SARDINE));
            } else if (species == EntityType.SARDINE) {
                e.addComponent(new CDiet(hunger, gain, EntityType.ALGAE));
            } else if (species == EntityType.CRAB) {
                e.addComponent(new CDiet(hunger, gain, EntityType.CORPSE));
            }
        }

        // Producer specific
        if (species == EntityType.ALGAE) {
            e.addComponent(new CProducer(cfgFloat(s, "energy", "photosynthesisRate")));
        }

        return e;
    }
}
