#ifndef VIEW_SPACE_NORMALS_TEXTURE_EXT
#define VIEW_SPACE_NORMALS_TEXTURE_EXT

static float2 sobelSamplePoints[9] =
{
    float2(-1, 1), float2(0, 1), float2(1, 1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, -1), float2(0, -1), float2(1, -1),
};

float invLerp(float from, float to, float value)
{
    return (value - from) / (to - from);
}

float3 remap(float3 In, float2 InMinMax, float2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void ViewNormals_float(float2 UV, out float3 outNormals)
{
    float3 normalWS = SHADERGRAPH_SAMPLE_SCENE_NORMAL(UV); 
    float renormFactor = 1.0 / length(normalWS); 
    normalWS = renormFactor * normalWS; 
    outNormals = mul(normalWS, (float3x3) UNITY_MATRIX_I_V);
}

void GetDepthAndNormal(float2 UV, out float outDepth, out float3 outNormals)
{
    ViewNormals_float(UV, outNormals);
    outDepth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV);
}

void GetAngleStrength_float(float2 UV, float3 viewPos, float angle, float angleMult, out float outStrength)
{
    float3 normals;
    ViewNormals_float(UV, normals); 
    viewPos = remap(viewPos, float2(0, 1), float2(1, -1));
    float viewDot = dot(viewPos, normals) - 1;
    outStrength = smoothstep(angle, 2, viewDot);
    outStrength *= angleMult;
    outStrength + 1;
}

void Outline_float(float2 UV, float scale, float3 viewPos, float angle, float angleMult, 
                    float nearNormalThreshold, float farNormalThreshold, float nearDepthThreshold, float farDepthThreshold, 
                    float minFadeDistance, float maxFadeDistance, float camDistance, out float outLine)
{  
    if (camDistance > maxFadeDistance)
    {
        outLine = 0;
        return;
    }
    
    // We have to run the sobel algorithm over the XYZ channels separately, like color
    float2 sobelX = 0; float2 sobelY = 0; float2 sobelZ = 0;
    float2 sobelDepth = 0;
    scale *= 0.001;
    
    // We can unroll this loop to make it more efficient
    [unroll]
    for (int i = 0; i < 9; i++)
    {
        float depth;
        float3 normal;
        GetDepthAndNormal(UV + sobelSamplePoints[i] * scale, depth, normal);
        
        // Create the kernel for this iteration
        float2 kernel = sobelSamplePoints[i];
        // Accumulate samples for each coordinate and depth
        sobelX += normal.x * kernel;
        sobelY += normal.y * kernel;
        sobelZ += normal.z * kernel;
        sobelDepth += depth * kernel;
    }
    
    // Get the final sobel value
    // Combine the XYZ values by taking the one with the largest sobel value
    float normalOutline = max(length(sobelX), max(length(sobelY), length(sobelZ)));
    
    float depthOutline = length(sobelDepth); 
    float angleStrength;
    GetAngleStrength_float(UV, viewPos, angle, angleMult, angleStrength);
    depthOutline *= 1 - angleStrength;
    
    // Distance based threshold
    float normalizedThresholdDistance = camDistance / maxFadeDistance;
    
    float normalThreshold = lerp(nearNormalThreshold, farNormalThreshold, normalizedThresholdDistance);
    normalOutline = step(normalThreshold, normalOutline);
    
    float depthThreshold = lerp(nearDepthThreshold, farDepthThreshold, normalizedThresholdDistance);
    depthOutline = step(depthThreshold, depthOutline);
    
    outLine = saturate(max(normalOutline, depthOutline));

    // fade
    float clampedDistance = clamp(camDistance, minFadeDistance, maxFadeDistance);
    float normalizedFadeDistance = invLerp(maxFadeDistance, minFadeDistance, clampedDistance);
    outLine *= normalizedFadeDistance;
}


#endif 