Shader "Custom/ShaderE_URP"
{
    Properties
    {
        _A("A", Range(-1,1)) = 0
        _B("B", Range(-1,1)) = 0
        _E("E", Range(0,20)) = 0
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
                float _E;
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
               
                float x = pow(sin(_A * IN.uv.x * 10 + _B), 2);
                float y = pow(sin(_A * IN.uv.y * 10 + _B), 2);
                
                float colorValue = (1 - (x + y) * _E);
                
                return half4(colorValue, colorValue, colorValue, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}