// Experimental Source 1 port of STORM CONNECTIONS material key 0x19f007.
// DX11 assembly reference: used_shaders/19f007_ps.asm.
// The Source wrapper supplies one model UV channel, so the two film samples
// currently use UVs instead of the game's pixel-position projections.
sampler TexBase : register(s0);
sampler TexFilm0 : register(s1);
sampler TexFilm1 : register(s2);

// c0: film UV scale (xy) and offset (zw)
// c1: second film UV scale (xy), first and second blend factors (zw)
float4 Film0 : register(c0);
float4 Film1 : register(c1);

struct PS_INPUT
{
    float2 uv : TEXCOORD0;
    float2 zeros : TEXCOORD1;
    float2 spare : TEXCOORD2;
    float4 color : TEXCOORD3;
};

float4 main(PS_INPUT i) : COLOR
{
    float4 baseSample = tex2D(TexBase, i.uv);
    float4 primary = baseSample * i.color;
    clip(primary.a - 0.005);

    float4 film0 = tex2D(TexFilm0, i.uv * Film0.xy + Film0.zw);
    float3 firstTarget = i.color.rgb + film0.rgb - baseSample.rgb;
    float3 color = lerp(primary.rgb, firstTarget, saturate(film0.a * Film1.z));

    float4 film1 = tex2D(TexFilm1, i.uv * Film1.xy + Film0.zw);
    color = lerp(color, film1.rgb, saturate(film1.a * Film1.w));

    return float4(saturate(color), primary.a);
}
