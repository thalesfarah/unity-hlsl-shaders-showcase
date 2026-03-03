Shader "Custom/DissolveShader_URP_TwoColors"
{
    Properties
    {
        [HDR]_Color ("Base Color", Color) = (1,1,1,1)
        [HDR]_PreDissolveColor("Pre-Dissolve Color", Color) = (1, 0.5, 0, 1)
        [HDR]_EdgeColor("Edge Glow", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _AlphaText("Alpha Text (Noise)", 2D) = "white" {}
        _Speed ("Animation Speed", Range(0, 5)) = 1
        _PreDissolveWidth ("Pre-Dissolve Width", Range(0, 0.5)) = 0.1
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_AlphaText);
            SAMPLER(sampler_AlphaText);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _PreDissolveColor;
                float4 _EdgeColor;
                float _Speed;
                float _PreDissolveWidth;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                float noise = SAMPLE_TEXTURE2D(_AlphaText, sampler_AlphaText, IN.uv).r;
                float animateStep = (sin(_Time.y * _Speed) * 0.5) + 0.5;
                float dissolve = step(animateStep, noise);
                float transitionMask = step(animateStep - _PreDissolveWidth, noise) - dissolve;
                float edgeMask = step(animateStep - 0.02, noise) - dissolve;
                float3 baseColor = mainTex.rgb * _Color.rgb;
                float3 finalRGB = lerp(baseColor, _PreDissolveColor.rgb, transitionMask);
                finalRGB += (edgeMask * _EdgeColor.rgb);
                float finalAlpha = (dissolve + transitionMask) * _Color.a;

                return half4(finalRGB, finalAlpha);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}