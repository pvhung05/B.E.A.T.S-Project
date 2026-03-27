/**
 * @TechArt — stress cho hiệu ứng; chỉ đọc UIState.
 * Inner class: chỉ dùng static final cho hằng số; method gọi qua instance (xem FX_Manager).
 */
class FX_EnvironmentVisuals {

    static final float OPTIMAL_TEMP_MIN = 16f;
    static final float OPTIMAL_TEMP_MAX = 26f;
    static final float POLLUTION_STRESS_THRESHOLD = 38f;

    float stressFactor(float worldX, float worldY) {
        float temp = UIState.temperature;
        float pol = UIState.pollution;

        float tempNorm = 0;
        if (temp < OPTIMAL_TEMP_MIN) {
            tempNorm = (OPTIMAL_TEMP_MIN - temp) / max(1f, OPTIMAL_TEMP_MIN + 20f);
        } else if (temp > OPTIMAL_TEMP_MAX) {
            tempNorm = (temp - OPTIMAL_TEMP_MAX) / max(1f, 50f - OPTIMAL_TEMP_MAX);
        }
        tempNorm = constrain(tempNorm, 0, 1);

        float polNorm = 0;
        if (pol > POLLUTION_STRESS_THRESHOLD) {
            polNorm = (pol - POLLUTION_STRESS_THRESHOLD) / (100f - POLLUTION_STRESS_THRESHOLD);
        }
        polNorm = constrain(polNorm, 0, 1);

        return max(tempNorm, polNorm);
    }

    String dominantMode(float worldX, float worldY) {
        float temp = UIState.temperature;
        float pol = UIState.pollution;

        float tempNorm = 0;
        if (temp < OPTIMAL_TEMP_MIN) {
            tempNorm = (OPTIMAL_TEMP_MIN - temp) / max(1f, OPTIMAL_TEMP_MIN + 20f);
        } else if (temp > OPTIMAL_TEMP_MAX) {
            tempNorm = (temp - OPTIMAL_TEMP_MAX) / max(1f, 50f - OPTIMAL_TEMP_MAX);
        }
        tempNorm = constrain(tempNorm, 0, 1);

        float polNorm = pol > POLLUTION_STRESS_THRESHOLD
            ? constrain((pol - POLLUTION_STRESS_THRESHOLD) / (100f - POLLUTION_STRESS_THRESHOLD), 0, 1)
            : 0;

        if (tempNorm > polNorm + 0.08f) return "TEMP";
        if (polNorm > tempNorm + 0.08f) return "POLLUTION";
        return "BOTH";
    }
}
