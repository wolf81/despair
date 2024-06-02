extern float alpha;

vec4 effect(vec4 col, Image tex, vec2 texCoord, vec2 screenCoord)
{
    // get color at texture coord
    vec4 texCol = texture2D(tex, texCoord);

    // multiply with alpha, so we can properly show transparancy if needed
    return vec4(texCol.xyz, texCol[3] * alpha);
}
