Shader "Custom/HologramShader_URP"
{
    Properties
    {
        [HDR]_Color ("Base Color", Color) = (1,1,1,1)
        [HDR]_FresnelColor ("Fresnel (Rim) Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Scale("Scanline Scale", Float) = 10
        _Speed("Scanline Speed", Float) = 1
        _Slider("Fresnel Power", Range(0.1, 10)) = 2
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Name "ForwardLit"
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off 

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _FresnelColor;
                float _Scale;
                float _Speed;
                float _Slider;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                OUT.viewDirWS = GetWorldSpaceViewDir(positionInputs.positionWS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                // 1. Scanlines
                float lines = sin(IN.uv.y * _Scale + (_Time.y * _Speed));
                lines = saturate((lines * 0.5) + 0.5); 

                // 2. Fresnel (Solução definitiva para o Warning)
                float3 normal = normalize(IN.normalWS);
                float3 viewDir = normalize(IN.viewDirWS);
                
                // Usamos 1.00001 e saturate para garantir que a base nunca seja <= 0
                float fresnelDot = saturate(dot(normal, viewDir));
                float base = saturate(1.0 - fresnelDot);
                float fresnel = SafePositivePow(base, _Slider);

                // 3. Composição
                float3 finalRGB = (_Color.rgb * tex.rgb) + (fresnel * _FresnelColor.rgb);
                float alpha = lines * fresnel * _Color.a;

                return half4(finalRGB, alpha);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}