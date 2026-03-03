Shader "Custom/ShaderI_URP"
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
                // Lógica de coordenadas baseada em seno
                float x = sin(_A * IN.uv.x * 25 + _B);
                float y = sin(_A * IN.uv.y * 25 + _B);
                
                // Criação da máscara binária (grid)
                float cor = ceil(x * y);
                
                // Cores animadas pelo tempo (_Time.z e _Time.w)
                float3 vermelho = cor * float3(1, 0, 0) * sin(_Time.z);
                float3 azul = (1.0 - cor) * float3(0, 0, 1) * sin(_Time.w);
                
                float3 finalRGB = vermelho + azul;
                
                return half4(finalRGB, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}