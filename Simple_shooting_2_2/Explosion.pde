class Explosion extends Entity{
  ExplosionParticle p;
  HashSet<Entity>HitEnemy;
  boolean myself=false;
  boolean inf=false;
  float power=10;
  
  {
    HitEnemy=new HashSet<Entity>();
  }
  
  Explosion(Entity e,float size){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size);
    HeapEntity.get(threadNum).add(p);
    myself=e instanceof Myself;
  }
  
  Explosion(Entity e,float size,float time){
    pos=e.pos.copy();
    this.size=0;
    p=new ExplosionParticle(e,size,time);
    HeapEntity.get(threadNum).add(p);
    myself=e instanceof Myself;
  }
  
  Explosion(Entity e,float size,float time,float power){
    pos=e.pos.copy();
    this.size=0;
    this.power=power;
    p=new ExplosionParticle(e,size,time);
    HeapEntity.get(threadNum).add(p);
    myself=e instanceof Myself;
  }
  
  Explosion Infinity(boolean inf){
    this.inf=inf;
    return this;
  }
  
  void display(PGraphics g){
    if(Debug){
      displayAABB(g);
    }
  }
  
  void update(){
    size=p.nowSize;
    isDead=p.isDead;
    Center=pos;
    AxisSize=new PVector(size,size);
    putOnlyAABB();
  }
  
  @Override
  public void Collision(Entity e){
    if(e instanceof Explosion){
      ExplosionCollision((Explosion)e);
    }else if(e instanceof Enemy){
      EnemyCollision((Enemy)e);
    }else if(e instanceof Bullet){
      BulletCollision((Bullet)e);
    }else if(e instanceof Myself){
      MyselfCollision((Myself)e);
    }else if(e instanceof WallEntity){
      WallCollision((WallEntity)e);
    }
  }
  
  @Override
  void ExplosionCollision(Explosion e){}
  
  @Override
  void EnemyCollision(Enemy e){
    if(qDist(pos,e.pos,(size+e.size)*0.5)){
      EnemyHit(e,false);
    }
  }
  
  @Override
  void EnemyHit(Enemy e,boolean b){
    if(!HitEnemy.contains(e)){
      HitEnemy.add(e);
      e.ExplosionHit(this,true);
    }
  }
  
  @Override
  void BulletCollision(Bullet b){
    b.ExplosionHit(this,true);
  }
  
  @Override
  void MyselfCollision(Myself m){
    m.ExplosionHit(this,true);
  }
  
  void Hit(Weapon w){
    return;
  }
  
  void Down(){
    isDead=false;
  }
}

class BulletExplosion extends Explosion{
  Weapon parent;
  
  BulletExplosion(Entity e,float size,float time,boolean my,Weapon w){
    super(e,size,time);
    myself=my;
    parent=w;
  }
  
  @Override
  void EnemyHit(Enemy e,boolean b){
    ((Enemy)e).Hit(parent);
  }
}

void addExplosion(Entity e,float size){
  HeapEntity.get(0).add(new Explosion(e,size));
}

void addExplosion(Entity e,float size,float time){
  HeapEntity.get(0).add(new Explosion(e,size,time));
}
