sampler TexBase : register(s0);
sampler TexFilm0 : register(s1);
sampler TexFilm1 : register(s2);
float4 Screen0 : register(c0);
float4 Screen1 : register(c1);
float4 TintAlpha : register(c2);
float4 Atlas : register(c3);
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 filmWeights : TEXCOORD1;
    float3 parameters : TEXCOORD2; // threshold, common.w, common.z
    float4 color : TEXCOORD3;
    float2 pixel : VPOS;
};
struct OUTPUT { float4 color:COLOR0; float4 parameters:COLOR1; };
OUTPUT main(PS_INPUT i) {
    OUTPUT o;
    float4 primary=tex2D(TexBase,i.uv*Atlas.zw+Atlas.xy)*i.color;
    primary.rgb*=TintAlpha.rgb;
    if(i.parameters.x>=primary.a) discard;
    float2 uv0=i.pixel*Screen0.xy+Screen0.zw;
    float2 uv1=i.pixel*Screen1.xy+Screen1.zw;
    uv0.y=1-uv0.y; uv1.y=1-uv1.y;
    float4 film0=tex2D(TexFilm0,uv0);
    float3 rgb=primary.rgb+(film0.rgb-primary.rgb)*(film0.a*i.filmWeights.x);
    float4 film1=tex2D(TexFilm1,uv1);
    rgb+=(film1.rgb-rgb)*(film1.a*i.filmWeights.y);
    float alpha=primary.a*TintAlpha.w;
    o.color=float4(rgb,alpha);
    o.parameters=float4(i.parameters.y,i.parameters.z,.99,alpha);
    return o;
}
