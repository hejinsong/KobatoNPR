Shader "Custom/NPREyeShader"
{
    Properties
    {
        _BaseMap ("Albedo (RGB)", 2D) = "white" {}
        _ShadowSmooth ("ShadowSmoothness", Range(0,1)) = 0.5
        _ShadowRange ("ShadowRange", Range(0,1)) = 0.5
        _DarkColor ("Drak Color", Color) = (0.3,0.3,0.3,1)
        _HighColor ("High Color", Color) = (1,1,1,1)
        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        _RimSmoothness ("RimSmoothness", Range(0, 10)) = 10
        _RimStrength ("RimStrength", Range(0, 1)) = 0.1
        _OutLineColor("OutLine Color", Color) = (0.5, 0.5, 0.5, 0)
        _OutLineWidth("OutLine Width", Range(0,10)) = 0.5
        //Settings
        [Header(RenderMode)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull Mode", Float) = 2.0
    }
    SubShader
    {
        Tags{"RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 300
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Cull[_Cull]
            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SURFACE_TYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON _ALPHAMODULATE_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS
            #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex NPRForwardLitVertex
            #pragma fragment NPRForwardLitFragment

            #include "NPRShadingInput.hlsl"
            #include "NPRForwardLitPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            //Trigger by Render Objects
            Name "OutLine"
            Tags { "LightMode" = "OutLine"}
            Cull Front
            ZTest LEqual
            Offset 0,0
            HLSLPROGRAM
            #pragma multi_compile _ _OUTLINE
            #pragma vertex NormalOutLineVertex
            #pragma fragment NormalOutLineFragment

            #include "NPRShadingInput.hlsl" 
            #include "OutLinePass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
