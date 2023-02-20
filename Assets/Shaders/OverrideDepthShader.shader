Shader "Custom/OverrideDepthShader"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL
        Pass
        {
            Name "HairDepth"
            Tags { "LightMode" = "HaidShadow"}
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            struct a2v
            {
                float4 positionOS: POSITION;
            };
            
            struct v2f
            {
                float4 positionCS: SV_POSITION;
            };
            v2f vert(a2v v)
            {
                v2f o;
                
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                return o;
            }
            float4 frag(v2f i): SV_Target
            {
                float depth = (i.positionCS.z / i.positionCS.w);
                return float4(0, depth, 0, 1);
            }
            ENDHLSL
        }

    }
}
