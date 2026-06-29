#version 460 core
#include <flutter/runtime_effect.glsl>

// ---------------------------------------------------------------------------
// Pure alpha-mask metaball shader.
// Outputs vec4(a,a,a,a) — used with BlendMode.dstIn to mask a widget layer.
//
// Float index map:
//   0-1  : uSize        (vec2)
//   2    : uBlend       (float)
//   3    : uNumShapes   (float, 1..15)
//   4    : uPointerActive (float, 0=off 1=on)
//   5    : uPointerCx
//   6    : uPointerCy
//   7    : uPointerR
//
//   Per shape i (i=0..14), 6 floats at index 8 + i*6:
//     +0 type   (1=rrect, 2=ellipse)
//     +1 centerX
//     +2 centerY
//     +3 width
//     +4 height
//     +5 cornerRadius
// ---------------------------------------------------------------------------

uniform vec2  uSize;
uniform float uBlend;
uniform float uNumShapes;
uniform float uPointerActive;
uniform float uPointerCx;
uniform float uPointerCy;
uniform float uPointerR;

// Shape 0
uniform float uS0Type; uniform float uS0Cx; uniform float uS0Cy;
uniform float uS0W;    uniform float uS0H;  uniform float uS0R;
// Shape 1
uniform float uS1Type; uniform float uS1Cx; uniform float uS1Cy;
uniform float uS1W;    uniform float uS1H;  uniform float uS1R;
// Shape 2
uniform float uS2Type; uniform float uS2Cx; uniform float uS2Cy;
uniform float uS2W;    uniform float uS2H;  uniform float uS2R;
// Shape 3
uniform float uS3Type; uniform float uS3Cx; uniform float uS3Cy;
uniform float uS3W;    uniform float uS3H;  uniform float uS3R;
// Shape 4
uniform float uS4Type; uniform float uS4Cx; uniform float uS4Cy;
uniform float uS4W;    uniform float uS4H;  uniform float uS4R;
// Shape 5
uniform float uS5Type; uniform float uS5Cx; uniform float uS5Cy;
uniform float uS5W;    uniform float uS5H;  uniform float uS5R;
// Shape 6
uniform float uS6Type; uniform float uS6Cx; uniform float uS6Cy;
uniform float uS6W;    uniform float uS6H;  uniform float uS6R;
// Shape 7
uniform float uS7Type; uniform float uS7Cx; uniform float uS7Cy;
uniform float uS7W;    uniform float uS7H;  uniform float uS7R;
// Shape 8
uniform float uS8Type; uniform float uS8Cx; uniform float uS8Cy;
uniform float uS8W;    uniform float uS8H;  uniform float uS8R;
// Shape 9
uniform float uS9Type; uniform float uS9Cx; uniform float uS9Cy;
uniform float uS9W;    uniform float uS9H;  uniform float uS9R;
// Shape 10
uniform float uS10Type; uniform float uS10Cx; uniform float uS10Cy;
uniform float uS10W;    uniform float uS10H;  uniform float uS10R;
// Shape 11
uniform float uS11Type; uniform float uS11Cx; uniform float uS11Cy;
uniform float uS11W;    uniform float uS11H;  uniform float uS11R;
// Shape 12
uniform float uS12Type; uniform float uS12Cx; uniform float uS12Cy;
uniform float uS12W;    uniform float uS12H;  uniform float uS12R;
// Shape 13
uniform float uS13Type; uniform float uS13Cx; uniform float uS13Cy;
uniform float uS13W;    uniform float uS13H;  uniform float uS13R;
// Shape 14
uniform float uS14Type; uniform float uS14Cx; uniform float uS14Cy;
uniform float uS14W;    uniform float uS14H;  uniform float uS14R;

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

float shapeSDF(vec2 p, float cx, float cy, float w, float h, float r, float type) {
    vec2 local   = p - vec2(cx, cy);
    vec2 halfExt = vec2(w, h) * 0.5;
    if (type == 2.0) return sdfEllipse(local, halfExt);
    return sdfRRect(local, halfExt, r);
}

float smoothUnion(float d1, float d2, float k) {
    if (k <= 0.0) return min(d1, d2);
    float e = max(k - abs(d1 - d2), 0.0);
    return min(d1, d2) - e * e * 0.25 / k;
}

// Scale uBlend by the smaller of the two blobs' half-extents so a near-zero
// blob exerts near-zero pull on its neighbours.
// Reference size: 40px half-extent → full uBlend. Clamped to [0,1].
float sizedBlend(float wa, float ha, float wb, float hb) {
    float ra = min(wa, ha) * 0.5;
    float rb = min(wb, hb) * 0.5;
    float t  = clamp(min(ra, rb) / 40.0, 0.0, 1.0);
    return uBlend * t;
}

float sceneSDF(vec2 p, float n) {
    float d = shapeSDF(p, uS0Cx, uS0Cy, uS0W, uS0H, uS0R, uS0Type);
    if (n > 1.0)  d = smoothUnion(d, shapeSDF(p, uS1Cx,  uS1Cy,  uS1W,  uS1H,  uS1R,  uS1Type),  sizedBlend(uS0W, uS0H, uS1W,  uS1H));
    if (n > 2.0)  d = smoothUnion(d, shapeSDF(p, uS2Cx,  uS2Cy,  uS2W,  uS2H,  uS2R,  uS2Type),  sizedBlend(uS1W, uS1H, uS2W,  uS2H));
    if (n > 3.0)  d = smoothUnion(d, shapeSDF(p, uS3Cx,  uS3Cy,  uS3W,  uS3H,  uS3R,  uS3Type),  sizedBlend(uS2W, uS2H, uS3W,  uS3H));
    if (n > 4.0)  d = smoothUnion(d, shapeSDF(p, uS4Cx,  uS4Cy,  uS4W,  uS4H,  uS4R,  uS4Type),  sizedBlend(uS3W, uS3H, uS4W,  uS4H));
    if (n > 5.0)  d = smoothUnion(d, shapeSDF(p, uS5Cx,  uS5Cy,  uS5W,  uS5H,  uS5R,  uS5Type),  sizedBlend(uS4W, uS4H, uS5W,  uS5H));
    if (n > 6.0)  d = smoothUnion(d, shapeSDF(p, uS6Cx,  uS6Cy,  uS6W,  uS6H,  uS6R,  uS6Type),  sizedBlend(uS5W, uS5H, uS6W,  uS6H));
    if (n > 7.0)  d = smoothUnion(d, shapeSDF(p, uS7Cx,  uS7Cy,  uS7W,  uS7H,  uS7R,  uS7Type),  sizedBlend(uS6W, uS6H, uS7W,  uS7H));
    if (n > 8.0)  d = smoothUnion(d, shapeSDF(p, uS8Cx,  uS8Cy,  uS8W,  uS8H,  uS8R,  uS8Type),  sizedBlend(uS7W, uS7H, uS8W,  uS8H));
    if (n > 9.0)  d = smoothUnion(d, shapeSDF(p, uS9Cx,  uS9Cy,  uS9W,  uS9H,  uS9R,  uS9Type),  sizedBlend(uS8W, uS8H, uS9W,  uS9H));
    if (n > 10.0) d = smoothUnion(d, shapeSDF(p, uS10Cx, uS10Cy, uS10W, uS10H, uS10R, uS10Type), sizedBlend(uS9W,  uS9H,  uS10W, uS10H));
    if (n > 11.0) d = smoothUnion(d, shapeSDF(p, uS11Cx, uS11Cy, uS11W, uS11H, uS11R, uS11Type), sizedBlend(uS10W, uS10H, uS11W, uS11H));
    if (n > 12.0) d = smoothUnion(d, shapeSDF(p, uS12Cx, uS12Cy, uS12W, uS12H, uS12R, uS12Type), sizedBlend(uS11W, uS11H, uS12W, uS12H));
    if (n > 13.0) d = smoothUnion(d, shapeSDF(p, uS13Cx, uS13Cy, uS13W, uS13H, uS13R, uS13Type), sizedBlend(uS12W, uS12H, uS13W, uS13H));
    if (n > 14.0) d = smoothUnion(d, shapeSDF(p, uS14Cx, uS14Cy, uS14W, uS14H, uS14R, uS14Type), sizedBlend(uS13W, uS13H, uS14W, uS14H));
    return d;
}

out vec4 fragColor;

void main() {
    vec2  p = FlutterFragCoord().xy;
    float n = uNumShapes;

    float dReal = sceneSDF(p, n);

    // Pointer influence — radial bell bump scaled by R and the inside/outside
    // sign of the pointer position, so that:
    //   inside  + R>0 → expand (inflate)      outside + R>0 → repel boundary
    //   inside  + R<0 → contract (deflate)    outside + R<0 → attract (overshoot)
    //
    // Formula: dFinal = dReal + R * sign(dAtPointer) * bell
    float dFinal = dReal;
    if (uPointerActive > 0.5 && uPointerR != 0.0) {
        float dAtPointer = sceneSDF(vec2(uPointerCx, uPointerCy), n);
        // Smooth transition from -1 (inside) to +1 (outside) over a 40px band
        // centred on the shape boundary, avoiding the hard snap of sign().
        float insideSign = mix(-1.0, 1.0, smoothstep(-20.0, 20.0, dAtPointer));

        float dist      = length(p - vec2(uPointerCx, uPointerCy));
        float bell      = 1.0 - smoothstep(0.0, 120.0, dist);

        dFinal = dReal + uPointerR * insideSign * bell;
    }

    // 1px anti-alias band — crisp edge with minimal fringing.
    float a = 1.0 - smoothstep(-0.5, 0.5, dFinal);
    // Output as premultiplied alpha mask — RGB=alpha so dstIn works correctly.
    fragColor = vec4(a, a, a, a);
}
