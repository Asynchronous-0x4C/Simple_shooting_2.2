const vec2 offset=vec2(-5.,5.);
const float power=1.5;
const float gamma=1.0/power;
const float albedo=0.2;

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
 
vec2 random2(vec2 texCoord, ivec2 Seed){
  return fract(sin(vec2(dot(texCoord.xy, vec2(12.9898, 78.233))) + Seed) * 43758.5453);
}

vec3 surface(vec4 c,vec4 bg,vec4 m){
  vec3 s=c.rgb*(ambient+GI*(1.-m.b)+bg.rgb*mix(vec3(0.04),c.rgb,m.b));
  vec3 l=GI*(1.-m.b)+bg.rgb*mix(vec3(0.04),c.rgb,m.b);
  return ambient*mix(ambient,bg.rgb,(1.-m.r*m.r)*m.b)+l*min(vec3(1.),pow((s+vec3(1.))*(1.-m.r),vec3(2.)))*(1.-m.r);//c.rgb->z_buffer
}

vec2 randomCoord(vec2 p,float r){
  return p+(random2(gl_FragCoord.xy,ivec2(round(p*resolution)))-vec2(0.5))*30.*r;
}

vec3 getColor(sampler2D t,vec2 p){
  vec4 m=texture2D(material,p);
  vec4 back=texture2D(background,randomCoord(p,m.g));
  return max(surface(texture2D(t,p),back,m),texture2D(light,p).rgb);
}

vec3 onlySurface(vec4 c,vec4 bg,vec4 m){
  return c.rgb*(ambient+GI*(1.-m.b)+bg.rgb*mix(vec3(0.04),c.rgb,m.b));
}

vec3 getDefaultColor(vec4 c,vec4 m,vec2 p,vec2 o,vec2 tFrag){
  return onlySurface(c,texture2D(background,(o*4.*m.g+randomCoord(p,m.g))*tFrag),m);
}

void main(void){
  vec2 pos=gl_FragCoord.xy;
  vec2 tFrag = vec2(1.)/resolution.xy;
  vec4 Back=texture2D(background,pos*tFrag);
  vec4 color=texture2D(primitive,pos*tFrag);
  vec4 Material=texture2D(material,pos*tFrag);
  float Roughness=Material.g;
  vec3 sum=getDefaultColor(color,Material,pos,vec2(0.,2.),tFrag);
  sum+=getDefaultColor(color,Material,pos,vec2(1.732,-1),tFrag);
  sum+=getDefaultColor(color,Material,pos,vec2(-1.732,-1),tFrag);
  sum+=getDefaultColor(color,Material,pos,vec2(0.,-2.),tFrag);
  sum+=getDefaultColor(color,Material,pos,vec2(-1.732,1),tFrag);
  sum+=getDefaultColor(color,Material,pos,vec2(1.732,1),tFrag);
  color=vec4(sum/6.,1.);
  pos+=offset;
  sum = getColor(primitive, pos * tFrag);
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
  gl_FragColor=mix(color,vec4(sum/29.,1.),1.-Material.r);//GI*mix(vec3(0.08), BaseColor, Metallic)
}