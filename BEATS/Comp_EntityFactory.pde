// EntityFactory.pde
// Loads JSON definitions and assembles ECS entities with components.

class EntityFactory {

    int spawn(Coordinator coordinator, EntityType species, float x, float y, float initialEnergyPct) {
        int entity = coordinator.createEntity();
        if (entity == -1) return -1;

        // Common components
        coordinator.addComponent(entity, new CSpecies(species));

        if (species == EntityType.CORPSE) {
            coordinator.addComponent(entity, new CTransform(x, y, 15, 8));
            // TODO: @[Core] thêm CVelocity(0, 1.5, 0) vào CORPSE để sys movement handle việc nó chìm xuống đáy cho cua ăn.
            coordinator.addComponent(entity, new CCorpse(300));
            // Energy level for decomposers to consume
            coordinator.addComponent(entity, new CEnergy(initialEnergyPct, initialEnergyPct, 0, Float.MAX_VALUE));
            return entity;
        }

        float maxEnergy = cfgFloat(species.name().toLowerCase(), "energy", "maxEnergy");
        float metabolism = cfgFloat(species.name().toLowerCase(), "energy", "metabolismRate");
        float reproduceThreshold = cfgFloat(species.name().toLowerCase(), "reproduction", "energyThreshold");
        float currentEnergy = initialEnergyPct >= 0 ? maxEnergy * initialEnergyPct : maxEnergy;

        float minDepth = cfgFloat(species.name().toLowerCase(), "ecology", "minDepth");
        float maxDepth = cfgFloat(species.name().toLowerCase(), "ecology", "maxDepth");

        float speed = cfgFloatOr(species.name().toLowerCase(), "movement", "speed", 0);
        float turnRate = cfgFloatOr(species.name().toLowerCase(), "movement", "turnRate", 0);

        float vision = cfgFloatOr(species.name().toLowerCase(), "feeding", "visionRadius", 0);
        float attack = cfgFloatOr(species.name().toLowerCase(), "feeding", "attackRadius", 15);
        
        float hunger = cfgFloatOr(species.name().toLowerCase(), "energy", "hungerThreshold", 0.5f);
        float gain = cfgFloatOr(species.name().toLowerCase(), "energy", "energyGain", 10.0f);

        // Species-specific setup
        switch(species) {
            case ALGAE:
                coordinator.addComponent(entity, new CTransform(x, y, 8, 8));
                coordinator.addComponent(entity, new CEnergy(currentEnergy, maxEnergy, metabolism, reproduceThreshold));
                coordinator.addComponent(entity, new CEcology(minDepth, maxDepth));
                coordinator.addComponent(entity, new CProducer(cfgFloat("algae", "energy", "photosynthesisRate")));
                break;
            case SARDINE:
                coordinator.addComponent(entity, new CTransform(x, y, 12, 6));
                coordinator.addComponent(entity, new CVelocity(random(-1,1), random(-1,1)));
                coordinator.addComponent(entity, new CEnergy(currentEnergy, maxEnergy, metabolism, reproduceThreshold));
                coordinator.addComponent(entity, new CEcology(minDepth, maxDepth));
                coordinator.addComponent(entity, new CSteering(speed, turnRate));
                coordinator.addComponent(entity, new CSenses(vision, attack));
                coordinator.addComponent(entity, new CDiet(hunger * maxEnergy, gain, EntityType.ALGAE));
                break;
            case SHARK:
                coordinator.addComponent(entity, new CTransform(x, y, 35, 15));
                coordinator.addComponent(entity, new CVelocity(random(-1,1), random(-1,1)));
                coordinator.addComponent(entity, new CEnergy(currentEnergy, maxEnergy, metabolism, reproduceThreshold));
                coordinator.addComponent(entity, new CEcology(minDepth, maxDepth));
                coordinator.addComponent(entity, new CSteering(speed, turnRate));
                coordinator.addComponent(entity, new CSenses(vision, attack));
                coordinator.addComponent(entity, new CDiet(hunger * maxEnergy, gain, EntityType.SARDINE));
                break;
            case CRAB:
                coordinator.addComponent(entity, new CTransform(x, y, 18, 12));
                coordinator.addComponent(entity, new CVelocity(random(-1,1), random(-1,1)));
                coordinator.addComponent(entity, new CEnergy(currentEnergy, maxEnergy, metabolism, reproduceThreshold));
                coordinator.addComponent(entity, new CEcology(minDepth, maxDepth));
                coordinator.addComponent(entity, new CSteering(speed, turnRate));
                coordinator.addComponent(entity, new CSenses(vision, attack));
                coordinator.addComponent(entity, new CDiet(hunger * maxEnergy, gain, EntityType.CORPSE));
                break;
        }

        return entity;
    }
}
