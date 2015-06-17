attribute highp vec4 a_Position;
attribute lowp  vec4 a_Color;
attribute highp vec3 a_Normal;

uniform   highp mat4 u_MVPMatrix;
uniform   highp mat3 u_NormalMatrix;

uniform   highp vec3 u_AmbientColorVector;
uniform   highp vec3 u_LightColorVector;
uniform   highp vec3 u_LightDirection;

varying   lowp  vec4 v_Color;
varying   lowp  vec3 v_Lighting;

void main()
{
    gl_Position = a_Position * u_MVPMatrix;

    v_Color = a_Color;

    vec3 eyeNormal = normalize(u_NormalMatrix * a_Normal);
    float directional = max(0.0, dot(eyeNormal, normalize(u_LightDirection)));

    v_Lighting = u_AmbientColorVector + (u_LightColorVector * directional);
}
