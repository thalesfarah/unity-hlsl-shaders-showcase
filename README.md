# Unity HLSL Shaders Showcase 🧪📚

![Unity](https://img.shields.io/badge/Unity-6.3.9f1-black?logo=unity)
![Status](https://img.shields.io/badge/Status-Academic%20Study-brightgreen)
![Category](https://img.shields.io/badge/Category-Technical%20Art-blue)

This repository is a collection of custom shaders developed as part of my **Academic Studies** in Game Development. The core intent of this project was to step away from visual scripting and learn how to code shaders **"from scratch" (handwritten HLSL)**.

---

## 🚀 Featured Shaders (Handwritten HLSL)

*The following effects were implemented to study specific rendering challenges:*

1. **Linear UV Gradient Controller:** A fundamental study on texture coordinate (UV) manipulation through raw code. This shader implements a manual linear function within the Fragment Shader (f(x)=ax+b) to generate dynamic gradients. ![ShaderA](https://github.com/user-attachments/assets/71c72801-cbb1-4d34-9faf-3717c77d4ea8)
2. **Diagonal Multi-Color Interpolator:** A technical exploration of diagonal color blending and non-linear interpolation. This shader calculates the difference between UV axes (U−V) to create a diagonal gradient, then applies a quadratic function (diff2) to achieve smoother, non-linear color transitions.![ShaderB](https://github.com/user-attachments/assets/d80b6411-5217-47a6-9f5b-69f080a04f97)
3. **Bi-Directional Coordinate Blender:** IA more complex study on coordinate-based color layering. This shader generates two independent linear gradients by calculating both the sum (U+V) and the difference (U−V) of texture coordinates. These gradients are then assigned to specific color channels (Magenta and Cyan) and blended additively.
4. **Sinusoidal Coordinate Wave:** This shader introduces trigonometric functions into the graphics pipeline to create procedural patterns. By wrapping a diagonal linear equation (U−V) inside a sin() function, it generates a repeating wave pattern across the surface of the mesh.
5. **Procedural Grid & Dot Matrix:** This shader represents an advanced study in procedural pattern generation using overlapping periodic functions. By calculating the square of the sine (sin2) on both U and V axes independently and then combining them with an intensity multiplier (_E), it creates a customizable grid or dot matrix effect.
6. **Radial Vignette & Quadratic Masking:** This shader explores the use of quadratic functions (x2+y2) to create procedural masking effects. By calculating the power of combined UV coordinates and applying an intensity multiplier (_E), it generates a smooth, circular gradient falloff from a specific origin point.
7. **Binary Threshold & Step Logic:** A study on non-linear color transitions and discrete value mapping. This shader uses the ceil() function to snap a linear gradient and its inverse into solid, binary color states.
8. **Bi-Linear Masking & Step Function:** This shader combines bi-linear coordinate multiplication with discrete thresholding. By multiplying manipulated X and Y coordinates (x⋅y) and applying a ceil() function to the resulting color vector, it generates procedural rectangular masks and sharp, solid-color intersections.
9. **Animated Checkerboard Grid:** This shader integrates time-based animation with procedural patterns. It utilizes sine functions on both axes to generate a binary grid mask via ceil(x * y), and then animates the Red and Blue color channels independently using Unity's built-in _Time variable.
10. **Radial Rounding & Midpoint Thresholding:** This study explores the round() function as an alternative to ceil() and floor() for creating discrete procedural shapes. By applying quadratic distance calculations (x2+y2) and rounding the results, this shader creates sharp radial masks with a specific threshold at the 0.5 midpoint.
11. **Trigonometric Power Thresholding:** A complex synthesis study that combines quadratic power functions with trigonometric oscillation. This shader passes a non-linear UV calculation into a sin() function before snapping the result with ceil(), creating a unique, high-contrast pulsing band effect.
12. **Quadratic Radial Ripple:** A study on creating procedural wave propagation. By applying a sine function to the sum of quadratic UV coordinates (x2+y2), this shader generates concentric circular ripples. The use of a large multiplier (20) and an intensity control (_E) allows for the creation of high-frequency interference patterns.
13. **Dissolve Shader:** practical application of procedural masks using external noise textures. This shader implements a multi-stage dissolve effect featuring a main color, a "pre-dissolve" transition area, and a glowing edge. It handles transparency (SrcAlpha OneMinusSrcAlpha) and dynamic animation cycles via _Time.
14. **Halftone Shader:** A complex NPR (Non-Photorealistic Rendering) effect that replicates a comic-book aesthetic using screen-space Voronoi noise. This shader calculates real-time lighting intensity and uses it to drive the scale and distribution of a procedural "halftone" dot pattern.
15. **Hologram Shader:** A complex transparency shader that combines view-dependent effects with procedural animation. It utilizes the Fresnel Effect (based on the dot product of the surface normal and the view direction) to create glowing edges, layered with moving sinusoidal scanlines.
16. **Shield Shader:** A high-end VFX shader featuring a moving hexagonal pattern and dynamic scene interaction. It utilizes the Depth Texture (SampleSceneDepth) to calculate the distance between the shield's surface and world geometry, creating a glowing "intersection" line where the shield touches the floor or other objects.

> **💡 Technical Note:** By coding these, I was able to avoid the redundant instructions often generated by visual editors, resulting in more optimized and lightweight shaders.

---

## 🔍 The "Hard-Coded" Philosophy

While tools like Shader Graph are powerful for prototyping, I dedicated this study to understanding the underlying logic for two main reasons:

1.  **Deep Understanding:** Learning how the vertex and fragment stages communicate without abstraction. It’s about understanding the math that powers the nodes.
2.  **Performance & Optimization:** Handwritten shaders allow for tighter control over the GPU. They are often more efficient for games because they eliminate unnecessary calculations.

## 🛠️ Technical Learning Path

* **HLSL Fundamentals:** Transitioning from nodes to raw code to master register control.
* **Graphics Pipeline:** Deep dive into the URP (Universal Render Pipeline) architecture.
* **Math for Rendering:** Direct application of linear algebra and trigonometry.
* **Shader Efficiency:** Minimizing performance impact to ensure high-fidelity visuals even on limited hardware.

## 📦 Project Info

* **Unity Version:** 6.3.9f1.
* **Context:** Developed during my college years as an achademic project.
* **How to explore:** Check the `Assets/HLSL_Showcase` and `Assets/ShaderLab_Showcase` folder for the raw `.shader` files.

---

*Shared under the MIT License - "To understand the tool, you must first understand the code."*
