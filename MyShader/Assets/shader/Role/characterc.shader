// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "my/role/characterc" {
	Properties {  
		_NotVisibleColor("NotVisibleColor", color) = (0.54,0.58,0.97,0.43)
		_MainTex("Main Tex", 2D)                 = "white" {}
		_BumpTex("Bump Tex", 2D)                 = "bump" {}
		_ChanneTex("Channel Tex Glossiness(R) Metallic(G) Flow(B)", 2D) = "white" {}
		_ColorTex("Color Tex  Color1(G) Color2(B) Occlusion(R) ",2D)   ="black" {}
		_Cube ("Reflection Cubemap", Cube) = "" {}
		_Metallic("Metallic(Channel G) ",Range(0,1))=1
		_Glossiness ("Gloss(Channel R)", Range(0,1)) = 0.5
		_Occlusion ("Occlusion(Color R)", Range(0,1)) = 0
		[HideInInspector]	
		_LightDir("Light Dir", Vector)           = (1, 1, 1, 0.0)
		_Ambient("Ambient Color", Color)         = (1, 1, 1, 1.0)
		_Intensity("Intensity",Range(0,8)) =1
		_Dey1("Dey Color1",Color) = (1, 1, 1, 1.0)
		_Dey2("Dey Color2",Color) = (1, 1, 1, 1.0)
	//	_Dey3("Dey Color3",Color) = (1, 1, 1, 1.0)
	//	_Dey4("Dey Color4",Color) = (1, 1, 1, 1.0)
		
		_LightTex ("Light Texture", 2D) = "black" {}
		_LightColor("Light Color",Color) = (1,1,1,1)
		_LightPower("Light Power",Range(0,5)) = 1
		_LightScale("Light Scale" , Range(0.5,5)) = 1
		_LightAngle("Light Angle",Range(-180,180)) = 1
		//每次持续时间，受Angle和Scale影响
		_LightDuration("Light Duration",Range(0,10)) = 1
		//时间间隔，受Angle和Scale影响
		_LightInterval("Light Interval",Range(0,20)) = 3
		//非线性，受Angle和Scale影响
		_LightOffSetX("Light OffSet ",Range(-10,10)) = 0
		[HideInInspector]	
		_OutLine("_OutLine Color", Color)         = (0, 0, 0, 1.0)
		[HideInInspector]	
		_FixedViewDir("Fixed ViewDir",float) =0	
		[HideInInspector]	
		_TeamFixedViewDir("Team Fixed ViewDir",float) =0	

		_RimbColor("RimbColor", Color) =(0,0,0,0.0)  
		_RimbPower("RimbPower", Range(0,1)) =  0.8
		_RimbWidth("RimbWidth",Float)=8.4

		_UIDir("UIDir",Vector)=(0, 0, -1, 0.0)
		
		_GrayRange("Gray Range", Range(0, 1)) = 0
		_DissolveVector2("DissolveVector2", Vector) = (-100,-100,-100,0)
		[Space(50)]
		[Toggle]_YuanShen("YuanShen", Int) = 0
		_YuanShenLineSize("YuanShenOutlineSize", range(0, 0.1)) = 0.02
		_YuanShenRimbColor("YuanShenRimbColor", Color) = (0,0,0,0.0)
		_YuanShenRimbPower("YuanShenRimbPower", Range(0,1)) = 0.8
		_YuanShenRimbWidth("YuanShenRimbWidth",Float) = 8.4
		_YuanShenLightTex("YuanShen Light Texture", 2D) = "black" {}
		_YuanShenLightColor("YuanShen Light Color",Color) = (1,1,1,1)
		_YuanShenLightPower("YuanShen Light Power",Range(0,5)) = 1
		_YuanShenLightScale("YuanShen Light Scale" , Range(0.5,5)) = 1
		_YuanShenLightAngle("YuanShen Light Angle",Range(-180,180)) = 1
		//每次持续时间，受Angle和Scale影响
		_YuanShenLightDuration("YuanShen Light Duration",Range(0,10)) = 1
		//时间间隔，受Angle和Scale影响
		_YuanShenLightInterval("YuanShen Light Interval",Range(0,20)) = 3
		//非线性，受Angle和Scale影响
		_YuanShenLightOffSetX("YuanShen Light OffSet ",Range(-10,10)) = 0
	}  

	SubShader {  
		
		Lighting Off		
		LOD 750
		Tags{ "Queue" = "Geometry+20" "RenderType" = "Opaque" }
	
		Pass
		{
			ZTest LEqual
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
//#pragma exclude_renderers d3d11 xbox360 gles
// Upgrade NOTE: excluded shader from DX11 and Xbox360 because it uses wrong array syntax (type[size] name)
//#pragma exclude_renderers d3d11 xbox360
			#pragma vertex   vert
			#pragma fragment frag
			#pragma multi_compile_fog 
			#include "UnityCG.cginc"
			#include "UnityStandardConfig.cginc"
			#define INTERNAL_DATA
			#define WorldReflectionVector(data,normal) data.worldRefl


			// fragma input
			struct v2f
			{
				float4 pos      : SV_POSITION;
				float2 uv       : TEXCOORD0;
				float3 viewDir  : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				float3 TBN0 : TEXCOORD3;
				float3 TBN1 : TEXCOORD4;
				float3 TBN2 : TEXCOORD5;
				float3 reflViewDir  : TEXCOORD6;
				float3 normalDir : TEXCOORD7;
				UNITY_FOG_COORDS(8)
				float2 lightuv : TEXCOORD9;
				float4 objPos : TEXCOORD10;

			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			sampler2D _ChanneTex;
			sampler2D _ColorTex;
			float4    _Ambient;
			fixed4    _Dey1;
			fixed4    _Dey2;
			fixed4    _Dey3;
			fixed4    _Dey4;
			float4    _LightDir;
			float  _Metallic;
			float _Glossiness;
			float _Intensity;
			float _Occlusion;
			float4 _DissolveVector2;

			UNITY_DECLARE_TEXCUBE(_Cube);

			
			float _LightMul;

			fixed4  _OutLine;
			fixed	_FixedViewDir; 
			fixed 	_TeamFixedViewDir;

			sampler2D _LightTex ;
			float4  _LightTex_ST;
			half _LightInterval ;
			half _LightDuration ;
			half4 _LightColor ;
			half _LightPower ;
			half _LightAngle ;
			half _LightScale ;
			half _LightOffSetX ;
			half _LightOffSetY ;
			fixed4 _RimbColor;  
			fixed _RimbWidth; 
			float _RimbPower;
			fixed4 _UIDir;
			float _GrayRange;

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv  = v.texcoord;
				o.objPos = v.vertex;

				float3 tangent  = normalize(v.tangent);
				float3 normal   = normalize(v.normal);
				float3 binormal = normalize(cross(normal, v.tangent.xyz) * v.tangent.w);
				
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				o.TBN0 = float3(worldTangent.x, worldBinormal.x, worldNormal.x);
				o.TBN1 = float3(worldTangent.y, worldBinormal.y, worldNormal.y);
				o.TBN2 = float3(worldTangent.z, worldBinormal.z, worldNormal.z);

				
				float3 lightDir = float3(0,0,0);
				//if (_UseSceneLight > 0.0)
				{
				//	lightDir = ObjSpaceLightDir(v.vertex);
				}
				//else
				{
				//	lightDir = normalize(mul(_World2Object, _LightDir))+viewDir;
				}
				

				//兼容gles2.0 手动算的 李藤提供 o.lightDir = mul(TBN, lightDir);
				o.lightDir=float3(tangent.x*lightDir.x+tangent.y*lightDir.y+tangent.z*lightDir.z,
					binormal.x*lightDir.x+binormal.y*lightDir.y+binormal.z*lightDir.z,
					normal.x*lightDir.x+normal.y*lightDir.y+normal.z*lightDir.z
					);

				float3 osviewDir=_UIDir.xyz*_FixedViewDir+ObjSpaceViewDir(v.vertex)*(1-_FixedViewDir);
				osviewDir=float3(0,1,0)*_TeamFixedViewDir+(1-_TeamFixedViewDir)*osviewDir;

				//兼容gles2.0 手动算的 李藤提供 o.viewDir  = mul(TBN, ObjSpaceViewDir(v.vertex));
				o.viewDir =float3(tangent.x*osviewDir.x+tangent.y*osviewDir.y+tangent.z*osviewDir.z,
					binormal.x*osviewDir.x+binormal.y*osviewDir.y+binormal.z*osviewDir.z,
					normal.x*osviewDir.x+normal.y*osviewDir.y+normal.z*osviewDir.z
					);

				o.reflViewDir = -WorldSpaceViewDir( v.vertex );
				o.normalDir=worldNormal;
				UNITY_TRANSFER_FOG(o,o.pos);


				 fixed currentTimePassed = fmod(_Time.y,_LightInterval);

				//uv offset, Sprite wrap mode need "Clamp"
				fixed offsetX = currentTimePassed / _LightDuration;
				fixed offsetY = currentTimePassed / _LightDuration;

				//fixed offsetX =  _LightDuration;
				//fixed offsetY =  _LightDuration;

                float angleInRad = 0.0174444 * _LightAngle;
				float sinInRad = sin(angleInRad);
				float cosInRad = cos(angleInRad);

				float2 offset ;
				offset.x = offsetX ;
				offset.y = offsetY ;

				float2 base = v.texcoord ;
				base.x -= _LightOffSetX ;
				base.y -= _LightOffSetX ;
				base = base / _LightScale ;

				float2 base2 = v.texcoord;
				base2.x  = base.x * cosInRad - base.y * sinInRad ;
				base2.y  = base.y * cosInRad + base.x * sinInRad ;

				o.lightuv = base2 + offset ;

				o.lightuv    = TRANSFORM_TEX(o.lightuv, _LightTex);

				return o;
			}

			float4 frag(v2f i) : COLOR0
			{
				clip(i.objPos.xyz - _DissolveVector2.xyz);

				float3 viewDir  = normalize(i.viewDir);
				float3 lightDir=normalize(i.lightDir+viewDir);

				//法线       
				float4 normalMap = tex2D(_BumpTex, i.uv);
				float3 normalDir = UnpackNormal(normalMap);
				 
				//取像素
				float4 channelCol=tex2D(_ChanneTex,i.uv);
				float4 clr  = tex2D(_MainTex, i.uv);//*channelCol.b;
				float4 colorChannel=tex2D(_ColorTex,i.uv);	
	
				float channelR=channelCol.r;
				float channelG=channelCol.g;
				float channelB=channelCol.b;
				float channelO=(1-colorChannel.r);
				
				 float3 color=	clr.rgb;
				 clr.rgb= color*_Dey1.rgb*colorChannel.g;
				 clr.rgb+=color*_Dey2.rgb*colorChannel.b;
				// clr.rgb+=color*_Dey3.rgb*colorChannel.r;
			     clr.rgb+=color*saturate(1-colorChannel.g-colorChannel.b);
				
			
				 // clr.rgb=colorChannel.a;
				//clr.rgb=clr.a;

				//虚拟灯光brdf计算
				half3 halfDir=SafeNormalize(lightDir+viewDir);

				half nl = DotClamped (normalDir, lightDir);
				half nh = DotClamped (normalDir, halfDir);
				half nv = DotClamped (normalDir, viewDir);
				half lh = DotClamped(lightDir,halfDir);

				//clr+=(1-nv-0.2)*clr*0.5;	

				half oneMinusRoughness=_Glossiness*(channelR);
				half roughness=	1-oneMinusRoughness;		
				half specularPower=RoughnessToSpecPower(roughness);

				half invV=lh*lh*oneMinusRoughness+roughness*roughness;
				half invF=lh;
				half specular = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);
				// if (IsGammaSpace())
				// {
					specular =sqrt(max(1e-4h, specular));
				// }

				#if SHADER_API_GLES || SHADER_API_GLES3
				specular = clamp(specular, 0.0, 100.0);
				#endif

				//反射
				half3 wn;
				wn.x=dot(i.TBN0,normalDir);
				wn.y=dot(i.TBN1,normalDir);
				wn.z=dot(i.TBN2,normalDir);
				half3 refDir = reflect(i.reflViewDir, wn);

				float4 c;
				float metallic=_Metallic*channelG;
				//灯光影响颜色计算
				half oneMinusReflectivity=0;
				half3 specColor=0;
				c.rgb = DiffuseAndSpecularFromMetallic (clr.rgb, _Metallic*channelG, /*out*/ specColor, /*out*/ oneMinusReflectivity);
				half3 diffColor=c.rgb;

				//反射光滑度计算
				half realRoughness = roughness*roughness;		// need to square perceptual roughness
				half surfaceReduction = IsGammaSpace() ? 0.28 : (0.6 - 0.08*roughness);
				surfaceReduction = 1.0 - realRoughness*roughness*surfaceReduction;

				#if UNITY_OPTIMIZE_TEXCUBELOD
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(_Cube,refDir, 4);
				if(roughness > 0.5)
				rgbm = lerp(rgbm, UNITY_SAMPLE_TEXCUBE_LOD(_Cube, refDir, 8), 2*roughness-1);
				else
				rgbm = lerp(UNITY_SAMPLE_TEXCUBE(_Cube, refDir), rgbm, 2*roughness);
				#else
				half mip = roughness * 8;
				half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(_Cube, refDir, mip);
				#endif


				half grazingTerm = saturate(oneMinusRoughness + (1-oneMinusReflectivity));
				half3 relColor=(rgbm.rgb*metallic+clr.rgb*(1-metallic))*surfaceReduction* FresnelLerpFast (specColor, grazingTerm, nv);;
				half giDiffuse=0.4;
				c.rgb=(diffColor+specular*specColor*channelO*(1-_Occlusion))*_Ambient*nl*_Intensity+diffColor*giDiffuse+relColor;
				
				fixed3 rimColor =_RimbColor.rgb*pow(_RimbPower+saturate(1-nv), _RimbWidth);
				c.rgb+=rimColor;
				
				//流光
				fixed4 lightCol  = tex2D(_LightTex, i.lightuv);
				lightCol *= _LightColor ;
				c.rgb+=lightCol.rgb* _LightPower*c.rgb*channelB;
				
				c.a=1;
				UNITY_APPLY_FOG(i.fogCoord, c.rgb);
				UNITY_OPAQUE_ALPHA(c.a);

				fixed4 gray = dot(c.rgb, fixed3(0.299, 0.587, 0.114));

				return lerp(c, gray, _GrayRange);
			}

			ENDCG

			CGINCLUDE
			inline half RoughnessToSpecPower (half roughness)
			{
				#if UNITY_GLOSS_MATCHES_MARMOSET_TOOLBAG2
				// from https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html
				half n = 10.0 / log2((1-roughness)*0.968 + 0.03);
				#if defined(SHADER_API_PS3) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
				// Prevent fp16 overflow when running on platforms where half is actually in use.
				n = max(n,-255.9370);  //i.e. less than sqrt(65504)
				#endif
				return n * n;

				// NOTE: another approximate approach to match Marmoset gloss curve is to
				// multiply roughness by 0.7599 in the code below (makes SpecPower range 4..N instead of 1..N)
				#else
				half m = max(1e-4f, roughness * roughness);			// m is the true academic roughness.

				half n = (2.0 / (m*m)) - 2.0;						// https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
				n = max(n, 1e-4f);									// prevent possible cases of pow(0,0), which could happen when roughness is 1.0 and NdotH is zero
				return n;
				#endif
			}
			inline half DotClamped (half3 a, half3 b)
			{
				#if (SHADER_TARGET < 30 || defined(SHADER_API_PS3))
				return saturate(dot(a, b));
				#else
				return max(0.0h, dot(a, b));
				#endif
			}
			inline half3 SafeNormalize(half3 inVec)
			{
				half dp3 = max(0.001f, dot(inVec, inVec));
				return inVec * rsqrt(dp3);
			}
			inline half3 FresnelLerpFast (half3 F0, half3 F90, half cosA)
			{
				half t =pow(1-cosA,4);// Pow4 (1 - cosA);
				return lerp (F0, F90, t); 
			}

			inline half OneMinusReflectivityFromMetallic(half metallic,float dielec)
			{
				half oneMinusDielectricSpec = 1-dielec;
				return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
			}
			inline half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
			{
				float dielec =0.2;
				specColor = lerp (float3(dielec,dielec,dielec), albedo, metallic);
				oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic,dielec);
				return albedo * oneMinusReflectivity;
			}
			inline	half GetRoughness (float roughnessIn) 
			{
				half roughness = roughnessIn;			// MM: switched to this
				roughness = roughness*(1.7 - 0.7*roughness);
				return roughness;
			}

			ENDCG
		} 

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile __ _YUANSHEN_ON

			sampler2D _MainTex;
			sampler2D _BumpTex;
			fixed4 _UIDir;
			fixed _FixedViewDir;
			fixed _TeamFixedViewDir;
			float _YuanShenLineSize;
			fixed4 _YuanShenRimbColor;
			fixed _YuanShenRimbWidth;
			float _YuanShenRimbPower;
			sampler2D _YuanShenLightTex;
			float4 _YuanShenLightTex_ST;
			half _YuanShenLightInterval;
			half _YuanShenLightDuration;
			half4 _YuanShenLightColor;
			half _YuanShenLightPower;
			half _YuanShenLightAngle;
			half _YuanShenLightScale;
			half _YuanShenLightOffSetX;
			half _YuanShenLightOffSetY;

			struct v2f 
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				float2 lightuv : TEXCOORD3;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				#ifdef _YUANSHEN_ON
				// UNITY_MATRIX_IT_MV为【模型坐标-世界坐标-摄像机坐标】【专门针对法线的变换】
				// 法线乘以MV，将模型空间 转换 视图空间
				float3 norm = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
				// 转换 视图空间 到 投影空间 【3D转2D】
				float2 offset = TransformViewToProjection(norm.xy);
				// 得到的offset，模型被挤的非常大，然后乘以倍率
				o.pos.xy += offset * _YuanShenLineSize;
				o.uv = v.texcoord;

				float3 tangent = normalize(v.tangent);
				float3 normal = normalize(v.normal);
				float3 binormal = normalize(cross(normal, v.tangent.xyz) * v.tangent.w);

				float3 osviewDir = _UIDir.xyz*_FixedViewDir + ObjSpaceViewDir(v.vertex)*(1 - _FixedViewDir);
				osviewDir = float3(0, 1, 0)*_TeamFixedViewDir + (1 - _TeamFixedViewDir)*osviewDir;

				//兼容gles2.0 手动算的 李藤提供 o.viewDir  = mul(TBN, ObjSpaceViewDir(v.vertex));
				o.viewDir = float3(tangent.x*osviewDir.x + tangent.y*osviewDir.y + tangent.z*osviewDir.z,
					binormal.x*osviewDir.x + binormal.y*osviewDir.y + binormal.z*osviewDir.z,
					normal.x*osviewDir.x + normal.y*osviewDir.y + normal.z*osviewDir.z
					);
				UNITY_TRANSFER_FOG(o, o.pos);
				fixed currentTimePassed = fmod(_Time.y, _YuanShenLightInterval);
				
				//uv offset, Sprite wrap mode need "Clamp"
				fixed offsetX = currentTimePassed / _YuanShenLightDuration;
				fixed offsetY = currentTimePassed / _YuanShenLightDuration;
				
				//fixed offsetX =  _LightDuration;
				//fixed offsetY =  _LightDuration;
				
				float angleInRad = 0.0174444 * _YuanShenLightAngle;
				float sinInRad = sin(angleInRad);
				float cosInRad = cos(angleInRad);

				float2 offset2;
				offset2.x = offsetX;
				offset2.y = offsetY;
				
				float2 base = v.texcoord;
				base.x -= _YuanShenLightOffSetX;
				base.y -= _YuanShenLightOffSetY;
				base = base / _YuanShenLightScale;
				
				float2 base2 = v.texcoord;
				base2.x = base.x * cosInRad - base.y * sinInRad;
				base2.y = base.y * cosInRad + base.x * sinInRad;
				
				o.lightuv = base2 + offset2;
				
				o.lightuv = TRANSFORM_TEX(o.lightuv, _YuanShenLightTex);

				#endif
				return o;
			}

			float4 frag(v2f i) : COLOR
			{
				float4 c;
				c.w = 0;
				#ifdef _YUANSHEN_ON
				float3 viewDir = normalize(i.viewDir);   
				float4 normalMap = tex2D(_BumpTex, i.uv);
				float3 normalDir = UnpackNormal(normalMap);
				half nv = DotClamped(normalDir, viewDir);
				fixed3 rimColor = _YuanShenRimbColor.rgb*pow(_YuanShenRimbPower + saturate(1 - nv), _YuanShenRimbWidth);
				//流光
				c.rgb = rimColor;
				fixed4 lightCol = tex2D(_YuanShenLightTex, i.lightuv);
				lightCol *= _YuanShenLightColor;
				c.rgb += lightCol.rgb* _YuanShenLightPower;
				c.a = _YuanShenRimbColor.a * Luminance(c.rgb);
				UNITY_APPLY_FOG(i.fogCoord, c.rgb);
				#endif
				return c;
			}
			ENDCG
		}
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
			sampler2D _ColorTex;
			fixed4    _Dey1;
			fixed4    _Dey2;
			fixed4    _Dey3;
			fixed4    _Dey4;
			float	  _GrayRange;
		
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
				fixed4 clr = tex2D(_MainTex, i.texcoord);
				float4 colorChannel=tex2D(_ColorTex,i.texcoord);	


				 float3 color=	clr.rgb;
				 clr.rgb= color*_Dey1.rgb*colorChannel.g;
				 clr.rgb+=color*_Dey2.rgb*colorChannel.b;
				 clr.rgb+=color*saturate(1-colorChannel.g-colorChannel.b);
				
				UNITY_APPLY_FOG(i.fogCoord, clr);
				UNITY_OPAQUE_ALPHA(clr.a);

				fixed4 gray = dot(clr.rgb, fixed3(0.299, 0.587, 0.114));
				return lerp(clr, gray, _GrayRange);
			}
		ENDCG
	}
}

	Fallback "Diffuse"  
}
