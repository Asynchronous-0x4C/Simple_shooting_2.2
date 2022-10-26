RigidBodyCollision ci_ci=(src,e)->{
  return qDist(src.pos,e.pos,src.r_body.radius+e.r_body.radius);
};

RigidBodyCollision ci_ca=(src,e)->{
  return CircleCollision(src.pos,src.r_body.radius+e.r_body.radius,e.r_body.pos,e.r_body.dist);
};

RigidBodyCollision re_ci=(src,e)->{
  PVector Vec;
  for(int i=0; i<3; i++){
    float L = i%2==0?src.r_body.dist.x/2:src.r_body.dist.y;
    float r=src.r_body.rotate+HALF_PI*i;
    PVector dir=new PVector(L,0).rotate(r).normalize();
    if( L <= 0 ) continue;
    float s = dot(e.pos.copy().sub(src.pos),dir) / L;
    s = abs(s);
    if( s > 1)Vec.add(dir.mult((1-s)*L));
  }
  return Vec.mag()<e.r_body.radius;
};

/*
Circle&Circle:dist x
Circle&Capsule:dist x
Capsule&Capsule:OBB
Rectangle&Circle:OBB x
Rectangle&Capsule:OBB
Rectangle&Rectangle:OBB
*/

interface RigidBodyCollision{
  boolean run(Entity src,Entity e);
}
