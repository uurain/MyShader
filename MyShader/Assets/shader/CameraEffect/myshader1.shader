Shader "my/Effect/myshaderBlue"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}		
		_BlurRadius("BlurRadius", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float2 uv4 : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//XX_TexelSize，XX纹理的像素相关大小width，height对应纹理的分辨率，x = 1/width, y = 1/height, z = width, w = height
			float4 _MainTex_TexelSize;
			float _BlurRadius;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.uv1 = o.uv + _BlurRadius * _MainTex_TexelSize * float2(1, 1);
				o.uv2 = o.uv + _BlurRadius * _MainTex_TexelSize * float2(-1, 1);
				o.uv3 = o.uv + _BlurRadius * _MainTex_TexelSize * float2(1, -1);
				o.uv4 = o.uv + _BlurRadius * _MainTex_TexelSize * float2(-1, -1);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);

				col += tex2D(_MainTex, i.uv1);
				col += tex2D(_MainTex, i.uv2);
				col += tex2D(_MainTex, i.uv3);
				col += tex2D(_MainTex, i.uv4);

				return col * 0.2;
			}
			ENDCG
		}
	}
}
