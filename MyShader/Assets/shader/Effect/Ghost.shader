// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "my/Effect/Ghost"{  
    Properties{  
        _MainTex("MainTex",2D) = ""{}  
        _Offset0("Offset0",Vector)=(0,0,0)
    }  
    CGINCLUDE  
    //将代码写在CGINCLUDE...ENDCG中  
        #include "UnityCG.cginc"  
          sampler2D _MainTex;

        float4 _Offset0;
        float4 _Offset1;
        float4 _Offset2;
        float4 _Offset3;
        float _Alpha0;
         float _Alpha1;
          float _Alpha2;
           float _Alpha3;
          
        struct v2f{  
            float4 pos : POSITION;  
            float2 uv   : TEXCOORD0;   
        };  
           v2f vert_normal(appdata_base v) { // 渲染自身的vert函数
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
         
         v2f vert_offset_1(appdata_base v) {
            v2f o;
            float4 pos = mul(unity_ObjectToWorld, v.vertex);
            o.pos = mul(UNITY_MATRIX_VP, pos + _Offset0);
            o.uv = v.texcoord;
            return o;
        }


        v2f vert_offset_2(appdata_base v) {
            v2f o;
            float4 pos = mul(unity_ObjectToWorld, v.vertex);
            o.pos = mul(UNITY_MATRIX_VP, pos + _Offset1);
            o.uv = v.texcoord;
            return o;
        }

        v2f vert_offset_3(appdata_base v) {
            v2f o;
            float4 pos = mul(unity_ObjectToWorld, v.vertex);
            o.pos = mul(UNITY_MATRIX_VP, pos + _Offset2);        
            o.uv = v.texcoord;
            return o;
        }

        v2f vert_offset_4(appdata_base v) {
            v2f o;
            float4 pos = mul(unity_ObjectToWorld, v.vertex);
            o.pos = mul(UNITY_MATRIX_VP, pos + _Offset3);        
            o.uv = v.texcoord;
            return o;
        }

        //   float4 frag_normal(v2f i) : COLOR {
        //     return tex2D(_MainTex, i.uv);
        // }


        float4 frag_color_1(v2f i) : COLOR { // 将残影的alpha值设为0.5
            float4 c;
            c = tex2D(_MainTex, i.uv);
            c.w = _Alpha0;
            return c;
        }
         float4 frag_color_2(v2f i) : COLOR { // 将残影的alpha值设为0.5
            float4 c;
            c = tex2D(_MainTex, i.uv);
            c.w = _Alpha1;
            return c;
        }
         float4 frag_color_3(v2f i) : COLOR { // 将残影的alpha值设为0.5
            float4 c;
            c = tex2D(_MainTex, i.uv);
            c.w = _Alpha2;
            return c;
        }
         float4 frag_color_4(v2f i) : COLOR { // 将残影的alpha值设为0.5
            float4 c;
            c = tex2D(_MainTex, i.uv);
            c.w = _Alpha3;
            return c;
        }
    
    ENDCG  
    SubShader{  
       Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
         Pass { // 从最远的开始渲染
            ZWrite Off 
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_offset_4
            #pragma fragment frag_color_4
            ENDCG
        }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_offset_3
            #pragma fragment frag_color_3
            ENDCG
        }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_offset_2
            #pragma fragment frag_color_2
            ENDCG
        }

        Pass {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert_offset_1
            #pragma fragment frag_color_1
            ENDCG
        }

        // Pass { // 渲染自身，这时要开启 ZWrite
        //   //  Blend SrcAlpha OneMinusSrcAlpha

        //     CGPROGRAM
        //     #pragma vertex vert_normal
        //     #pragma fragment frag_normal
        //     ENDCG
        // } 
        }  
    FallBack "Diffuse"
}