Shader "Custom/DepthShadowShader"
{

    SubShader
    {
        Tags { "RenderType"="Opaque"  "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL

        Pass
        {
            Name "FaceDepthOnly"
            Tags { "LightMode"="UniversalForward"}

            ColorMask 0
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
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            half4 frag(v2f i): SV_Target
            {
                return(0,0,0,1);
            }
            ENDHLSL
        }

        Pass
        {
            Name "HairColorBuffer"
            Tags{ "LightMode"="UniversalForward"}
            Cull Off
            ZTest LEqual
            ZWrite Off

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

            half4 frag(v2f i): SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDHLSL
        }
    }

}
