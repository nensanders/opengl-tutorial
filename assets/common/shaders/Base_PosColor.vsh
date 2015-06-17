attribute highp vec4 a_Position;
attribute lowp  vec4 a_Color;

uniform highp   mat4  u_MVPMatrix;

varying lowp    vec4 v_Color;

void main()
{
    gl_Position = a_Position * u_MVPMatrix;

    v_Color = a_Color;
}
