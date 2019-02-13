Shader "my/Effect/Grayscale Effect" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_GrayRange("GrayRange",float)=0
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
				
CGPROGRAM
#pragma vertex vert_img
#pragma fragment frag
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
float _GrayRange;
fixed4 frag (v2f_img i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	col.rgb = lerp(col.rgb,dot(col.rgb, fixed3(.222,.707,.071)),_GrayRange);
	return col;
}
ENDCG

	}
}

Fallback off

}
