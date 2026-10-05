// Readable reconstruction of used_shaders/19f007_ps.asm.
// This is a DX11 reference, NOT an installed Source shader.
// Runtime-to-interpolator bindings and render state remain unresolved.
Texture2D g_texture0 : register(t0);
Texture2D g_texture2 : register(t1);
Texture2D g_texture3 : register(t2);
SamplerState g_sampler0 : register(s0);
SamplerState g_samplerScreen0 : register(s1);
SamplerState g_samplerScreen1 : register(s2);

struct PSInput {
    float4 position : SV_Position;
    float4 tint : TEXCOORD0;
    float2 uv : TEXCOORD1;
    float3 mixAmounts : TEXCOORD4;
    float4 alphaAndTarget : COLOR0;
    float4 finalColor : COLOR1;
    float4 screenTransform0 : TEXCOORD6;
    float4 screenTransform1 : TEXCOORD7;
};
struct PSOutput {
    float4 color : SV_Target0;
    float4 auxiliary : SV_Target1;
};

PSOutput main(PSInput input) {
    float4 base = g_texture0.Sample(g_sampler0, input.uv) * input.tint;
    // discard_nz(ge(threshold, alpha)): equality also discards.
    if (input.alphaAndTarget.x >= base.a) discard;
    float2 uv0 = input.screenTransform0.xy * input.position.xy
               + input.screenTransform0.zw;
    uv0.y = 1.0 - uv0.y;
    float4 screen0 = g_texture2.Sample(g_samplerScreen0, uv0);
    float3 color = base.rgb + (screen0.rgb - base.rgb)
                 * (screen0.a * input.mixAmounts.y);
    float2 uv1 = input.screenTransform1.xy * input.position.xy
               + input.screenTransform1.zw;
    uv1.y = 1.0 - uv1.y;
    float4 screen1 = g_texture3.Sample(g_samplerScreen1, uv1);
    color += (screen1.rgb - color) * (screen1.a * input.mixAmounts.z);
    PSOutput output;
    output.color.rgb = input.finalColor.rgb
                     + input.mixAmounts.x * (color - input.finalColor.rgb);
    output.color.a = base.a * input.alphaAndTarget.y;
    output.auxiliary = float4(input.alphaAndTarget.w,
                             input.alphaAndTarget.z, 0.99, output.color.a);
    return output;
}
