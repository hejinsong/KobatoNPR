#ifndef UNITY_NPR_SHADING_INPUT_HLSL
#define UNITY_NPR_SHADING_INPUT_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)

half4 _BaseMap_ST;
float _ShadowSmooth;
float _ShadowRange;
float4 _DarkColor;
float4 _HighColor;

float4 _OutLineColor;
float _OutLineWidth;

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


#endif