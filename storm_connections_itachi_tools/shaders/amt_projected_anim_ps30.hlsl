// 19f007-style dynamic particle shader, retaining the original animated atlas UV.
// c0/c1: two projected screen-film transforms; c2: both weights, alpha cutoff,
// final alpha; c3: animated atlas offset.xy and scale.xy.
sampler TexBase : register(s0);
sampler TexFilm0 : register(s1);
sampler TexFilm1 : register(s2);
float4 Film0 : register(c0);
float4 Film1 : register(c1);
float4 Common : register(c2);
float4 Atlas : register(c3);
float4 Tint : register(c5);
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
    float2 pixel : VPOS;
};
float4 main(PS_INPUT i) : COLOR {
    float4 base = tex2D(TexBase, i.uv * Atlas.zw + Atlas.xy) * i.color * Tint;
    if (Common.z >= base.a) discard;
    float2 uv0 = i.pixel * Film0.xy + Film0.zw;
    float2 uv1 = i.pixel * Film1.xy + Film1.zw;
    uv0.y = 1 - uv0.y;
    uv1.y = 1 - uv1.y;
    float4 film0 = tex2D(TexFilm0, uv0);
    float4 film1 = tex2D(TexFilm1, uv1);
    float3 rgb = base.rgb + (film0.rgb - base.rgb) * (film0.a * Common.x);
    rgb += (film1.rgb - rgb) * (film1.a * Common.y);
    return float4(rgb, base.a * Common.w);
}
