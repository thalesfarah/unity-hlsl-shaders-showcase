Shader "URP/HalftoneSpiderVerseShader"
{
    Properties
    {
        [HDR]_DotTint ("Dot Tint", Color) = (1,1,1,1)
        [HDR]_Tint ("Base Tint", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Scale("Halftone Scale", Float) = 20
        _VoronoiAngle("Voronoi Angle", Float) = 2
        _CellDensity("Cell Density", Float) = 5
        _DotSize("Dot Size Threshold", Range(0,1)) = 0.5
        _HalftonePower("Halftone Lighting Power", Float) = 1
    }

    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

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
                float4 screenPos : TEXCOORD1;
                float3 normalWS : TEXCOORD3;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _DotTint;
                float4 _Tint;
                float4 _MainTex_ST;
                float _Scale;
                float _VoronoiAngle;
                float _CellDensity;
                float _DotSize;
                float _HalftonePower;
            CBUFFER_END

            inline float2 unity_voronoi_noise_randomVector (float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5);
            }

            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float res = 8.0;

                for(int y=-1; y<=1; y++)
                {
                    for(int x=-1; x<=1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if(d < res)
                        {
                            res = d;
                        }
                    }
                }
                Out = res;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.screenPos = ComputeScreenPos(OUT.positionCS);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                screenUV.x *= aspect;
            
                float voronoiResult;
                Unity_Voronoi_float(screenUV * _Scale, _VoronoiAngle, _CellDensity, voronoiResult);
                
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float3 normal = normalize(IN.normalWS);
                
                float diff = saturate(dot(normal, lightDir));
                float lightIntensity = pow(diff, _HalftonePower);
                
                float dots = step(_DotSize, 1.0 - voronoiResult) * lightIntensity;
                
                float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _Tint;
                float3 finalColor = texColor.rgb + (dots * _DotTint.rgb);
                
                return half4(finalColor, texColor.a);
            }
            ENDHLSL
        }
    }
    FallBack "Universal Render Pipeline/Lit"
}