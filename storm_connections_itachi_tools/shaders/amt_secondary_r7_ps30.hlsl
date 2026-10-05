// Port of c4ee9b55... original ps_4_0 target 0. Target 1 is a deferred
// postprocessing attachment; it needs a separate Source postprocess pass.
sampler TexBase : register(s0);
float4 Tint : register(c1);
float4 Common : register(c2); // unused, threshold, alpha, unused
float4 Atlas : register(c3);
float4 Fog : register(c0); // original fog RGB; factor comes from vertex stage
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
};
float4 main(PS_INPUT i) : COLOR {
    float4 texel=tex2D(TexBase,i.uv*Atlas.zw+Atlas.xy);
    float alpha=texel.a*i.color.a;
    if(Common.y>=alpha) discard;
    float3 rgb=texel.rgb*i.color.rgb*Tint.rgb;
    return float4(Fog.rgb+i.zeros.x*(rgb-Fog.rgb),alpha*Common.z);
}
