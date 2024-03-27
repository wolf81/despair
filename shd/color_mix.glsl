extern vec4 blendColor;
extern float alpha;

vec4 effect(vec4 col, Image tex, vec2 texCoord, vec2 screenCoord)
{
    // get color at texture coord
    vec4 texCol = texture2D(tex, texCoord);

    // mix texture color with blend color using blend color alpha
    vec4 color = mix(texCol, blendColor, blendColor[3]);

    // multiply with alpha, so we can properly show transparancy if needed
    return vec4(color.xyz, texCol[3] * alpha);
}
