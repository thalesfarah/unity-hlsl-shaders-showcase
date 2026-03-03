Shader "Custom/ShaderC_URP"
{
    Properties
    {
        _A("A", Range(-1,1)) = 0
        _B("B", Range(-1,1)) = 0
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            
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
                float4 _MainTex_ST;
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
                float3 color1 = _A * (IN.uv.x - IN.uv.y) + _B;
                float3 color2 = _A * (IN.uv.x + IN.uv.y) + _B;
                float3 magenta = color1 * float3(1, 0, 1);
                float3 ciano = color2 * float3(0, 1, 1);
                float3 finalRGB = ciano + magenta;
                return half4(finalRGB, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}