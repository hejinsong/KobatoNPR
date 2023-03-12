#ifndef NPR_FORWARD_LIT_PASS_HLSL
#define NPR_FORWARD_LIT_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
    float4 tangentOS: TANGENT;
    float2 uv : TEXCOORD0;
    float2 staticLightmapUV : TEXCOORD1;
    float2 dynamicLightmapUV : TEXCOORD2;
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

    DECLARE_LIGHTMAP_OR_SH(staticLightmapUV, vertexSH, 4);
    #ifdef DYNAMICLIGHTMAP_ON
        float2 dynamicLightmapUV : TEXCOORD5;
    #endif
};

float NPRDirectSpecular(BRDFData brdfData, NPRSurfaceData surfData, half3 viewDir, half3 lightDir, half3 normalWS)
{
    half specularTerm = 0.0;
    half3 halfVec = normalize(viewDir + lightDir);
    #if _SPECULARMODE_BLINNPHONG
        half nDotH = max(0, dot(halfVec, normalWS));
        specularTerm = smoothstep(0.7 - surfData.smoothness / 2, 0.7 + surfData.smoothness / 2, pow(max(0, nDotH), surfData.glossiness * 128.0));
    #elif _SPECULARMODE_GGX
        half nDotH = max(0, dot(halfVec, normalWS));
        half lDotH = max(0, dot(halfVec, lightDir));
        float d = nDotH * nDotH * (brdfData.roughness2 - 1) + 1.00001f;
        specularTerm = (brdfData.roughness2) / ((d * d) * max(0.1h, lDotH * lDotH) * (brdfData.roughness * 4.0 + 2));
    #endif

    return specularTerm;
}

half3 NPRDirectDiffuse(half3 lightDir, half3 normalWS)
{
    half halfLambert = dot(normalWS, lightDir) * 0.5 + 0.5;
    half3 diffuse = (half3)0;
    #if _DIFFUSEMODE_LAMBERT
        half ramp = smoothstep(0, _ShadowSmooth, (halfLambert - _ShadowRange));
        diffuse = lerp(_DarkColor, _HighColor, ramp).rgb;
    #elif _DIFFUSEMODE_RAMP
        diffuse = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(halfLambert, 0.5)).rgb ;
    #endif

    return diffuse;
}

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
    NPRSurfaceData surdata = (NPRSurfaceData)0;
    InitializeNPRInputSurfaceData(input.uv, surdata);
    BRDFData brdfData = (BRDFData)0;
    InitializeNPRBrdfData(surdata, brdfData);
    
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    half3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
    half3 normalWS = normalize(input.normalWS);
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light light = GetMainLight(shadowCoord);
    // half halfLambert = dot(normalWS, light.direction) * 0.5 + 0.5;
    // half ramp = smoothstep(0, _ShadowSmooth, (halfLambert - _ShadowRange));
    half shadowAttenuation = 0.0;
    #if _FaceShading
        float2 screenPos = input.positionSS.xy / input.positionSS.w;
        float depth = input.positionCS.z / input.positionCS.w;
        float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);
        //Unity View Space ,Camera forward is the negative Z axis, So Add light view dir means substract
        float3 viewLightDir = normalize(TransformWorldToViewDir(light.direction)) * (1 / min(input.positionCS.w, 1)) * min(1, 5 / linearEyeDepth);
        float2 samplePoint = screenPos + _HairShadowDistance * viewLightDir.xy;
        float hairDepth = SAMPLE_TEXTURE2D(_HairDepthTexture, sampler_HairDepthTexture, samplePoint).g;
        hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);
        shadowAttenuation = linearEyeDepth > (hairDepth - 0.01) ? _HairShadowStrength : 1; 
        //ramp *= hairShadow;
    #else
        shadowAttenuation = light.shadowAttenuation * light.distanceAttenuation;
        //ramp *= shadowAttenuation;
    #endif
    
    half3 diffuse = NPRDirectDiffuse(light.direction, normalWS) * surdata.albedo * shadowAttenuation;
    half3 specColor = _SpecularColor.rgb * NPRDirectSpecular(brdfData, surdata, viewDir, light.direction, normalWS);
    
    float rimStrength = pow(saturate(1 - dot(normalWS, viewDir)), _RimSmoothness);
    half3 rimColor = _RimColor.rgb * rimStrength * _RimStrength;
    outColor = float4(diffuse + specColor + rimColor, 1.0f);
}

#endif