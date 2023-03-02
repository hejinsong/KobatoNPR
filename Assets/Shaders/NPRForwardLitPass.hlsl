#ifndef NPR_FORWARD_LIT_PASS_HLSL
#define NPR_FORWARD_LIT_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    #if _FaceShading
        float4 positionSS : TEXCOORD3;
    #endif
};

Varyings NPRForwardLitVertex(Attributes input)
{
    Varyings output = (Varyings) 0;
    
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    
    output.positionCS = vertexInput.positionCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.normalWS = normalInput.normalWS;
    output.positionWS = vertexInput.positionWS;
    #if _FaceShading
        output.positionSS = ComputeScreenPos(output.positionCS);
    #endif
    return output;
}

void NPRForwardLitFragment(Varyings input, out half4 outColor : SV_Target)
{
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);;
    half3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 normalWS = normalize(input.normalWS);
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light light = GetMainLight(shadowCoord);
    half halfLambert = dot(normalWS, light.direction) * 0.5 + 0.5;
    half ramp = smoothstep(0, _ShadowSmooth, pow(halfLambert - _ShadowRange, _ShadowSmooth));
    
    #if _FaceShading
        float2 screenPos = input.positionSS.xy / input.positionSS.w;
        float depth = input.positionCS.z / input.positionCS.w;
        float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);
        //Unity View Space ,Camera forward is the negative Z axis, So Add light view dir means substract
        float3 viewLightDir = normalize(TransformWorldToViewDir(light.direction)) * (1 / min(input.positionCS.w, 1)) * min(1, 5 / linearEyeDepth);
        float2 samplePoint = screenPos + _HairShadowDistance * viewLightDir.xy;
        float hairDepth = SAMPLE_TEXTURE2D(_HairDepthTexture, sampler_HairDepthTexture, samplePoint).g;
        hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);
        float hairShadow = linearEyeDepth > (hairDepth - 0.01) ? 0 : 1;
        ramp *= hairShadow;
    #else
        half shadowAttenuation = light.shadowAttenuation * light.distanceAttenuation;
        ramp *= shadowAttenuation;
    #endif
    
    half3 diffuse = lerp(_DarkColor, _HighColor, ramp).rgb;
    float rimStrength = pow(saturate(1 - dot(normalWS, viewDir)), _RimSmoothness);
    float3 rimColor = _RimColor.rgb * rimStrength * _RimStrength;
    
    outColor = float4(diffuse * baseColor.rgb + rimColor, 1.0f);
}

#endif