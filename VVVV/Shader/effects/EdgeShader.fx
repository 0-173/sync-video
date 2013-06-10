//@author: vvvv group
//@help: basic pixel based lightning with directional light
//@tags: shading, blinn
//@credits:

// -----------------------------------------------------------------------------
// PARAMETERS:
// -----------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{ 
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = Point;
    MagFilter = LINEAR;
};
texture NormTex <string uiname="Normal Texture";>;
sampler NormSamp = sampler_state    //sampler for doing the texture-lookup
{ 
    Texture   = (NormTex);          //apply a texture to the sampler
    AddressU = Clamp;
    AddressV = Clamp;
    MipFilter = LINEAR;         //sampler states
    MinFilter = Point;
    MagFilter = LINEAR;
};

float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;
float4 lColor : COLOR <String uiname="Color";>  = {1, 1, 1, 1};
float edgeWeight <float uimin=0.0;> = 0.05;

struct vs2ps
{
    float4 PosWVP: POSITION;
    float4 TexCd : TEXCOORD;
    float3 NormV: TEXCOORD2;
};

// -----------------------------------------------------------------------------
// VERTEXSHADERS
// -----------------------------------------------------------------------------

vs2ps VS(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //inverse light direction in view space
//    Out.LightDirV = normalize(-mul(lDir, tV));
    
    //normal in view space
    Out.NormV = normalize(mul(NormO, tWV));

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    Out.TexCd = mul(TexCd, tTex);
	
	//Out.PosWVP.x += 0.2;
    return Out;
}

vs2ps VS_normalBased(
    float4 PosO: POSITION,
    float4 TexCd : TEXCOORD)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;
    
    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);
    // coordinate on screen
	Out.TexCd = TexCd;
	
	//Out.PosWVP.x += 0.2;
    return Out;
}

// -----------------------------------------------------------------------------
// PIXELSHADERS:
// -----------------------------------------------------------------------------

float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(Samp, In.TexCd);
	col.a *= Alpha;

	float2 tc = saturate(In.TexCd);
	col *=	((tc.x < edgeWeight) || (tc.x > 1-edgeWeight) ||
			(tc.y < edgeWeight) || (tc.y > 1-edgeWeight) ) ?
			lColor : 0;

    return col;
}


float2 PixelKernel[4] =
{
    { 0,  1},
    { 1,  0},
    { 0, -1},
    {-1,  0}
};

float2 TexelKernel[4]
<
	string ConvertPixelsToTexels = "PixelKernel";
>;

//get normals only
float3 GetNormals(float4 col)
{
  float3 n;
  n.xy = col.rg * 2 - 1;
  n.z = -sqrt(1 - dot(n.xy, n.xy));
  return n;
}

float FarPlane;
//get normals and depth
float4 GetNormalsAndDepth(float4 col)
{
  float4 n;
  n.xy = col.rg * 2 - 1;
  n.z = -sqrt(1 - dot(n.xy, n.xy));
  n.w = (col.b + col.a / 255) * FarPlane;
  return n;
}

float scurve(float x, float steep = 1) {
	return (1+tanh(2*3.1415*(x*steep-0.5)))/2;
}

float normSensitivity <float uimin=0.0; float uimax=1.0; string uiname="normal sensitivity";> = 0.05;
float depthSensitivity <float uimin=0.0; string uiname="depth sensitivity";> = 1;

float4 PS_normalBased(vs2ps In): COLOR
{
    float4 NormDepth = GetNormalsAndDepth(tex2D(NormSamp, In.TexCd ));

	float Alpha = 0;
	float3 SumNormals = 0.0;
	float SumDepth = 0.0;
    for( int i = 0; i < 4; i++ ) {
		//Sum += saturate(1-dot( Normal, GetNormals(tex2D( NormSamp, In.TexCd + TexelKernel[i])) ));
    	float4 Neighbour = GetNormalsAndDepth(tex2D( NormSamp, In.TexCd + TexelKernel[i]));
		SumNormals += abs(NormDepth.xyz - Neighbour.xyz);
		SumDepth += abs(NormDepth.w - Neighbour.w);
    }
	float4 col = lColor;
	col.a = scurve( (sqrt(dot(SumNormals,SumNormals)) / normSensitivity / 4), 1);
	col.a += scurve(SumDepth / depthSensitivity / 4, 1);
	col.a = saturate(col.a);
	
    return col;
}


// -----------------------------------------------------------------------------
// TECHNIQUES:
// -----------------------------------------------------------------------------

technique TTextureEdge
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS();
        PixelShader = compile ps_2_0 PS();
    }
}

technique TNormalEdge
{
	pass P0
	{
		VertexShader = compile vs_1_1 VS_normalBased();
		PixelShader = compile ps_3_0 PS_normalBased();
		ZEnable = false;
	}
}
