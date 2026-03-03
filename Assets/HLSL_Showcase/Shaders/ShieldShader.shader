Shader "Custom/ShieldHexAnimated_URP"
{
    Properties
    {
        [HDR] _GlowColor ("Hexagon Color (HDR)", Color) = (0, 0.5, 1, 1)
        _AlphaText ("Hexagon Texture (B&W)", 2D) = "white" {}
        
        _HexScale ("Hex Scale", Float) = 5
        _MoveSpeed ("Horizontal Move Speed", Float) = 0.5
        _PulseSpeed ("Visibility Pulse Speed", Range(0, 10)) = 2
        
        [HDR] _EdgeColor ("Intersection Glow", Color) = (1, 1, 1, 1)
        _FadeLength ("Intersection Fade", Range(0.01, 5)) = 0.5
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
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            TEXTURE2D(_AlphaText);
            SAMPLER(sampler_AlphaText);

            CBUFFER_START(UnityPerMaterial)
                float4 _GlowColor;
                float4 _EdgeColor;
                float _HexScale;
                float _MoveSpeed;
                float _PulseSpeed;
                float _FadeLength;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                OUT.screenPos = ComputeScreenPos(OUT.positionCS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // 1. Movimento Horizontal da Textura
                // Somamos o tempo ao eixo X do UV antes de multiplicar pelo Scale
                float2 movingUV = IN.uv;
                movingUV.x += _Time.y * _MoveSpeed;
                
                // 2. Amostragem da Textura
                float4 hexTex = SAMPLE_TEXTURE2D(_AlphaText, sampler_AlphaText, movingUV * _HexScale);
                
                // 3. Função de Seno para Transparência Total (Pulso)
                // O seno oscila entre -1 e 1. Ajustamos para 0 e 1.
                float visibilityPulse = saturate(sin(_Time.y * _PulseSpeed) * 0.5 + 0.5);
                
                // 4. Cálculo de Intersecção
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float rawDepth = SampleSceneDepth(screenUV);
                float sceneZ = LinearEyeDepth(rawDepth, _ZBufferParams);
                float partZ = IN.screenPos.w;
                float intersect = saturate(1.0 - (abs(sceneZ - partZ) / _FadeLength));
                float3 intersectionGlow = _EdgeColor.rgb * SafePositivePow(intersect, 3);

                // 5. Composição de Cor
                // Aplicamos o visibilityPulse na cor para ela também "apagar" no Bloom
                float3 finalRGB = (hexTex.rgb * _GlowColor.rgb * visibilityPulse) + (intersectionGlow * visibilityPulse);
                
                // 6. Alpha Final
                // Multiplicamos o valor da textura pelo pulso de visibilidade
                // O preto da textura já garante transparência, o pulso faz o branco sumir também
                float finalAlpha = saturate(hexTex.r + intersect) * _GlowColor.a * visibilityPulse;

                return half4(finalRGB, finalAlpha);
            }
            ENDHLSL
        }
    }
    FallBack "Transparent/Diffuse"
}