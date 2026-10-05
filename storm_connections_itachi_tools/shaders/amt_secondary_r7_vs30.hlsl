float4x4 ModelViewProjection : register(c4);
// Fog is evaluated per original vertex by the resource renderer:
// 1 + amount*(saturate((far-originalClipW)/(far-near))-1).
// Preserve its interpolation through TEXCOORD1. All four user registers in
// screenspace_general are pixel constants, so vertex fog uses mesh input.
struct VS_INPUT {
    float4 position : POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float2 fog : TEXCOORD1;
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
    o.uv=i.uv; o.fog=i.fog; o.unused=0; o.color=i.color;
    return o;
}
