/**
 * @TechArt — Chiếu world → màn hình cho lớp FX (instance, không static — tương thích inner class Java).
 * Dùng biến global worldView trong sketch. @Architect: gán camX, camY, zoom mỗi frame khi có camera.
 */
class WorldView {

  float camX = 0;
  float camY = 0;
  float zoom = 1f;
  float fxParallaxAmbientAmp = 1f;
  int frameCountForFx = 0;

  PVector worldToScreen(float wx, float wy) {
    float sx = (wx - camX) * zoom;
    float sy = (wy - camY) * zoom;
    return new PVector(sx, sy);
  }

  PVector worldToScreenFX(float wx, float wy) {
    int fc = frameCountForFx;
    PVector s = worldToScreen(wx, wy);
    s.x += (float)Math.sin(fc * 0.02f) * 4f * fxParallaxAmbientAmp * 0.35f;
    s.y += (float)Math.cos(fc * 0.017f) * 3f * fxParallaxAmbientAmp * 0.35f;
    return s;
  }
}
