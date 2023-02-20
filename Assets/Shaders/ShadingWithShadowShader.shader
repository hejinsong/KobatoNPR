Shader "Custom/ShadingWithShadowShader"
{
    Properties
    {   
        [MainTexture]_BaseMap ("Base Map", 2D) = "White" { }

        _HairShadowDistance("Hair Shadow Distance", Range(0, 1)) = 0.01

        [Toggle(_IsFace)] _IsFace ("IsFace", Float) = 0.0

        _DarkColor ("DarkColor", Color) = (0.5, 0.5, 0.5, 1)
        _BrightColor ("BrightColor", Color) = (1, 1, 1, 1)

        _CelShadingPoint("shade mid point", Range(0, 1)) = 0.5
        _CelShadowSmoothness("shadow smooth", Range(0, 1)) = 0.2

        _RimColor ("RimColor", Color) = (1, 1, 1, 1)
        _RimSmoothness ("RimSmoothness", Range(0, 10)) = 10
        _RimStrength ("RimStrength", Range(0, 1)) = 0.1

        _DepthBias("depth bias", Range(0, 1)) = 0.15
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        HLSLINCLUDE
        
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
        //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT

        ENDHLSL

        Pass
        {
            Name "BaseShading"
            Tags { "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _IsFace

            #include "NPRParameters.hlsl"
            struct a2v
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
                float3 colorVert : COLOR;
            };
            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normal : TEXCOORD2;
                #if _IsFace
                    float4 positionSS : TEXCOORD3;
                    float posNDCw : TEXCOORD4;
                #endif
                 float3 color: TEXCOORD5;
            };

            TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_HairDepthTexture);   SAMPLER(sampler_HairDepthTexture);

            v2f vert(a2v v)
            {
                v2f o;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = positionInputs.positionCS;
                o.positionWS = positionInputs.positionWS;
                #if _IsFace
                    o.positionSS = ComputeScreenPos(o.positionCS);
                    o.posNDCw = positionInputs.positionNDC.w;
                #endif
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(v.normal.xyz);
                o.normal = normalInputs.normalWS;
                o.color = v.colorVert;
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                float4 shadowCoord = TransformWorldToShadowCoord(i.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);

                half shadow = light.shadowAttenuation * light.distanceAttenuation;
                float3 normal = normalize(i.normal);
                float halfLambert = dot(normal, light.direction) * 0.5 + 0.5;
                half ramp = smoothstep(0, _CelShadingPoint, pow(saturate(halfLambert - _CelShadingPoint), _CelShadowSmoothness)); 

                #if _IsFace
                    float2 screenPos = i.positionSS.xy / i.positionSS.w;
                    float4 scaledScreenParams = GetScaledScreenParams();
                    float depth = i.positionCS.z / i.positionCS.w;
                    float linearEyeDepth = LinearEyeDepth(depth, _ZBufferParams);

                    //Unity View Space ,Camera forward is the negative Z axis, So Add light view dir means substract
                    float3 viewLightDir = normalize(TransformWorldToViewDir(light.direction)) * (1 / min(i.posNDCw, 1)) * min(1, 5 / linearEyeDepth);

                    float2 samplePoint = screenPos + _HairShadowDistance * viewLightDir.xy;

                    float hairDepth = SAMPLE_TEXTURE2D(_HairDepthTexture, sampler_HairDepthTexture, samplePoint).g;
                    hairDepth = LinearEyeDepth(hairDepth, _ZBufferParams);
                    
                    float hairShadow = linearEyeDepth > (hairDepth - _DepthBias) ? 0 : 1;
                    ramp *= hairShadow;
                #else
                    ramp *= shadow;
                #endif
                
                float3 diffuse = lerp(_DarkColor.rgb, _BrightColor.rgb, ramp);
                diffuse *= baseColor.rgb;
                float3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - i.positionWS);
                float rimStrength = pow(saturate(1 - dot(normal, viewDirectionWS)), _RimSmoothness);
                float3 rimColor = _RimColor.rgb * rimStrength * _RimStrength;
                return half4(diffuse + rimColor, 1.0);
            }



            ENDHLSL
        }
    }
}
