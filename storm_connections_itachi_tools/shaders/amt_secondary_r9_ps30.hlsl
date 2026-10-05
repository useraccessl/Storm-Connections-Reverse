// Port of c4ee9b55... original ps_4_0 target 0. Target 1 is a deferred
// postprocessing attachment; it needs a separate Source postprocess pass.
sampler TexBase : register(s0);
float4 Tint : register(c1);
float4 Common : register(c2); // unused, threshold, alpha, unused
float4 Atlas : register(c3);
float4 SamplerPolicy : register(c4); // half texel.xy, original address mode.z
float4 Fog : register(c0); // original fog RGB; factor comes from vertex stage
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
};
float4 main(PS_INPUT i) : COLOR {
    float2 uv=i.uv*Atlas.zw+Atlas.xy;
    float2 sampleUV=uv;
    float weight=1;
    if(SamplerPolicy.z>2.5) {
        sampleUV=clamp(uv,SamplerPolicy.xy,1-SamplerPolicy.xy);
        if(SamplerPolicy.z>3.5) {
            // ClampBorder with transparent black; preserve linear edge taps.
            float2 taps=saturate(uv/(2*SamplerPolicy.xy)+.5)*saturate((1-uv)/(2*SamplerPolicy.xy)+.5);
            weight=taps.x*taps.y;
        }
    }
    float4 texel=tex2D(TexBase,sampleUV)*weight;
    float alpha=texel.a*i.color.a;
    if(Common.y>=alpha) discard;
    float3 rgb=texel.rgb*i.color.rgb*Tint.rgb;
    return float4(Fog.rgb+i.zeros.x*(rgb-Fog.rgb),alpha*Common.z);
}
