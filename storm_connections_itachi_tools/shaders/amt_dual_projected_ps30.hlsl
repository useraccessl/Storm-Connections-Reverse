// 1bf007 variant, NU_blendType=1, with the original two distinct UVs.
// c0/1 projected film transforms; c2 blendRate.x, film amount, threshold, alpha;
// c3 transforms already-transformed UV0 into UV1. No game fog or auxiliary MRT.
sampler Tex0 : register(s0);
sampler Tex1 : register(s1);
sampler Film0Tex : register(s2);
sampler Film1Tex : register(s3);
float4 Film0 : register(c0);
float4 Film1 : register(c1);
float4 Common : register(c2);
float4 UV1 : register(c3);
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
    float2 pixel : VPOS;
};
float4 main(PS_INPUT i) : COLOR {
    float4 first = tex2D(Tex0, i.uv);
    float4 second = tex2D(Tex1, i.uv * UV1.zw + UV1.xy);
    float4 base = lerp(second, first, saturate(Common.x)) * i.color;
    if (Common.z >= base.a) discard;
    float2 uv0 = i.pixel * Film0.xy + Film0.zw;
    float2 uv1 = i.pixel * Film1.xy + Film1.zw;
    uv0.y = 1 - uv0.y;
    uv1.y = 1 - uv1.y;
    float4 film0 = tex2D(Film0Tex, uv0);
    float4 film1 = tex2D(Film1Tex, uv1);
    float3 rgb = base.rgb + (film0.rgb - base.rgb) * film0.a * Common.y;
    rgb += (film1.rgb - rgb) * film1.a * Common.y;
    return float4(rgb, base.a * Common.w);
}
