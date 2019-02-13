// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "my/Effect/RadialBlur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}


	CGINCLUDE

	#include "UnityCG.cginc"

	struct appdata_t {
		float4 vertex : POSITION;
		half2 texcoord : TEXCOORD0;
	};

	struct v2f {
		float4 vertex : SV_POSITION;
		half2 texcoord : TEXCOORD0;
		
	};

	sampler2D _MainTex;
	sampler2D _BlurTex;
	uniform float _fSampleDist;
	uniform float _fSampleStrength;
	uniform float2 _MainTex_TexelSize;
	v2f vert (appdata_t v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.texcoord = v.texcoord;
		
		return o;
	}
	
	fixed4 fragRadialBlur (v2f i) : COLOR
	{
		fixed2 dir = 0.5-i.texcoord;
		fixed dist = length(dir);
		dir /= dist;
		dir *= _fSampleDist;

		fixed4 sum = tex2D(_MainTex, i.texcoord - dir*0.01);
		sum += tex2D(_MainTex, i.texcoord - dir*0.02);
		sum += tex2D(_MainTex, i.texcoord - dir*0.03);
		sum += tex2D(_MainTex, i.texcoord - dir*0.05);
		sum += tex2D(_MainTex, i.texcoord - dir*0.08);
		sum += tex2D(_MainTex, i.texcoord + dir*0.01);
		sum += tex2D(_MainTex, i.texcoord + dir*0.02);
		sum += tex2D(_MainTex, i.texcoord + dir*0.03);
		sum += tex2D(_MainTex, i.texcoord + dir*0.05);
		sum += tex2D(_MainTex, i.texcoord + dir*0.08);
		sum *= 0.1;
		
		return sum;
	}

	fixed4 fragCombine (v2f i) : COLOR
	{
		
		fixed dist = length(float2(0.5, 0.5)-i.texcoord);

		float dist2=saturate(dist-0.2);
		
		float t=10;//_Time*10;

		
		i.texcoord.x+=sin(t*1.45)*0.05*dist2*(0.5-i.texcoord.x)*_fSampleStrength;
		i.texcoord.y+=sin(t*1.45)*0.05*dist2*(0.5-i.texcoord.y)*_fSampleStrength;
		float fx=i.texcoord.x;
		float fy=i.texcoord.y;
		
		#if SHADER_API_D3D9||SHADER_API_D3D11
		if (_MainTex_TexelSize.y< 0.0)
		fy = 1.0 - fy;
		#endif

		fixed4  col = tex2D(_MainTex,float2(i.texcoord.x,i.texcoord.y));
		fixed4  blur = tex2D(_BlurTex, float2(fx,fy));
		col=lerp(col, blur,saturate(_fSampleStrength*(dist)));
		return col;
	}
	ENDCG

	SubShader {
		ZTest Always  ZWrite Off Cull Off Blend Off

		Fog { Mode off } 
		//0  
		Pass { 
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment fragRadialBlur
			#pragma fragmentoption ARB_precision_hint_fastest 
			
			ENDCG	 
		}	
		//1	
		Pass { 
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment fragCombine
			#pragma fragmentoption ARB_precision_hint_fastest 
			
			ENDCG	 
		}				
		
	}	


}
