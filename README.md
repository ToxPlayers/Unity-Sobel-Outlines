# Unity-Sobel-Outlines
Toon sobel outlines using depth + view normals, and distance based parameters. (URP) <br>

[toon shading in the image below by cyanilux, not included](https://github.com/Cyanilux/URP_ShaderGraphCustomLighting)

![image](https://github.com/ToxPlayers/Unity-SobelOutlines/assets/67845762/ec765741-6fbe-46a1-a688-c6b3b443a88c)

# Usage
Download the unity package from Releases.
Add **Full Screen Pass Renderer Feature** to your Universal Renderer Data.<br>
Requirements must have **Depth** and **Normal** enabled.<br>
Set the material to the Outlines material with the outlines shader.<br>

![5bf6b813c66f0a20792b9eee6a847b7c](https://github.com/ToxPlayers/Unity-SobelOutlines/assets/67845762/81d8f72f-1b7f-429a-8a88-263aefea2326)

# Parameters  
<h1> IMPORTANT: when testing with scene view camera, make sure the near and far values in the scene camera settings are the same as your game's camera.</h1>
  
**Scale -** the distance of the pixel sampling. Values other than 1 may introduce visual artifacts.<br> 
**NearNormalThreshold -** the normal threshold when the camera is at 0 distance.<br> 
**FarNormalThreshold -** the normal threshold when the camera is at **MaxFadeDistance** distance.<br>
**NearDepthThreshold -** the depth threshold when '''.<br>
**FarDepthThreshold -** the depth threshold when '''.<br>
**MinFadeDistance -** the minimum distance for the fade to begin.<br>
**MaxFadeDistance -** the maximum distance for the outline to be visible. pixels farther than **MaxFadeDistance** will not be sampled.<br>
**Angle -** A viewing angle for multiplying the depth outline to avoid artifacts when the viewing angle is nearly perpendicular.<br>
**AngleMultiplier -** When reaching **Angle**, depth outline will be multiplied by this value.<br> 

**The settings I used:**<br>
![01acbabaf148f51cca2967524eb14081](https://github.com/ToxPlayers/Unity-SobelOutlines/assets/67845762/c1e5d90a-2629-43db-9a97-28f2851ae36e)

