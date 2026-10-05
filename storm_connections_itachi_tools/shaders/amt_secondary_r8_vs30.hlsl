float4x4 ModelViewProjection : register(c4);
// Immutable mesh TEXCOORD1 stores reciprocal skill scale and fog amount.
// Clip W is camera depth after the Source model/view/projection transform.
// This is the same per-vertex fog as the previous CPU calculation, now on GPU.
struct VS_INPUT {
    float4 position : POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float2 fogParameters : TEXCOORD1;
};
struct VS_OUTPUT {
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float2 fog : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
};
VS_OUTPUT main(VS_INPUT i) {
    VS_OUTPUT o;
    o.position=mul(float4(i.position.xyz,1),ModelViewProjection);
    float clipW=o.position.w*i.fogParameters.x;
    o.fog=float2(1+i.fogParameters.y*(saturate((13000-clipW)/12800)-1),0);
    o.uv=i.uv; o.unused=0; o.color=i.color;
    return o;
}
