Shader "my/effect/WaterWave Effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float _distanceFactor;
			uniform float _timeFactor;
			uniform float _totalFactor;
			uniform float _waveWidth;
			uniform float _curWaveDis;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 dv = float2(0.5, 0.5) - i.uv;
				dv = dv * float2(_ScreenParams.x/_ScreenParams.x, 1);

				float dis = sqrt(dv.x * dv.x + dv.y * dv.y);
				float sinFactor = sin(dis * _distanceFactor + _Time.y * _timeFactor) * _totalFactor * 0.01;
				float discardFactor = clamp(_waveWidth - abs(_curWaveDis - dis), 0, 1);
				float2 dv1 = normalize(dv);
				float2 offset = dv1 * sinFactor * discardFactor;

				float2 uv = offset + i.uv;


				// sample the texture
				fixed4 col = tex2D(_MainTex, uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
