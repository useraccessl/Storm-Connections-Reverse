// Source c4 is the model-view-projection matrix (common_vs_fxc.h).
float4x4 ModelViewProjection : register(c4);
struct VS_INPUT { float4 position : POSITION; float4 color : COLOR0; float2 uv : TEXCOORD0; };
struct VS_OUTPUT {
    float4 position : POSITION;
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
};
VS_OUTPUT main(VS_INPUT i) {
    VS_OUTPUT o;
    // Source's screenspaceeffect_vs20.fxc uses a row vector on the left.
    o.position = mul(float4(i.position.xyz,1), ModelViewProjection);
    o.uv = i.uv;
    o.zeros = 0;
    o.unused = 0;
    o.color = i.color;
    return o;
}
