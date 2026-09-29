// the cursor itself glides between cells instead of jumping.
// Unlike a trail shader, this one is the focused cursor, so it
// requires ghostty's own cursor to be hidden:
//
//     cursor-opacity = 0
//     custom-shader  = "./shaders/cursor_glide.glsl"
//
// The block is opaque, so it covers the glyph in the cell it lands on.


// --- CONFIGURATION ---
const float DURATION  = 0.14;  // seconds for one glide
const float AA        = 1.0;   // edge antialiasing in pixels
const float BAR_SCALE = 0.65;  // bar width, as a part of the cell's bar width
const float BAR_MIN   = 1.0;   // smallest bar width in pixels

// The color uniforms arrive as sRGB, and iChannel0 and the output are
// linear. `alpha-blending` selects the space: keep this conversion for
// `linear` and `linear-corrected`, and remove it for `srgb`.
vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

// Ghostty resolves iCursorColor from `cursor-color`, and puts the foreground
// color there when that option is empty. A zero vector means neither color
// reached the shader; the foreground color takes its place.
vec3 cursorColor() {
    vec3 c = dot(iCursorColor, iCursorColor) > 0.0 ? iCursorColor : iForegroundColor;
    return sRGBToLinear(c);
}

// EaseOutCubic — swap for any of the curves in cursor_sweep.glsl.
float ease(float x) {
    return 1.0 - pow(1.0 - x, 3.0);
}

float sdfRect(vec2 p, vec2 center, vec2 halfSize) {
    vec2 d = abs(p - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// iCurrentCursor/iPreviousCursor are (left, top-edge, width, height) in
// pixels with shadertoy's y-up convention: the rect spans [y - h, y].
// The result is (center.xy, halfSize.xy). A bar keeps its left edge, so
// the thinner bar stays against the cell boundary.
vec4 cursorRect(vec4 r, int style) {
    float w = r.z;
    if (style == CURSORSTYLE_BAR) w = max(w * BAR_SCALE, BAR_MIN);
    return vec4(r.x + w * 0.5, r.y - r.w * 0.5, w * 0.5, r.w * 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 tex = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = tex;

    if (iCursorVisible == 0 || iFocus == 0) return;
    if (iCurrentCursorStyle == CURSORSTYLE_BLOCK_HOLLOW ||
        iCurrentCursorStyle == CURSORSTYLE_LOCK) return;

    vec4 cur       = iCurrentCursor;
    vec4 prev      = iPreviousCursor;
    int  prevStyle = iPreviousCursorStyle;
    // An all-zero previous cursor is the first frame after launch; don't
    // glide in from the window corner.
    if (dot(prev.zw, prev.zw) == 0.0) {
        prev      = cur;
        prevStyle = iCurrentCursorStyle;
    }

    vec4 from = cursorRect(prev, prevStyle);
    vec4 to   = cursorRect(cur, iCurrentCursorStyle);

    float t = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    float e = ease(t);

    vec2 center   = mix(from.xy, to.xy, e);
    vec2 halfSize = mix(from.zw, to.zw, e);

    float coverage = 1.0 - smoothstep(0.0, AA, sdfRect(fragCoord, center, halfSize));
    if (coverage <= 0.0) return;

    fragColor = mix(tex, vec4(cursorColor(), 1.0), coverage);
}
