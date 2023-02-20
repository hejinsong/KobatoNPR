Shader "Custom/DepthShadowShader"
{
    //Just Implement ,but not used, use urp lit Generate depth
    SubShader
    {
        Tags { "RenderType"="Opaque"  "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        ENDHLSL

        Pass
        {
            Name "DepthOnly"
            Tags{ "LightMode"="DepthOnly"}
            Cull Off
            ColorMask 0
            ZWrite On

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 3.0

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #include "NPRParameters.hlsl"
            #include "ShaderInclude/NPRDepthShadowPass.hlsl"

            ENDHLSL
        }
    }

}
