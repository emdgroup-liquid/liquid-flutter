#version 460 core
#include <flutter/runtime_effect.glsl>

// ---------------------------------------------------------------------------
// Metaball shader — two modes from one program.
//
// mode 0 (fill): outputs vec4(a,a,a,a) — alpha mask for ShaderMask+dstIn.
// mode 1 (border): outputs borderColor * ringAlpha — painted above fill layer
//   via CustomPaint.
//
//   Border strategy: a pixel is in the border ring when it is outside the
//   smooth-union fill (dFinal > 0) but within borderWidth of the nearest
//   *individual* shape boundary (minShapeSDF < borderWidth). Individual shape
//   SDFs have gradient ≈ 1 everywhere, so borderWidth in SDF units equals
//   borderWidth in pixels — no stretching in the blend neck.
//
// Uniforms are packed into vec4 slots to stay within Metal's 30-buffer limit
// on iOS (Impeller maps every scalar uniform to a separate buffer slot).
//
// Float index map (Flutter FragmentShader.setFloat):
//   0-3   : u0  (sizeW, sizeH, blend, numShapes)
//   4-7   : u1  (pointerActive, pointerCx, pointerCy, pointerR)
//   8-11  : u2  (mode [0=fill, 1=border], borderWidth, pad, pad)
//   12-15 : u3  (borderColor RGBA — ignored in fill mode)
//
//   Per shape i (i=0..11), 8 floats at index 16 + i*8:
//     +0 type   (1=rrect, 2=ellipse)
//     +1 centerX
//     +2 centerY
//     +3 width
//     +4 height
//     +5 cornerRadius
//     +6 (padding)
//     +7 (padding)
//
// Max shapes: 12  (uses 4 + 12*2 = 28 vec4 buffer slots, within Metal's 30)
// ---------------------------------------------------------------------------

uniform vec4 u0; // (sizeW, sizeH, blend, numShapes)
uniform vec4 u1; // (pointerActive, pointerCx, pointerCy, pointerR)
uniform vec4 u2; // (mode, borderWidth, pad, pad)
uniform vec4 u3; // borderColor RGBA

// Each shape packed as two vec4:
//   sa = (type, cx, cy, w)
//   sb = (h, r, pad, pad)
uniform vec4 uS0a;  uniform vec4 uS0b;
uniform vec4 uS1a;  uniform vec4 uS1b;
uniform vec4 uS2a;  uniform vec4 uS2b;
uniform vec4 uS3a;  uniform vec4 uS3b;
uniform vec4 uS4a;  uniform vec4 uS4b;
uniform vec4 uS5a;  uniform vec4 uS5b;
uniform vec4 uS6a;  uniform vec4 uS6b;
uniform vec4 uS7a;  uniform vec4 uS7b;
uniform vec4 uS8a;  uniform vec4 uS8b;
uniform vec4 uS9a;  uniform vec4 uS9b;
uniform vec4 uS10a; uniform vec4 uS10b;
uniform vec4 uS11a; uniform vec4 uS11b;

// Convenience accessors
#define SHAPE_TYPE(sa)   (sa).x
#define SHAPE_CX(sa)     (sa).y
#define SHAPE_CY(sa)     (sa).z
#define SHAPE_W(sa)      (sa).w
#define SHAPE_H(sb)      (sb).x
#define SHAPE_R(sb)      (sb).y
#define SHAPE_FORCE(sb)  (sb).z

// ---------------------------------------------------------------------------
// SDF helpers
// ---------------------------------------------------------------------------

float sdfRRect(vec2 p, vec2 b, float r) {
    float shortest = min(b.x, b.y);
    r = min(r, shortest);
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

float sdfEllipse(vec2 p, vec2 ab) {
    ab = max(ab, vec2(1e-4));
    vec2 pn = p / ab;
    float k1 = length(pn);
    vec2  pn2 = p / (ab * ab);
    float k2 = length(pn2);
    return (k1 * (k1 - 1.0)) / max(k2, 1e-4);
}

float shapeSDF(vec2 p, vec4 sa, vec4 sb) {
    vec2 local   = p - vec2(SHAPE_CX(sa), SHAPE_CY(sa));
    vec2 halfExt = vec2(SHAPE_W(sa), SHAPE_H(sb)) * 0.5;
    if (SHAPE_TYPE(sa) == 2.0) return sdfEllipse(local, halfExt);
    return sdfRRect(local, halfExt, SHAPE_R(sb));
}

float smoothUnion(float d1, float d2, float k) {
    if (k <= 0.0) return min(d1, d2);
    float e = max(k - abs(d1 - d2), 0.0);
    return min(d1, d2) - e * e * 0.25 / k;
}

// Scale uBlend by the smaller of the two blobs' half-extents so a near-zero
// blob exerts near-zero pull on its neighbours.
// Reference size: 40px half-extent → full uBlend. Clamped to [0,1].
// Also multiplies by the minimum force of the two blobs.
float sizedBlend(vec4 sa, vec4 sb, vec4 sa2, vec4 sb2) {
    float ra = min(SHAPE_W(sa),  SHAPE_H(sb))  * 0.5;
    float rb = min(SHAPE_W(sa2), SHAPE_H(sb2)) * 0.5;
    float t  = clamp(min(ra, rb) / 40.0, 0.0, 1.0);
    float f  = min(SHAPE_FORCE(sb), SHAPE_FORCE(sb2));
    return u0.z * t * f; // u0.z = uBlend
}

// Blended scene SDF — used for fill boundary and pointer influence.
float sceneSDF(vec2 p, float n) {
    float d = shapeSDF(p, uS0a, uS0b);
    if (n > 1.0)  d = smoothUnion(d, shapeSDF(p, uS1a,  uS1b),  sizedBlend(uS0a,  uS0b,  uS1a,  uS1b));
    if (n > 2.0)  d = smoothUnion(d, shapeSDF(p, uS2a,  uS2b),  sizedBlend(uS1a,  uS1b,  uS2a,  uS2b));
    if (n > 3.0)  d = smoothUnion(d, shapeSDF(p, uS3a,  uS3b),  sizedBlend(uS2a,  uS2b,  uS3a,  uS3b));
    if (n > 4.0)  d = smoothUnion(d, shapeSDF(p, uS4a,  uS4b),  sizedBlend(uS3a,  uS3b,  uS4a,  uS4b));
    if (n > 5.0)  d = smoothUnion(d, shapeSDF(p, uS5a,  uS5b),  sizedBlend(uS4a,  uS4b,  uS5a,  uS5b));
    if (n > 6.0)  d = smoothUnion(d, shapeSDF(p, uS6a,  uS6b),  sizedBlend(uS5a,  uS5b,  uS6a,  uS6b));
    if (n > 7.0)  d = smoothUnion(d, shapeSDF(p, uS7a,  uS7b),  sizedBlend(uS6a,  uS6b,  uS7a,  uS7b));
    if (n > 8.0)  d = smoothUnion(d, shapeSDF(p, uS8a,  uS8b),  sizedBlend(uS7a,  uS7b,  uS8a,  uS8b));
    if (n > 9.0)  d = smoothUnion(d, shapeSDF(p, uS9a,  uS9b),  sizedBlend(uS8a,  uS8b,  uS9a,  uS9b));
    if (n > 10.0) d = smoothUnion(d, shapeSDF(p, uS10a, uS10b), sizedBlend(uS9a,  uS9b,  uS10a, uS10b));
    if (n > 11.0) d = smoothUnion(d, shapeSDF(p, uS11a, uS11b), sizedBlend(uS10a, uS10b, uS11a, uS11b));
    return d;
}

// Full scene SDF with pointer influence applied at position p.
// Extracted so the same deformation can be evaluated at neighbour positions.
float sceneSdfWithPointer(vec2 p, float n, float insideSign) {
    float d = sceneSDF(p, n);
    if (u1.x > 0.5 && u1.w != 0.0) {
        float dist = length(p - vec2(u1.y, u1.z));
        float bell = 1.0 - smoothstep(0.0, 120.0, dist);
        d = d + u1.w * insideSign * bell;
    }
    return d;
}

// Returns the minimum pointer-deformed SDF among p and its 4 axis-aligned
// neighbours at distance 'r', using a shared insideSign computed at p.
float minNeighbourSDF(vec2 p, float n, float r, float insideSign) {
    float d = sceneSdfWithPointer(p, n, insideSign);
    d = min(d, sceneSdfWithPointer(p + vec2( r,  0.0), n, insideSign));
    d = min(d, sceneSdfWithPointer(p + vec2(-r,  0.0), n, insideSign));
    d = min(d, sceneSdfWithPointer(p + vec2( 0.0,  r), n, insideSign));
    d = min(d, sceneSdfWithPointer(p + vec2( 0.0, -r), n, insideSign));
    return d;
}

out vec4 fragColor;

void main() {
    vec2  p = FlutterFragCoord().xy;
    float n = u0.w; // uNumShapes

    float dReal = sceneSDF(p, n);

    // Pointer influence — radial bell bump.
    // insideSign is computed once at p and reused for neighbour samples.
    float insideSign = 0.0;
    float dFinal = dReal;
    if (u1.x > 0.5 && u1.w != 0.0) { // u1.x=pointerActive, u1.w=pointerR
        float dAtPointer = sceneSDF(vec2(u1.y, u1.z), n);
        insideSign = mix(-1.0, 1.0, smoothstep(-20.0, 20.0, dAtPointer));
        float dist = length(p - vec2(u1.y, u1.z));
        float bell = 1.0 - smoothstep(0.0, 120.0, dist);
        dFinal = dReal + u1.w * insideSign * bell;
    }

    if (u2.x < 0.5) {
        // ---- mode 0: fill alpha mask ----
        // Used with ShaderMask + BlendMode.dstIn to clip the fill layer.
        float a = 1.0 - smoothstep(-0.5, 0.5, dFinal);
        fragColor = vec4(a, a, a, a);
    } else {
        // ---- mode 1: border ring ----
        // A pixel is a border pixel when it is outside the fill but has at
        // least one neighbour that is inside. We sample sceneSDF at the current
        // pixel and its 4 axis-aligned neighbours at distance borderWidth.
        // If the current pixel is outside (dFinal > 0) but the minimum over
        // all neighbours is inside (< 0), this pixel is on the border.
        //
        // This is pixel-accurate regardless of SDF gradient: borderWidth here
        // is a literal screen-space sample distance, not an SDF threshold.
        float bw = u2.y;
        float dNeighbourMin = minNeighbourSDF(p, n, bw, insideSign);

        // Smoothstep transitions for AA:
        //   inner edge — where the fill starts (dFinal crosses 0)
        //   outer edge — where the furthest neighbour crosses 0
        float innerAlpha = 1.0 - smoothstep(-0.5, 0.5, dFinal);
        float outerAlpha = 1.0 - smoothstep(-0.5, 0.5, dNeighbourMin);
        float ringAlpha  = clamp(outerAlpha - innerAlpha, 0.0, 1.0);
        fragColor = u3 * ringAlpha;
    }
}
