#ifndef NPR_DEPTH_SHADOW_METHOD
#define NPR_DEPTH_SHADOW_METHOD

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D_X_FLOAT(_CameraDepthShadowTexture);
SAMPLER(sampler_CameraDepthShadowTexture);

float LoadSceneDepthShadow(float2 uv)
{
    return SAMPLE_TEXTURE2D_X_LOD(_CameraDepthShadowTexture, sampler_CameraDepthShadowTexture, uv, 0).r;
}
#endif
