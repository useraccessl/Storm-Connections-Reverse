// Main captured Amaterasu shader, fog disabled as in verified original draws.
// Dynamic original atlas UVs/tint permit one shared mesh per original model.
sampler TexBase : register(s0);
sampler TexFilm : register(s1);
float4 Screen : register(c0);
float4 Tint : register(c1);
float4 Common : register(c2); // film amount, threshold, final alpha, unused
float4 Atlas : register(c3); // offset.xy, scale.xy
struct PS_INPUT {
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 unused : TEXCOORD2;
    float4 color : TEXCOORD3;
    float2 pixel : VPOS;
};
float4 main(PS_INPUT i) : COLOR {
    float4 primary=tex2D(TexBase,i.uv*Atlas.zw+Atlas.xy)*i.color;
    primary.rgb*=Tint.rgb;
    if(Common.y>=primary.a) discard;
    float2 filmUV=i.pixel*Screen.xy+Screen.zw;
    filmUV.y=1-filmUV.y;
    float4 film=tex2D(TexFilm,filmUV);
    float3 rgb=primary.rgb+(film.rgb-primary.rgb)*(film.a*Common.x);
    return float4(rgb,primary.a*Common.z);
}
