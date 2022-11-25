import java.util.concurrent.atomic.AtomicInteger;

import ddf.minim.Minim;
import ddf.minim.AudioPlayer;

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
      }else if(e instanceof Enemy&&!ArchiveEntity.contains(e.getClass().getName())){
        ArchiveEntity.add(e.getClass().getName());
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
      conf.setJSONArray("Enemy",parseJSONArray(Arrays.toString(ArchiveEntity.toArray(new String[0]))));
      saveJSONObject(conf,SavePath+"config.json");
    }
  }
}

class SoundProcess implements Runnable{
  private HashMap<String,AudioPlayer>sounds;
  private HashMap<String,ArrayList<String>>soundData;
  
  private AudioPlayer snd_BGM;
  
  private Minim minim;
  
  private ArrayList<String>schedule;
  
  private float vol_SE=1;
  private float gain_SE=1;
  private float vol_BGM=1;
  private float gain_BGM=1;
  
  private boolean finishLoad=true;
  private boolean loop=true;
  private boolean enableBGM=true;
  private boolean enableSE=true;
  
  SoundProcess(){
    sounds=new HashMap<>();
    soundData=new HashMap<>();
    schedule=new ArrayList<>();
    minim=new Minim(CopyApplet);
    JSONObject data=loadJSONObject(Windows?".\\data\\sound\\config.json":"../data/sound/config.json");
    JSONArray list=data.getJSONArray("state");
    for(int i=0;i<list.size();i++){
      String name=list.getString(i);
      soundData.put(name,new ArrayList<String>(Arrays.asList(data.getJSONArray(name).getStringArray())));
    }
  }
  
  void run(){
    while(loop){
      ArrayList<String>played=new ArrayList<>();
      ArrayList<String>next=new ArrayList<>();
      synchronized(schedule){
        schedule.forEach(s->{
          if(played.contains(s)){
            next.add(s);
          }else{
            sounds.get(s).play();
            sounds.get(s).rewind();
            played.add(s);
          }
        });
        schedule=next;
      }
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
      sounds.put(s.replace(".mp3","").replace(".wav","").replace(".ogg",""),minim.loadFile(Windows?(".\\data\\sound\\"+state+"\\"+s):("../data/sound/"+state+"/"+s)));
    });
    applySEVolume();
    finishLoad=true;
  }
  
  void setSEVolume(float v){
    vol_SE=constrain(v,0,1);
    gain_SE=20*log(vol_SE);
    if(vol_SE>0)applySEVolume();
  }
  
  void applySEVolume(){
    sounds.forEach((k,v)->{
      v.setGain(gain_SE);
    });
  }
  
  int getSEVolume(){
    return round(vol_SE*10);
  }
  
  void setBGMVolume(float v){
    vol_BGM=constrain(v,0,1);
  }
  
  int getBGMVolume(){
    return round(vol_BGM)*10;
  }
  
  void play(String name){
    if(sounds.containsKey(name)&&enableSE&&vol_SE>0)
    synchronized(schedule){
      schedule.add(name);
    }
  }
  
  void stop(){
    sounds.forEach((k,v)->{
      v.pause();
    });
    minim.stop();
  }
  
  boolean finishLoad(){
    return finishLoad;
  }
  
  void end(){
    loop=false;
  }
  
  void disable(){
    enableBGM=enableSE=false;
  }
  
  void disableBGM(){
    enableBGM=false;
  }
  
  void disableSE(){
    enableSE=false;
  }
  
  void enable(){
    enableBGM=enableSE=true;
  }
  
  void enableBGM(){
    enableBGM=true;
  }
  
  void enableSE(){
    enableSE=true;
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
