// Source SM3 adaptation of original 19f007 pixel math.
// c0/c1: original screenTransform0/1, in pixel coordinates.
// c2: film0 amount, film1 amount, alpha threshold, alpha multiplier.
// c3: final fog RGB and final fog interpolation factor.
// Original auxiliary MRT output is not supplied by this Source wrapper.
sampler TexBase : register(s0);
sampler TexFilm0 : register(s1);
sampler TexFilm1 : register(s2);
float4 Film0 : register(c0);
float4 Film1 : register(c1);
float4 Common : register(c2);
float4 Fog : register(c3);
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
    float2 pixel : VPOS;
};
float4 main(PS_INPUT i) : COLOR {
    float4 primary = tex2D(TexBase, i.uv) * i.color;
    if (Common.z >= primary.a) discard;
    float2 uv0 = i.pixel * Film0.xy + Film0.zw;
    float2 uv1 = i.pixel * Film1.xy + Film1.zw;
    uv0.y = 1 - uv0.y;
    uv1.y = 1 - uv1.y;
    float4 film0 = tex2D(TexFilm0, uv0);
    float4 film1 = tex2D(TexFilm1, uv1);
    float3 color = primary.rgb + (film0.rgb - primary.rgb) * (film0.a * Common.x);
    color += (film1.rgb - color) * (film1.a * Common.y);
    color = Fog.rgb + Fog.w * (color - Fog.rgb);
    return float4(color, primary.a * Common.w);
}
