Shader "Custom/ShaderJ_URP"
{
    Properties
    {
        _A("A", Range(-1,1)) = 0
        _B("B", Range(-1,1)) = 0
        _E("E", Range(0,50)) = 0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
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
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float _A;
                float _B;
                float _E;
            CBUFFER_END

            sampler2D _MainTex;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float x = pow(_A * IN.uv.x + _B, 2);
                float y = pow(_A * IN.uv.y + _B, 2);
                float funcao = (x + y) * _E;
                float3 azul = (1.0 - funcao) * float3(0, 0, 1);
                float3 finalRGB = round(funcao + azul);
                return half4(finalRGB, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}