import java.util.concurrent.atomic.AtomicInteger;

import processing.sound.*;

class EntityProcess implements Callable<String>{
  long pTime=0;
  byte number;
  int s;
  int l;
  
  EntityProcess(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
  
  String call(){
    pTime=System.nanoTime();
    ArrayList<Entity>next=HeapEntity.get(number);
    for(int i=s;i<l;i++){
      Entity e=Entities.get(i);
      e.threadNum=number;
      if(player.isDead){
        if((e instanceof Explosion)||(e instanceof Particle)){
          e.update();
        }else{
          e.putAABB();
        }
      }else{
        e.update();
      }
      if(!e.isDead){
        next.add(e);
      }
    }
    EntityTime=(System.nanoTime()-pTime)/1000000f;
    return "";
  }
  
  void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
  }
}

class EntityCollision implements Callable<String>{
  TreeMap<Float,Enemy>overEntity;
  float hue;
  byte number;
  int s;
  int l;
  
  EntityCollision(int s,int l,byte num){
    this.s=s;
    this.l=l;
    hue=s==0?0:255*(s/(float)EntityDataX.size());
    number=num;
  }
  
  String call(){
    for(int i=s;i<l;i++){
      Entity E=SortedDataX[i].getEntity();
      if((E instanceof Enemy)&&Debug)((Enemy)E).hue=hue;
      switch(SortedDataX[i].getType()){
        case "s":Collision(E,i);break;
        case "e":break;
      }
    }
    return "";
  }
  
  void Collision(Entity E,int i){
    ++i;
    for(int j=i,s=EntityDataX.size();j<s;j++){
      Entity e=SortedDataX[j].getEntity();
      if(E==e)break;
      if(SortedDataX[j].getType().equals("e")){
        continue;
      }
      if(abs(e.Center.y-E.Center.y)<=(e.AxisSize.y+E.AxisSize.y)*0.5){
        E.Collision(e);
      }
    }
  }
  
  void setData(int s,int l,byte num){
    this.s=s;
    this.l=l;
    number=num;
    hue=s==0?0:255*(s/(float)EntityDataX.size());
  }
}

class EntityDraw implements Callable<PGraphics>{
  PGraphics g;
  int s;
  int l;
  
  EntityDraw(int s,int l){
    this.s=s;
    this.l=l;
    this.g=createGraphics(width,height);
  }
  
  PGraphics call(){
    g.beginDraw();
    g.translate(scroll.x,scroll.y);
    g.background(0,0);
    for(int i=s;i<l;i++){
      Entities.get(i).display(g);
    }
    g.endDraw();
    return g;
  }
  
  void setData(int s,int l){
    this.s=s;
    this.l=l;
  }
}

class saveConfig implements Runnable{
  
  void run(){
    if(!StageFlag.contains("Game_Over")){
      conf.setJSONArray("Stage",parseJSONArray(Arrays.toString(stageList.Contents.toArray(new String[0]))));
      saveJSONObject(conf,SavePath+"config.json");
    }
  }
}

class SoundProcess implements Runnable{
  private HashMap<String,SoundFile>sounds;
  private HashMap<String,ArrayList<String>>soundData;
  
  private HashSet<String>schedule;
  
  private boolean finishLoad=true;
  private boolean loop=true;
  private boolean enable=true;
  
  SoundProcess(){
    sounds=new HashMap<>();
    soundData=new HashMap<>();
    schedule=new HashSet<>();
    JSONObject data=loadJSONObject(Windows?".\\data\\sound\\config.json":"../data/sound/config.json");
    JSONArray list=data.getJSONArray("state");
    for(int i=0;i<list.size();i++){
      String name=list.getString(i);
      soundData.put(name,new ArrayList<String>(Arrays.asList(data.getJSONArray(name).getStringArray())));
    }
  }
  
  void run(){
    while(loop){
      schedule.forEach(s->{
        sounds.get(s).play();
      });
      schedule.clear();
      try{
        Thread.sleep(8);
      }catch(InterruptedException e){
        e.printStackTrace();
      }
    }
  }
  
  void loadData(String state){
    finishLoad=false;
    if(!soundData.containsKey(state)){
      finishLoad=true;
      return;
    }
    sounds.clear();
    soundData.get(state).forEach(s->{
      sounds.put(s.replace(".mp3","").replace(".wav","").replace(".ogg",""),new SoundFile(CopyApplet,Windows?(".\\data\\sound\\"+state+"\\"+s):("../data/sound/"+state+"/"+s)));
    });
    finishLoad=true;
  }
  
  void play(String name){
    if(sounds.containsKey(name)&&enable)schedule.add(name);
  }
  
  void stop(){
    sounds.forEach((k,v)->{
      v.stop();
    });
  }
  
  boolean finishLoad(){
    return finishLoad;
  }
  
  void end(){
    loop=false;
  }
  
  void disable(){
    enable=false;
  }
  
  void enable(){
    enable=true;
  }
}

class CollisionData{
  byte number;
  byte end;
  Entity e;
  CollisionData(Entity e,byte num){
    number=num;
    this.e=e;
  }
  
  Entity getEntity(){
    return e;
  }
  
  byte getNumber(){
    return number;
  }
  
  void setEnd(byte b){
    end=b;
  }
  
  byte getEnd(){
    return end;
  }
  
  @Override
  String toString(){
    return number+":"+e;
  }
}

class AABBData{
  private float pos;
  private String type="";
  private Entity e;
  
  AABBData(float pos,String type,Entity e){
    this.pos=pos;
    this.type=type;
    this.e=e;
  }
  
  final float getPos(){
    return pos;
  }
  
  final String getType(){
    return type;
  }
  
  final Entity getEntity(){
    return e;
  }
}
