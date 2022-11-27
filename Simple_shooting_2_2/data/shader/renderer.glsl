const vec2 offset=vec2(-5.,5.);
const float power=1.5;
const float gamma=1.0/power;
const float albedo=0.2;

uniform ivec2 seed;
uniform sampler2D light;
uniform sampler2D primitive;
uniform sampler2D material;//alpha->x ... r->alpha g->roughness b->metalness
uniform sampler2D background;
uniform vec2 resolution;
uniform vec3 GI;
uniform vec3 ambient;
 
float random(vec2 texCoord, int Seed){
  return fract(sin(dot(texCoord.xy, vec2(12.9898, 78.233)) + Seed) * 43758.5453);
}

vec3 shadow(vec3 c,vec4 bg,vec4 m){
  return min(vec3(1.),ambient+((GI*(1-m.b)+bg.rgb*mix(vec3(0.04),c.rgb,m.b))*min(vec3(1.),pow((c+vec3(1.))*(1.-m.r),vec3(2.))))*(1.-m.r));
}

vec3 surface(vec4 c,vec4 bg,vec4 m){
  return c.rgb*(ambient+GI*(1-m.b))+bg.rgb*mix(vec3(0.04),c.rgb,m.b);
}

vec3 getColor(sampler2D t,vec2 p){
  vec4 m=texture2D(material,p);
  vec4 back=texture2D(background,p);
  return max(shadow(surface(texture2D(t,p),back,m),back,m),texture2D(light,p).rgb);
}

void main(void){
  vec2 pos=gl_FragCoord.xy;
  vec2 tFrag = vec2(1.)/resolution.xy;
  vec4 color=texture2D(primitive,pos*tFrag);
  float Roughness=texture2D(material,pos*tFrag).g;
  vec2 rand=(vec2(random(pos,seed.x),random(pos,seed.y))-0.5)*5;
  pos+=offset;
  vec3 sum = getColor(primitive, pos * tFrag);
  sum += getColor(primitive, (pos + (vec2(-1.0,  1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0,  1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 1.0,  1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-1.0,  0.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 1.0,  0.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-1.0, -1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0, -1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 1.0, -1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-2.0,  2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-1.0,  2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0,  2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 1.0,  2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 2.0,  2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-2.0,  1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 2.0,  1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-2.0,  0.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 2.0,  0.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-2.0, -1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 2.0, -1.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-2.0, -2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-1.0, -2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0, -2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 1.0, -2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 2.0, -2.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0,  3.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 0.0, -3.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2( 3.0,  0.0)+rand)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + (vec2(-3.0,  0.0)+rand)*Roughness) * tFrag);
  gl_FragColor=mix(color,vec4(sum/29.,1.),1.-texture2D(material,gl_FragCoord.xy*tFrag).r);//GI*mix(vec3(0.08), BaseColor, Metallic)
}