// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "my/role/character" {
	Properties {  
		_NotVisibleColor("NotVisibleColor", color) = (0.54,0.58,0.97,0.43)

		_MainTex("Base (RGB)", 2D) = "white" {}  
		_NormalMap("NormalMap",2D) = "white" {}

		_LightAdd("LightAdd",Range(0,3))=0.5
		
		_RimColor("RimColor", Color) =(0.2,0.2,0.2,0.0)  
		_RimWidth("RimWidth", Range(0.1,255)) = 4
		
		_SpecularColor("SpecularColor", Color) =(0.6,0.6,0.6,1.0)  
		_SpecularPow("SpecularPow",Range(0.1,255))=8
		_SpecularStrength("SpecularStrength",Range(0.1,10))=1


		[HideInInSpector]
		_Amount("Amount",Range(0,100))=0
	}  

	SubShader {  
		Tags{ "Queue"="Geometry+20" "RenderType" = "Opaque"}  
		Lighting Off		

		LOD 750  
		
		ZTest LEqual
		CGPROGRAM  

		#pragma surface surf NoLighting  

		struct Input {  
			float2 uv_MainTex;  
			float3 viewDir;  
		};  

		sampler2D _MainTex; 
		sampler2D _NormalMap; 
		fixed4 _RimColor;  
		fixed _RimWidth; 
		float _LightAdd; 
		float _Amount;

		fixed4 _SpecularColor;
		float _SpecularPow;
		float _SpecularStrength;

		fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
		{
			fixed4 c;
			c.rgb = 0; 
			c.a = s.Alpha;
			return c;
		}

		void surf (Input IN, inout SurfaceOutput o) {  
			
			fixed4 main = tex2D (_MainTex, IN.uv_MainTex);  
			fixed4 packedNormal=tex2D(_NormalMap,IN.uv_MainTex);

			o.Albedo =0;  
			o.Alpha = main.a;  
		
			half rim = 1-saturate(dot (normalize(IN.viewDir), o.Normal));  
			fixed3 color= main.rgb*(1+_LightAdd)+ _RimColor.rgb * pow (rim, _RimWidth);

			half spec=saturate(dot (normalize(IN.viewDir), o.Normal));  

			color+=_SpecularColor.rgb*_SpecularStrength*pow(spec,_SpecularPow)*main.a;


			o.Emission=color*(1+_Amount);
		}  

		ENDCG  
	}  

	SubShader {
	Tags {"Queue"="Geometry+20" "RenderType"="Opaque" }
	LOD 100
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				UNITY_APPLY_FOG(i.fogCoord, col);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
		ENDCG
	}
}

	Fallback "Diffuse"  
}
