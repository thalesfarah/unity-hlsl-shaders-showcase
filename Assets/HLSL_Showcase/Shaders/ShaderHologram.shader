Shader "Custom/HologramShader_URP"
{
    Properties
    {
        [HDR]_Color ("Color", Color) = (1,1,1,1)
        [HDR]_FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _B ("B", Float) = 0
        _Scale ("Scale", Float) = 1
        _Speed ("Speed", Float) = 1
        _Slider ("Slider", Range(-5,5)) = 0
    }

    SubShader
    {
        // Define que o shader é transparente e não escreve no ZBuffer
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

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
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _FresnelColor;
                float _B;
                float _Scale;
                float _Speed;
                float _Slider;
            CBUFFER_END

            sampler2D _MainTex;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.viewDirWS = GetWorldSpaceViewDir(worldPos);
                OUT.screenPos = ComputeScreenPos(OUT.positionHCS);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Lógica original: Efeito de Scanline (retas passando pelo UV)
                float reta1 = _Scale * IN.uv.y + _B * (_Time.y * _Speed);
                
                // Cálculo de Fresnel (Brilho nas bordas)
                float3 normal = normalize(IN.normalWS);
                float3 viewDir = normalize(IN.viewDirWS);
                float fresnel = saturate(pow(1.0 - dot(normal, viewDir), _Slider));
                
                // Aplicação das cores e transparência
                float3 finalRGB = _Color.rgb * IN.screenPos.xyy; // Simula o efeito screenPos original
                float3 emissao = (1.0 - fresnel) * _FresnelColor.rgb;
                
                // Alpha baseado no seno da reta (Efeito de cintilação do holograma)
                float alpha = (1.0 - sin(reta1)) * IN.screenPos.y;
                
                return half4(finalRGB + emissao, alpha * _Color.a);
            }
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}