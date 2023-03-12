#ifndef UNITY_NPR_SHADING_INPUT_HLSL
#define UNITY_NPR_SHADING_INPUT_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/BRDF.hlsl"

CBUFFER_START(UnityPerMaterial)

half4 _BaseMap_ST;
half4 _RampMap_ST;
float _ShadowSmooth;
float _ShadowRange;
float4 _DarkColor;
float4 _HighColor;
float4 _RimColor;
float _RimStrength;
float _RimSmoothness;
half _HairShadowStrength;

float _Glossiness;
float4 _SpecularColor;
float4 _OutLineColor;
float _OutLineWidth;
#if _FaceShading
    float _HairShadowDistance;
#endif
float4 _DetailAlbedoMap_ST;
half4 _BaseColor;
half4 _SpecColor;
half4 _EmissionColor;
half _Cutoff;
half _Smoothness;
half _Metallic;
half _BumpScale;
half _Parallax;
half _OcclusionStrength;
half _ClearCoatMask;
half _ClearCoatSmoothness;
half _DetailAlbedoMapScale;
half _DetailNormalMapScale;
half _Surface;

CBUFFER_END

#if _FaceShading
    TEXTURE2D(_HairDepthTexture);   SAMPLER(sampler_HairDepthTexture);
#endif
    TEXTURE2D(_RampMap);    SAMPLER(sampler_RampMap);

struct NPRSurfaceData
{
    half3 albedo;
    half3 specular;
    half3 normalTS;
    half3 emission;
    half  metallic;
    half  smoothness;
    half  glossiness;
    half  alpha;
};
inline void InitializeNPRInputSurfaceData(float2 uv, out NPRSurfaceData surfData)
{
    surfData = (NPRSurfaceData)0;
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    surfData.alpha = Alpha(albedoAlpha.a, _BaseColor, _Cutoff);
    surfData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
    surfData.smoothness = _Smoothness;
    surfData.metallic = _Metallic;
    surfData.glossiness = _Glossiness;
    surfData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
}

inline void InitializeNPRBrdfData(NPRSurfaceData surfData ,out BRDFData BrdfData)
{
    InitializeBRDFData(surfData.albedo, surfData.metallic, surfData.specular, surfData.smoothness ,surfData.alpha, BrdfData);
}

#endif