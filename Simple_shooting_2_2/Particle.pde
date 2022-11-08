class Particle extends Entity{
  ArrayList<particleFragment>particles=new ArrayList<particleFragment>();
  float min=1;
  float max=5;
  float time=0;
  
  Particle(){
    
  }
  
  Particle(Bullet b,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(b.c.getRed(),b.c.getGreen(),b.c.getBlue(),(int)random(16,255));
      particles.add(new LineFragment(b.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle(PVector pos,Color c,int num){
    for(int i=0;i<num;i++){
      float scala=random(0,0.5);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      particles.add(new particleFragment(pos,vec,c,random(min,max)));
    }
  }
  
  Particle(Entity e,String s){
    particles.add(new StringFragment(e.pos,new PVector(0,-1),
                      e instanceof Myself?new Color(255,0,0):new Color(255,255,255),15,s));
  }
  
  Particle(Entity e,int num,float speed){
    for(int i=0;i<num;i++){
      float scala=random(0,speed);
      float rad=random(0,360);
      PVector vec=new PVector(cos(radians(rad))*scala,sin(radians(rad))*scala);
      Color c=new Color(e.c.getRed(),e.c.getGreen(),e.c.getBlue(),(int)random(16,255));
      particles.add(new particleFragment(e.pos,vec,c,random(min,max)));
    }
  }
  
  Particle setSize(float min,float max){
    this.min=min;
    this.max=max;
    for(particleFragment p:particles){
      p.setSize(random(min,max));
    }
    return this;
  }
  
  @Override
  void display(PGraphics g){
    for(particleFragment p:particles){
      p.display(g);
    }
  }
  
  void update(){
    ArrayList<particleFragment>nextParticles=new ArrayList<particleFragment>();
    for(particleFragment p:particles){
      if(p.isDead)continue;
      p.setAlpha(p.alpha-(p instanceof StringFragment?1000f/p.alpha:2)*vectorMagnification);
      p.threadNum=threadNum;
      p.update();
      if(!p.isDead)nextParticles.add(p);
    }
    particles=nextParticles;
    time+=2*vectorMagnification;
    if(time>255){
      isDead=true;
    }
  }
  
  @Override
  void putAABB(){
  }
}

class ExplosionParticle extends Particle{
  PVector pos;
  float nowSize=0;
  float size=0;
  float time=0;
  
  float maxTime=0.4;
  
  ExplosionParticle(Entity e,float size){
    this.pos=e.pos.copy();
    this.size=size;
    c=new Color(255,60,0);
    shape=(g,c,en)->{
      ExplosionParticle p=(ExplosionParticle)en;
      p.nowSize=p.size*(p.time/p.maxTime)*2;
      g.noFill();
      g.stroke(toColor(c));
      g.strokeWeight(1);
      g.ellipse(p.pos.x,p.pos.y,p.nowSize,p.nowSize);
    };
    emission=c;
    setPrimitive(0.8,1,0,6);
  }
  
  ExplosionParticle(Entity e,float size,float time){
    this.pos=e.pos.copy();
    this.size=size;
    c=new Color(255,60,0);
    maxTime=time;
    shape=(g,c,en)->{
      ExplosionParticle p=(ExplosionParticle)en;
      p.nowSize=p.size*(p.time/p.maxTime)*2;
      g.noFill();
      g.stroke(toColor(c));
      g.strokeWeight(1);
      g.ellipse(p.pos.x,p.pos.y,p.nowSize,p.nowSize);
    };
    emission=c;
    setPrimitive(0.8,1,0,6);
  }
  
  @Override
  void display(PGraphics g){
  }
  
  void update(){
    inScreen=-scroll.x<pos.x-size/2&&pos.x+size/2<-scroll.x+width&&-scroll.y<pos.y-size/2&&pos.y+size/2<-scroll.y+height;
    setGeometry();
    time+=0.016*vectorMagnification;
    if(time>=maxTime)isDead=true;
  }
}

class StringFragment extends particleFragment{
  String text="0";
  
  final float diffuse=5.5;
  
  StringFragment(PVector pos,PVector vel,Color c,float size,String s){
    super(pos,vel,c,size);
    this.pos.add(random(-diffuse,diffuse),random(-diffuse,diffuse));
    setText(s);
  }
  
  void setText(String s){
    text=s;
  }
  
  @Override
  void display(PGraphics g){
    g.blendMode(BLEND);
    g.textAlign(CENTER);
    g.textSize(size+1);
    g.fill(128,128,128,c.getAlpha());
    g.text(text,pos.x,pos.y);
    g.textSize(size);
    g.fill(toColor(c));
    g.text(text,pos.x,pos.y);
  }
  
  void update(){
    vel=vel.copy().div(1.1);
    super.update();
  }
}

class LineFragment extends particleFragment{
  
  LineFragment(PVector pos,PVector vel,Color c,float size){
    super(pos,vel,c,size);
    shape=(g,co,e)->{
      g.strokeWeight(1);
      g.stroke(toColor(co));
      g.line(e.pos.x,e.pos.y,e.pos.x+e.vel.x*e.size*3,e.pos.y+e.vel.y*e.size*3);
    };
    primitive.shape=shape;
  }
  
  @Override
  void display(PGraphics g){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
  }
  
  void update(){
    super.update();
  }
}

class particleFragment extends Entity{
  float alpha;
  
  particleFragment(PVector pos,PVector vel,Color c,float size){
    this.pos=pos.copy();
    this.vel=vel.copy();
    this.c=cloneColor(c);
    alpha=c.getAlpha();
    this.size=size;
    shape=(g,co,e)->{
      g.noStroke();
      g.fill(toColor(co));
      g.rectMode(CENTER);
      g.rect(e.pos.x,e.pos.y,e.size,e.size);
    };
    emission=c;
    setPrimitive(0.8,1,0,6);
  }
  
  particleFragment setAlpha(float a){
    alpha=constrain(a,0,255);
    c=new Color(c.getRed(),c.getGreen(),c.getBlue(),round(max(0,alpha)));
    emission=c;
    setPrimitive(0.8,1,0,4);
    return this;
  }
  
  void display(PGraphics g){
    if(!inScreen)return;
    if(alpha<=0){
      isDead=true;
      return;
    }
  }
  
  void update(){
    inScreen=-scroll.x<pos.x-size/2&&pos.x+size/2<-scroll.x+width&&-scroll.y<pos.y-size/2&&pos.y+size/2<-scroll.y+height;
    setGeometry();
    pos.add(vel.copy().mult(vectorMagnification));
  }
}
