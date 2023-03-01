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
    half ramp = smoothstep(0, _ShadowSmooth, halfLambert - _ShadowRange);
    half3 diffuse = lerp(_DarkColor, _HighColor, ramp).rgb;
    outColor = float4(diffuse * baseColor.rgb, 1.0f);
}

#endif