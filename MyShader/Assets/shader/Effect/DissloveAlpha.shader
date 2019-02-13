// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "my/Effect/Particles/DissloveAlpha"
{
	Properties
	{
		_TintColor ("Diffuse Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("DiffuseTexture", 2D) = "white" {}
		_N_mask ("N_mask", Float) = 0.3
		_MaskTex ("Mask Texture", 2D) = "white" {}
		_EdgeColor ("Edge Color", Color) = (0.5,0.5,0.5,0.5)
		_EdgeLength ("Edge Length", Range(0, 1)) = 0.1 
		_Illuminate ("Illuminate", Range (0, 1)) = 0.5
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

	 	Blend SrcAlpha OneMinusSrcAlpha
	 	ZWrite Off
	 	Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 vertexColor : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 maskuv : TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 vertexColor : COLOR;
			};

			sampler2D _MainTex;
			sampler2D _MaskTex;
			float4 _MainTex_ST;
			float4 _MaskTex_ST;
			float _N_mask;
			fixed4 _TintColor;
			fixed4 _EdgeColor;
			fixed _EdgeLength;
			fixed _Illuminate;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vertexColor = v.vertexColor;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.maskuv = TRANSFORM_TEX(v.uv, _MaskTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColor = tex2D(_MainTex, i.uv);
				fixed4 maskColor = tex2D(_MaskTex, i.maskuv);
				half value = _N_mask * i.vertexColor.a - maskColor.r;
				if(value <= 0)
				{
					discard;
				}
				else
				{
					if(value < _EdgeLength)
					{
						mainColor = mainColor * _EdgeColor * (value / _EdgeLength) / (1 - _Illuminate);
					}
				}
				//
				UNITY_APPLY_FOG(i.fogCoord, mainColor);
				return mainColor * _TintColor * i.vertexColor;
			}
			ENDCG
		}
	}
}
