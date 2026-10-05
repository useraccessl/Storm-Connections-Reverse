// Reference translation of original 19f002 VS/PS, extracted from GPU capture.
// D3D11 reference only: Source adapter and original animation player pending.
cbuffer Original : register(b0) { float4 C[17]; }
Texture2D Base : register(t0);
Texture2D Film0 : register(t1);
Texture2D Film1 : register(t2);
SamplerState BaseSampler : register(s0);
SamplerState FilmSampler0 : register(s1);
SamplerState FilmSampler1 : register(s2);
struct Input { float4 position:POSITION; float4 color:COLOR0; float2 uv:TEXCOORD0; };
struct Varying { float4 position:SV_POSITION; float4 color:COLOR0; float2 uv:TEXCOORD0; float fog:TEXCOORD1; };
Varying VS(Input i) {
    Varying o;
    o.position=i.position.x*C[4]+i.position.y*C[5]+i.position.z*C[6]+i.position.w*C[7];
    o.color=float4(i.color.rgb*C[12].rgb*C[3].rgb,i.color.a);
    o.uv=i.uv*C[8].zw+C[8].xy;
    float f=saturate((C[2].y-o.position.w)/(C[2].y-C[2].x));
    o.fog=1+(f-1)*C[2].z;
    return o;
}
struct Targets { float4 color:SV_TARGET0; float4 parameters:SV_TARGET1; };
Targets PS(Varying i) {
    Targets o;
    float4 texel=Base.Sample(BaseSampler,i.uv);
    float4 primary=texel*i.color;
    if(C[0].x>=primary.a) discard;
    float2 pixel=float2(i.position.x*C[13].x,-i.position.y*C[13].y);
    float2 uv0=pixel*C[16].xy+C[15].xy*C[16].xy;
    float2 uv1=pixel*C[16].zw+C[15].zw*C[16].zw;
    uv0.y=1-uv0.y; uv1.y=1-uv1.y;
    float4 film0=Film0.Sample(FilmSampler0,uv0);
    float3 rgb=primary.rgb+(film0.rgb-primary.rgb)*(film0.a*C[14].x);
    float4 film1=Film1.Sample(FilmSampler1,uv1);
    rgb+=(film1.rgb-rgb)*(film1.a*C[14].y);
    float alpha=primary.a*C[0].y;
    o.color=float4(C[1].rgb+i.fog*(rgb-C[1].rgb),alpha);
    o.parameters=float4(C[0].w,C[0].z,.99,alpha);
    return o;
}
