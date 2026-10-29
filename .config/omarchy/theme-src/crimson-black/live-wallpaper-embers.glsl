// Crimson Black live wallpaper: mpv user shader, run per output by omarchy-livewall through mpvpaper.
//
// Hooks MAIN (the only resizable stage before scaling) and renders at half the output size; mpv's scaler
// brings it to full resolution. Two layers: domain-warped crimson smoke rising from the bottom, and sparse
// embers that drift upward, sway and flicker. Everything moves on integer cycles of LOOP_SECONDS, so the loop
// is seamless. OLED rules: the top 6% (waybar zone) stays dark and anything under 3/255 is fully off.

//!HOOK MAIN
//!BIND HOOKED
//!DESC crimson-black embers
//!WIDTH OUTPUT.w 2 /
//!HEIGHT OUTPUT.h 2 /

const int FPS = 30;                // matches the lavfi source rate in omarchy-livewall
const int LOOP_SECONDS = 90;
const float TAU = 6.28318530718;
const vec3 CRIMSON = vec3(224.0, 17.0, 43.0) / 255.0;   // brand crimson
const vec3 EMBER = vec3(241.0, 65.0, 87.0) / 255.0;     // color9, brighter crimson for ember cores
const float SMOKE_PEAK = 0.55;
const float EMBER_PEAK = 0.9;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    mat2 rotate = mat2(0.8, -0.6, 0.6, 0.8);
    for (int octave = 0; octave < 5; octave++) {
        value += amplitude * noise(p);
        p = rotate * p * 2.03 + 11.7;
        amplitude *= 0.5;
    }
    return value;
}

// Sparse glowing points rising through three parallax layers. `t` is loop progress in [0, 1).
float embers(vec2 uv, float aspect, float t) {
    float glow = 0.0;
    for (int layer = 0; layer < 3; layer++) {
        float l = float(layer);
        float cells = 9.0 + 7.0 * l;                         // cells per screen height; nearer layers are bigger
        vec2 p = vec2(uv.x * aspect, uv.y) * cells;
        p.y += t * cells * (2.0 + l);                        // rise a whole number of screens per loop
        vec2 id = floor(p);
        float seed = hash(id + l * 17.0);
        if (seed > 0.22) continue;                           // ~22% of cells hold an ember
        vec2 center = vec2(0.25 + 0.5 * hash(id + 3.1), 0.25 + 0.5 * hash(id + 7.7));
        center.x += 0.18 * sin(TAU * (t * (3.0 + l) + seed * 10.0));
        float size = 0.06 + 0.06 * hash(id + 5.3);
        float flicker = 0.55 + 0.45 * sin(TAU * (t * (11.0 + 2.0 * l) + seed * 31.0));
        glow += flicker * smoothstep(size, 0.0, length(fract(p) - center)) * (1.0 - 0.25 * l);
    }
    return glow;
}

vec4 hook() {
    vec2 uv = HOOKED_pos;                                   // 0..1, y grows downward
    float aspect = target_size.x / target_size.y;           // real screen shape (HOOKED is the 16:9 dummy source); portrait-safe

    // Integer modulo keeps the phase exact no matter how long mpv has been running.
    int period = FPS * LOOP_SECONDS;
    float t = float(frame % period) / float(period);
    vec2 orbit = vec2(cos(TAU * t), sin(TAU * t));

    // Smoke: domain-warped noise drifting on a closed orbit, gathering toward the bottom.
    vec2 p = vec2(uv.x * aspect, uv.y) * 2.4;
    vec2 warp = vec2(fbm(p + 1.2 * orbit), fbm(p + vec2(5.2, 1.3) - 1.2 * orbit.yx));
    float smoke = smoothstep(0.35, 0.85, fbm(p + 2.0 * warp + 0.8 * orbit));
    float rise = smoothstep(-0.05, 1.0, uv.y);

    float barGuard = smoothstep(0.06, 0.20, uv.y);         // nothing lit behind the bar
    float emberFade = smoothstep(0.10, 0.75, uv.y);

    vec3 color = CRIMSON * (SMOKE_PEAK * smoke * rise + 0.10 * rise * rise);
    color += EMBER * EMBER_PEAK * embers(uv, aspect, t) * emberFade;
    color = min(color * barGuard, vec3(1.0));
    color *= step(3.0 / 255.0, max(color.r, max(color.g, color.b)));   // OLED: sub-3/255 pixels fully off
    return vec4(color, 1.0);
}
