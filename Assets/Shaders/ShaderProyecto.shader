Shader "Custom/ShaderProyecto"
{
    Properties
    {
        _Albedo("Albedo Color", Color) = (1,1,1,1)
        _FallOff("FallOff", Range(0.1, 0.5)) = 0.1

        //Phong
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _SpecularPower("Specular Power", Range(1.0, 10.0)) = 5.0
        _SpecularGloss("Specular Gloss", Range(1.0, 5.0)) = 1.0
        _GlossSteps("GlossSteps", Range(1,8)) = 4

        //RIM
        [HDR] _RimColor("Rim Color", Color) = (1,0,0,1)
        _RimPower("Rim Power", Range(0.0, 8.0)) = 1.0

        //Textura y mapa normal
        _MainTex("Main Texture", 2D) = "white" {}
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(-5, 5)) = 1

        //Banded
        _Steps("Banded Steps", Range(1,100)) = 20
        _RampTex("Ramp Texture", 2D) = "white" {}

    }

    SubShader
    {
        Tags
        {
            "Queue" = "Geometry"
            "RenderType" = "Opaque"
        }

        CGPROGRAM
            #pragma surface surf ShaderProyecto

            half4 _Albedo;
            half _FallOff;
            //Textura y normal map
            sampler2D _MainTex;
            sampler2D _NormalTex;
            float _NormalStrength;

            //Phong
            half4 _SpecularColor;
            half _SpecularPower;
            half _SpecularGloss;
            int _GlossSteps;

            //RIM
            half4 _RimColor;
            float _RimPower;

            //Banded
            fixed _Steps;
            sampler2D _RampTex;

            half4 LightingShaderProyecto (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
            {
                half NdotL = max(0, dot(s.Normal, lightDir)); //Lambert
                half diff= NdotL * _FallOff + _FallOff;

                //Phong
                half3 reflectedLight = reflect(-lightDir, s.Normal);
                half RdotV = max(0, dot(reflectedLight, viewDir));
                half3 specularity = pow (RdotV, _SpecularGloss / _GlossSteps) * _SpecularPower * _SpecularColor.rgb;
                
                //Banded
                half lightBandsMultiplier = _Steps / 256;
                half lightBandsAdditive = _Steps/2;
                fixed bandedLightModel = (floor((NdotL * 256 + lightBandsAdditive) / _Steps)) * lightBandsMultiplier;
                //Floor lo que hace es redondear al entero más cercano

                //Ramp Texture
                float x = NdotL * 0.5 + 0.5;
                float2 uv_RampTex = float2(x,0);
                half4 rampColor = tex2D(_RampTex, uv_RampTex);

                half4 c;
                c.rgb = (NdotL * s.Albedo + specularity ) * _LightColor0.rgb  * atten * diff * bandedLightModel * rampColor;
                c.a = s.Alpha;
                return c;
            }

            

            struct Input
            {
                float2 uv_MainTex;
                float3 viewDir;
                //NORMAL MAP
                float2 uv_NormalTex;

            };

            void surf (Input IN, inout SurfaceOutput o)
            {
                half4 texColor = tex2D(_MainTex, IN.uv_MainTex);
                

                //TEXTURA Y NORMAL MAP
                half4 normalColor = tex2D(_NormalTex, IN.uv_NormalTex);
                half3 normal = UnpackNormal(normalColor);
                normal.z = normal.z / _NormalStrength;
                o.Normal = normalize(normal);

                //RIM
                float3 nVwd = normalize(IN.viewDir);
                float3 NdotV = dot(nVwd, o.Normal);
                half rim= 1 - saturate(NdotV);
                o.Emission = _RimColor.rgb * pow(rim, _RimPower);
                //Emisión devuelve la intensidad del color sobre una superficie

                o.Albedo = texColor.rgb *  _Albedo.rgb;
               

            }
        ENDCG
    }
}
