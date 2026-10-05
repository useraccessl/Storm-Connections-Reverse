float4x4 ModelViewProjection : register(c4);
struct VS_INPUT {
    float4 position:POSITION; float4 color:COLOR0; float2 uv:TEXCOORD0;
    float2 filmWeights:TEXCOORD1; float3 parameters:TEXCOORD2;
};
struct VS_OUTPUT {
    float4 position:POSITION; float2 uv:TEXCOORD0;
    float2 filmWeights:TEXCOORD1; float3 parameters:TEXCOORD2;
    float4 color:TEXCOORD3;
};
VS_OUTPUT main(VS_INPUT i) {
    VS_OUTPUT o;
    o.position=mul(float4(i.position.xyz,1),ModelViewProjection);
    o.uv=i.uv; o.filmWeights=i.filmWeights; o.parameters=i.parameters; o.color=i.color;
    return o;
}
