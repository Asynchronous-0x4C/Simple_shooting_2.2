class Stage{
  HashMap<String,ArrayList<TimeSchedule>> t;
  ArrayList<SpownPoint>spown;
  HashMap<Enemy,Float>autoEnemy;
  boolean displaySpown;
  boolean endSchedule;
  String name;
  int frag;
  int score;
  float time;
  float freq;
  
  Stage(){
    t=new HashMap<String,ArrayList<TimeSchedule>>();
    spown=new ArrayList<SpownPoint>();
    autoEnemy=new HashMap<Enemy,Float>();
    displaySpown=false;
    endSchedule=false;
    score=0;
    time=0;
    frag=0;
    freq=0;
    name=StageName;
  }
  
  void addProcess(String name,TimeSchedule... t){
    if(this.t.get(name)==null)this.t.put(name,new ArrayList<TimeSchedule>());
    if(t.length==0)return;
    this.t.get(name).addAll(Arrays.asList(t));
    Collections.sort(this.t.get(name),t[0].c);
  }
  
  void addSchedule(String name,TimeSchedule... t){
    if(this.t.containsKey(name))this.t.get(name).addAll(Arrays.asList(t));
    Collections.sort(this.t.get(name),t[0].c);
  }
  
  void addSpown(PVector pos,Enemy e){
    spown.add(new SpownPoint(pos,e));
  }
  
  void addSpown(EnemySpown s,float offset,Enemy e){
    addSpown(s,offset,120,e);
  }
  
  void addSpown(EnemySpown s,float offset,float t,Enemy e){
    int number=0;
    switch(s){
      case Single:spown.add(new SpownPoint(player.pos.copy(),t,e));return;
      case Double:number=2;break;
      case Triangle:number=3;break;
      case Rect:number=4;break;
      case Pentagon:number=5;break;
      case Hexagon:number=6;break;
      case Heptagon:number=7;break;
      case Octagon:number=8;break;
      case Nonagon:number=9;break;
      case Decagon:number=10;break;
    }
    float r=TWO_PI/number;
    try{
      for(int i=0;i<number;i++){
        spown.add(new SpownPoint(player.pos.copy().add(new PVector(e.size*4*cos(r*i+offset+HALF_PI),-e.size*4*sin(r*i+offset+HALF_PI))),t,e.clone()));
      }
    }catch(CloneNotSupportedException f){}
  }
  
  void addSpown(int n,float dist,float offset,Enemy e){
    addSpown(n,dist,offset,120,e);
  }
  
  void addSpown(int n,float dist,float offset,float t,Enemy e){
    float r=TWO_PI/n;
    try{
      for(int i=0;i<n;i++){
        spown.add(new SpownPoint(player.pos.copy().add(new PVector(e.size*4*dist*cos(r*i+offset+HALF_PI),-e.size*4*dist*sin(r*i+offset+HALF_PI))),t,e.clone()));
      }
    }catch(CloneNotSupportedException f){}
  }
  
  void autoSpown(boolean b,float freq,HashMap<Enemy,Float> map){
    this.freq=freq;
    displaySpown=b;
    autoEnemy=map;
  }
  
  void clearSpown(){
    spown.clear();
  }
  
  void display(){
    spown.forEach(s->{s.display();});
  }
  
  void update(){
    spownEnemy();
    scheduleUpdate();
    ArrayList<SpownPoint>nextSpown=new ArrayList<SpownPoint>(spown.size());
    spown.forEach(s->{
      s.update();
      if(!s.isDead)nextSpown.add(s);
    });
    spown=nextSpown;
    time+=vectorMagnification;
  }
  
  void spownEnemy(){
    if(freq!=0&&random(0,1)<freq*vectorMagnification){
      float r=TWO_PI*random(0,1);
      PVector[] v={new PVector(cos(r)*(width+height),sin(r)*(width+height))};
      for(int i=0;i<4;i++){
        PVector p=new PVector();
        switch(i){
          case 0:p=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(width,0),player.pos.copy(),v[0]);break;
          case 1:p=SegmentCrossPoint(scroll.copy().mult(-1).add(0,height),new PVector(width,0),player.pos.copy(),v[0]);break;
          case 2:p=SegmentCrossPoint(scroll.copy().mult(-1),new PVector(0,height),player.pos.copy(),v[0]);break;
          case 3:p=SegmentCrossPoint(scroll.copy().mult(-1).add(width,0),new PVector(0,height),player.pos.copy(),v[0]);break;
        }
        if(p!=null){
          v[0]=p;
          break;
        }
      }
      Enemy[] e={null};
      float rand=random(0,1);
      float[] sum={0};
      autoEnemy.forEach((ene,freq)->{
        try{
          if(sum[0]<=rand&rand<sum[0]+freq){
            e[0]=ene.clone();
            if(displaySpown){
              spown.add(new SpownPoint(v[0].add(cos(r)*e[0].size,sin(r)*e[0].size),e[0]));
            }else{
              NextEntities.add(e[0].setPos(v[0].add(cos(r)*e[0].size,sin(r)*e[0].size)));
            }
          }
          sum[0]+=freq;
        }catch(CloneNotSupportedException f){}
      });
    }
  }
  
  void scheduleUpdate(){
    while(time>t.get(name).get(frag).getTime()*60){
      TimeSchedule T=t.get(name).get(frag);
      if(time>T.getTime()*60){
        T.getProcess().Process(this);
        if(!endSchedule)++frag;
      }
    }
  }
}

class SpownPoint{
  Enemy e;
  boolean inScreen=false;
  boolean isDead=false;
  PVector pos;
  float time;
  
  SpownPoint(PVector pos,Enemy e){
    this.pos=pos;
    time=120;
    this.e=e;
  }
  
  SpownPoint(PVector pos,float time,Enemy e){
    this.pos=pos;
    this.time=time;
    this.e=e;
  }
  
  void display(){
    if(!inScreen)return;
    float t=time%25/25;
    noFill();
    strokeWeight(1);
    stroke((int)(255*t),0,0);
    ellipse(pos.x,pos.y,e.size*t*0.7,e.size*t*0.7);
  }
  
  void update(){
    time-=vectorMagnification;
    if(time<0){
      isDead=true;
      e.init();
      e.setPos(pos);
      NextEntities.add(e);
      return;
    }
    inScreen=-scroll.x<pos.x-e.size*0.35&&pos.x+e.size*0.35<-scroll.x+width&&-scroll.y<pos.y-e.size*0.35&&pos.y+e.size*0.35<-scroll.y+height;
  }
}

class TimeSchedule{
  float time;
  StageProcess p;
  Comparator<TimeSchedule>c;
  
  TimeSchedule(float time,StageProcess p){
    this.time=time;
    this.p=p;
    c=new Comparator<TimeSchedule>(){
      @Override
      public int compare(TimeSchedule T1,TimeSchedule T2){
        Float t1=T1.getTime();
        Float t2=T2.getTime();
        Integer ret=Float.valueOf(t1).compareTo(t2);
        return ret;
      }
    };
  }
  
  float getTime(){
    return time;
  }
  
  StageProcess getProcess(){
    return p;
  }
}

enum EnemySpown{
  Single,
  Double,
  Triangle,
  Rect,
  Pentagon,
  Hexagon,
  Heptagon,
  Octagon,
  Nonagon,
  Decagon
}

interface StageProcess{
  void Process(Stage s);
}
