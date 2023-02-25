#ifndef OUTLINE_PASS_HLSL
#define OUTLINE_PASS_HLSL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//TODO: Add Property into Cbuffer...
float4 _OutLineColor;
float _OutLineWidth;
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
};

Varyings NormalOutLineVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS);
    float3 normalCS = TransformWorldToHClipDir(normalInput.normalWS, true);
    float4 screenParams = GetScaledScreenParams();
    float ratio = screenParams.y / screenParams.x;
    normalCS.x *= ratio;
    output.positionCS = vertexInput.positionCS;
    float wClamp = clamp(vertexInput.positionCS.w, 0, 5);
    output.positionCS.xy += normalCS.xy * wClamp * 0.01 * _OutLineWidth;
    return output;
}

void NormalOutLineFragment(Varyings input, out half4 outColor : SV_Target)
{
    outColor = half4(_OutLineColor);
}

#endif