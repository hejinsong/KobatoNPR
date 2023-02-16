#ifndef UNITY_NPR_PARAMETES_HLSL_INCLUDED
#define UNITY_NPR_PARAMETES_HLSL_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float _HairShadowDistance;
    float _CelShadingPoint;
    float _CelShadowSmoothness;
    float4 _DarkColor;
    float4 _BrightColor;
    float4 _RimColor;
    float _RimStrength;
    float _RimSmoothness;
CBUFFER_END

TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_HairSolidColor);     SAMPLER(sampler_HairSolidColor);
#endif