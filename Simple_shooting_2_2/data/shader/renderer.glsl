const vec2 offset=vec2(-10.,10.);
const float power=1.5;
const float gamma=1.0/power;
const float albedo=0.2;

uniform sampler2D light;
uniform sampler2D primitive;
uniform sampler2D material;//alpha->x ... r->alpha g->roughness b->?
uniform vec2 resolution;
uniform vec3 GI;
uniform vec3 ambient;

vec3 shadow(vec4 c,vec4 m){
  return min(vec3(1.),ambient+(GI*min(vec3(1.),pow((c.rgb+vec3(1.))*(1.-m.r),vec3(2.))))*(1.-m.r));
}

vec3 getColor(sampler2D t,vec2 p){
  vec4 m=texture2D(material,p);
  return max(shadow(texture2D(t,p),m),texture2D(light,p).rgb);
}

void main(void){
  vec2 pos=gl_FragCoord.xy;
  vec2 tFrag = vec2(1.)/resolution.xy;
  vec4 color=texture2D(primitive,pos*tFrag);
  float Roughness=texture2D(material,pos*tFrag).g;
  pos+=offset;
  vec3 sum = getColor(primitive, pos * tFrag);
  sum += getColor(primitive, (pos + vec2(-1.0,  1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0,  1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 1.0,  1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-1.0,  0.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 1.0,  0.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-1.0, -1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0, -1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 1.0, -1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-2.0,  2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-1.0,  2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0,  2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 1.0,  2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 2.0,  2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-2.0,  1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 2.0,  1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-2.0,  0.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 2.0,  0.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-2.0, -1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 2.0, -1.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-2.0, -2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-1.0, -2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0, -2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 1.0, -2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 2.0, -2.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0,  3.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 0.0, -3.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2( 3.0,  0.0)*Roughness) * tFrag);
  sum += getColor(primitive, (pos + vec2(-3.0,  0.0)*Roughness) * tFrag);
  gl_FragColor=mix(color,vec4(sum/29.,1.),1.-texture2D(material,gl_FragCoord.xy*tFrag).r);//GI*mix(vec3(0.08), BaseColor, Metallic)
}