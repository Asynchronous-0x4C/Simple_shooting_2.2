uniform sampler2D texture;
uniform float  weight[10];
uniform vec2   resolution;
uniform bool   horizontal;

void main(void){
  vec2 tFrag = vec2(1.)/resolution.xy;
  vec4  destColor = vec4(0.);
  if(horizontal){
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-9.0, 0.0)) * tFrag) * weight[9];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-8.0, 0.0)) * tFrag) * weight[8];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-7.0, 0.0)) * tFrag) * weight[7];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-6.0, 0.0)) * tFrag) * weight[6];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-5.0, 0.0)) * tFrag) * weight[5];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-4.0, 0.0)) * tFrag) * weight[4];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-3.0, 0.0)) * tFrag) * weight[3];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-2.0, 0.0)) * tFrag) * weight[2];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(-1.0, 0.0)) * tFrag) * weight[1];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 0.0, 0.0)) * tFrag) * weight[0];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 1.0, 0.0)) * tFrag) * weight[1];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 2.0, 0.0)) * tFrag) * weight[2];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 3.0, 0.0)) * tFrag) * weight[3];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 4.0, 0.0)) * tFrag) * weight[4];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 5.0, 0.0)) * tFrag) * weight[5];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 6.0, 0.0)) * tFrag) * weight[6];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 7.0, 0.0)) * tFrag) * weight[7];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 8.0, 0.0)) * tFrag) * weight[8];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2( 9.0, 0.0)) * tFrag) * weight[9];
  }else{
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -9.0)) * tFrag) * weight[9];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -8.0)) * tFrag) * weight[8];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -7.0)) * tFrag) * weight[7];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -6.0)) * tFrag) * weight[6];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -5.0)) * tFrag) * weight[5];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -4.0)) * tFrag) * weight[4];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -3.0)) * tFrag) * weight[3];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -2.0)) * tFrag) * weight[2];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0, -1.0)) * tFrag) * weight[1];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  0.0)) * tFrag) * weight[0];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  1.0)) * tFrag) * weight[1];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  2.0)) * tFrag) * weight[2];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  3.0)) * tFrag) * weight[3];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  4.0)) * tFrag) * weight[4];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  5.0)) * tFrag) * weight[5];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  6.0)) * tFrag) * weight[6];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  7.0)) * tFrag) * weight[7];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  8.0)) * tFrag) * weight[8];
    destColor += texture2D(texture, (gl_FragCoord.st + vec2(0.0,  9.0)) * tFrag) * weight[9];
  }
  gl_FragColor = destColor;
}