//The MIT License (MIT)

//Copyright (c) 2013 Alla Hoffman

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;

Physics physics;

CollisionDetector detector;
//sounds - from OpenGameArt.org or Freesound.org
Maxim maxim;
AudioPlayer player;
AudioPlayer coinsound;
AudioPlayer aliensound1;
AudioPlayer aliensound2;
AudioPlayer growl1;
AudioPlayer growl2;
AudioPlayer slurp;
AudioPlayer explosionsound;

Body character;

ArrayList<Body>aliens;
ArrayList<Body>bigbad;
ArrayList<Body>hearts;
ArrayList<Body>coins;
ArrayList<Body>missiles;
ArrayList<Body>shieldfuel;
ArrayList<Vec2>explosions;

//intializing global, gamestate, character variables
boolean left=false;

boolean playing=false;

boolean shieldthere=false;

int deaths=0;
int score=0;
int level=0;
int kills=0;
int bigbadthreshold=10;

int Ballsize=25;
int shieldSize=3*Ballsize;
int alienSize = 23;
int heartSize=13;
int coinSize=10;
int missileSize=3;
int shieldfuelSize=20;
int splashscreenSize=500;
int bigbadSize=100;

int boomSize=128;

int currentPosition=0;

//images from OpenGameArt.org, game-icons.net, and edited or created by me
PImage ghost,background,cowled,coma,alien,heart,coin,boom,missile,splashscreen,battery,bigbaddy;


void setup() {
  size(700,700);
  frameRate(60);
  imageMode(CENTER);
  background=loadImage("space.jpg");
  ghost=loadImage("ghosty.png");
  cowled=loadImage("space-suit.png");
  coma=loadImage("coma.png");
  alien=loadImage("alien-skull.png");
  heart=loadImage("heart.png");
  coin=loadImage("coin.png");
  boom=loadImage("boom3_0.png");
  missile=loadImage("spr_bullet_strip.png");
  splashscreen=loadImage("splashscreen.png");
  battery=loadImage("battery.png");
  bigbaddy=loadImage("bigbad.png");

  
 maxim=new Maxim(this);
 player = maxim.loadFile("space_0.wav");
 //credit Alexandr Zhelanov
 player.setLooping(true);
 player.volume(1);
 
 maxim=new Maxim(this);
 coinsound = maxim.loadFile("coinsound.wav");
 //credit DJ Burnham
 coinsound.setLooping(false);
 coinsound.volume(.7);
 
 maxim=new Maxim(this);
 aliensound1 = maxim.loadFile("cathiss.wav");
 //credit Zabuhailo
 aliensound1.setLooping(false);
 aliensound1.volume(.8);
 
 maxim=new Maxim(this);
 aliensound2 = maxim.loadFile("panhiss.wav");
 //credit Sound Science
 aliensound2.setLooping(false);
 aliensound2.volume(.8);
 
 maxim=new Maxim(this);
 growl1 = maxim.loadFile("growl1.wav");
 //credit ubecareful
 growl1.setLooping(false);
 growl1.volume(.8);
 
 maxim=new Maxim(this);
 growl2 = maxim.loadFile("growl2.wav");
 //credit Nmb910
 growl2.setLooping(false);
 growl2.volume(.8);
 
 maxim=new Maxim(this);
 slurp = maxim.loadFile("slurp.wav");
 //credit Connum
 slurp.setLooping(false);
 slurp.volume(.7);

 maxim=new Maxim(this);
 explosionsound = maxim.loadFile("explosion.wav");
 //credit sarge4267
 explosionsound.setLooping(false);
 explosionsound.volume(.7);
  
  physics = new Physics(this, width, height, 0, 0, width*2, height*2, width, height, 100);
  
  physics.setCustomRenderingMethod(this,"customRenderer");
  physics.removeBorder();
  physics.setDensity(10.0f);
  character=physics.createCircle(27,577,Ballsize);
  
  physics.setDensity(24.0f);
 
 //create aliens, hearts, coins, and an array to put missiles in later 
 aliens = new ArrayList<Body>();
 if(playing==true){
 for(int i=0;i<7;i++){
   aliens.add(physics.createCircle(width/2+random(-alienSize,alienSize),height/2,alienSize));
   }
 } 

 hearts=new ArrayList<Body>();
 if(playing==true){
 for(int i=0;i<3;i++){
   hearts.add(physics.createCircle(width/2+i*random(1,15),height/2+random(-10,10),heartSize));
   }
 }
 
 coins=new ArrayList<Body>();
 if(playing==true){
 for(int i=0;i<5;i++){
   coins.add(physics.createCircle(width/2+coinSize*i/100,height/2,coinSize));
   }
 }
 
 missiles=new ArrayList<Body>();
 explosions=new ArrayList<Vec2>();
 shieldfuel=new ArrayList<Body>();
 bigbad=new ArrayList<Body>();
  
  detector= new CollisionDetector(physics,this);
}

void draw() {
  image(background,width/2,height/2,width,height);
  fill(255);
  
  if(playing==false) {
    image(splashscreen,width/2,height/2,splashscreenSize,splashscreenSize);
  }
  
  if(100+(level*50)>=width-100){
     bigbadSize=width-100;
     }
  
  player.play();
  
  textSize(12);
  text("Damage at "+deaths,20,20);
  text("Score: "+score,width-100,20);
  textSize(20);
  text("Level "+level,width/2,30);
  
  //animation for explosions
  for(int i=0;i<explosions.size();i++){
  frameRate(20);  
  image(boom.get(currentPosition*boomSize,currentPosition*boomSize,boomSize,boomSize),explosions.get(i).x,explosions.get(i).y);
  currentPosition+=1;
  explosions.remove(i);
  explosionsound.play();
  }
  
  if (currentPosition>=7) {
    currentPosition=0;
  }
  
  frameRate(60);
  
  //determine game over
  if (deaths>16) {
    textSize(40);
    text("You're dead! No hope left.",100,height/2);
  }
 
 //respawn hearts, coins, and aliens when they're all gone
 if(playing) {
  if (hearts.size()<1) {
    if(level<10){
   while(hearts.size()<3){
    hearts.add(physics.createCircle(random(heartSize,width-heartSize),random(heartSize,height-heartSize),heartSize)); 
   }
    }
    if(level>=10 &&level<=15){
       while(hearts.size()<2){
    hearts.add(physics.createCircle(random(heartSize,width-heartSize),random(heartSize,height-heartSize),heartSize)); 
   }
    }
    if(level>15){
       while(hearts.size()<1){
    hearts.add(physics.createCircle(random(heartSize,width-heartSize),random(heartSize,height-heartSize),heartSize)); 
   }
    }
   }
  }
 
  if(playing){
  if (coins.size()<1) {
   while(coins.size()<7){
    coins.add(physics.createCircle(random(coinSize,width-coinSize),random(coinSize,height-coinSize),coinSize)); 
   }
   aliens.add(physics.createCircle(random(alienSize,width-alienSize),random(alienSize,height-alienSize),alienSize));
   level+=1;
    }
  }
  
  int respawn_number=level+4;
  if(playing==true) {
  if (aliens.size()<respawn_number){
   while(aliens.size()<4){
    aliens.add(physics.createCircle(random(alienSize,width-alienSize),random(alienSize,height-alienSize),alienSize));
     } 
    }
  }
   
 //wrapping character movement
 Vec2 characterPlace=physics.worldToScreen(character.getPosition());  
 if(characterPlace.x<0){
   character.setPosition(physics.screenToWorld(new Vec2(width-Ballsize,characterPlace.y)));
 }
  if(characterPlace.x>width){
   character.setPosition(physics.screenToWorld(new Vec2(Ballsize,characterPlace.y)));
 }
 if(characterPlace.y<0){
   character.setPosition(physics.screenToWorld(new Vec2(characterPlace.x,height-Ballsize)));
 }
 if(characterPlace.y>height){
   character.setPosition(physics.screenToWorld(new Vec2(characterPlace.x,Ballsize)));
 }
 
 //wrapping alien movement
 for (int i = 0; i < aliens.size(); i++) {
 Vec2 aliensPlace=physics.worldToScreen(aliens.get(i).getPosition());
 
 if(aliensPlace.x<0){
   aliens.get(i).setPosition(physics.screenToWorld(new Vec2(width-Ballsize,aliensPlace.y)));
 }
  if(aliensPlace.x>width){
   aliens.get(i).setPosition(physics.screenToWorld(new Vec2(Ballsize,aliensPlace.y)));
 }
 if(aliensPlace.y<0){
   aliens.get(i).setPosition(physics.screenToWorld(new Vec2(aliensPlace.x,height-Ballsize)));
 }
 if(aliensPlace.y>height){
   aliens.get(i).setPosition(physics.screenToWorld(new Vec2(aliensPlace.x,Ballsize)));
 }
 } 
 
 //wrapping heart movement
 for (int i = 0; i < hearts.size(); i++) {
 Vec2 heartsPlace=physics.worldToScreen(hearts.get(i).getPosition());
 
 if(heartsPlace.x<0){
  hearts.get(i).setPosition(physics.screenToWorld(new Vec2(width-Ballsize,heartsPlace.y)));
 }
  if(heartsPlace.x>width){
   hearts.get(i).setPosition(physics.screenToWorld(new Vec2(Ballsize,heartsPlace.y)));
 }
 if(heartsPlace.y<0){
   hearts.get(i).setPosition(physics.screenToWorld(new Vec2(heartsPlace.x,height-Ballsize)));
 }
 if(heartsPlace.y>height){
   hearts.get(i).setPosition(physics.screenToWorld(new Vec2(heartsPlace.x,Ballsize)));
 }
 }

//wrapping coin movmeent
 for (int i = 0; i < coins.size(); i++) {
 Vec2 coinsPlace=physics.worldToScreen(coins.get(i).getPosition());
 
 if(coinsPlace.x<0){
  coins.get(i).setPosition(physics.screenToWorld(new Vec2(width-coinSize,coinsPlace.y)));
 }
  if(coinsPlace.x>width){
   coins.get(i).setPosition(physics.screenToWorld(new Vec2(coinSize,coinsPlace.y)));
 }
 if(coinsPlace.y<0){
   coins.get(i).setPosition(physics.screenToWorld(new Vec2(coinsPlace.x,height-coinSize)));
 }
 if(coinsPlace.y>height){
   coins.get(i).setPosition(physics.screenToWorld(new Vec2(coinsPlace.x,coinSize)));
 }
 }
 
 //wrapping shieldfuel movmeent
 for (int i = 0; i < shieldfuel.size(); i++) {
 Vec2 shieldfuelPlace=physics.worldToScreen(shieldfuel.get(i).getPosition());
 
 if(shieldfuelPlace.x<0){
  shieldfuel.get(i).setPosition(physics.screenToWorld(new Vec2(width-shieldfuelSize,shieldfuelPlace.y)));
 }
  if(shieldfuelPlace.x>width){
   shieldfuel.get(i).setPosition(physics.screenToWorld(new Vec2(shieldfuelSize,shieldfuelPlace.y)));
 }
 if(shieldfuelPlace.y<0){
   shieldfuel.get(i).setPosition(physics.screenToWorld(new Vec2(shieldfuelPlace.x,height-shieldfuelSize)));
 }
 if(shieldfuelPlace.y>height){
   shieldfuel.get(i).setPosition(physics.screenToWorld(new Vec2(shieldfuelPlace.x,shieldfuelSize)));
   }
 }
 
 //making missiles fire once created
 for(int i=0; i<missiles.size();i++) {
   if(left==false){
   Vec2 impulse=new Vec2(.2,0);
   missiles.get(i).applyImpulse(impulse,missiles.get(i).getWorldCenter());
 }
   else if(left==true){
     Vec2 impulse=new Vec2(-.2,0);
     missiles.get(i).applyImpulse(impulse,missiles.get(i).getWorldCenter());
   }
 }
 
 //killing missiles when they go offscreen
 if(missiles.size()>0){
 for (int i=0;i<missiles.size();i++) {
   Vec2 missilesPlace=physics.worldToScreen(missiles.get(i).getPosition());   
   if(missilesPlace.x<0 || missilesPlace.x>width) {
     missiles.remove(i);
   }
   else if(missilesPlace.y<0 ||missilesPlace.y>height) {
   missiles.remove(i);
     }
   }
 }
 
 //creates shield-fuel, bigbad once the player has killed a certain number of aliens
 if(kills>bigbadthreshold) {
    while(bigbad.size()<1){
      bigbad.add(physics.createCircle(random(bigbadSize,width-bigbadSize),0,bigbadSize));
    }
    bigbadthreshold=kills+5;
   while(shieldfuel.size()<1){
   shieldfuel.add(physics.createCircle(random(shieldfuelSize,width-shieldfuelSize),random(shieldfuelSize,height-shieldfuelSize),shieldfuelSize));
   }
 }
 
 //moving the bigbad
 for(int i=0; i<bigbad.size();i++) {
   Vec2 impulse=new Vec2(random(-.05,.05),-.08);
   bigbad.get(i).applyImpulse(impulse,bigbad.get(i).getWorldCenter());
   }
   
 //killing the bigbad when it goes offscreen
 if(bigbad.size()>0){
 for (int i=0;i<bigbad.size();i++) {
   Vec2 bigbadPlace=physics.worldToScreen(bigbad.get(i).getPosition());   
   if(bigbadPlace.x+bigbadSize<0 || bigbadPlace.x-bigbadSize>width) {
     bigbad.remove(i);
   }
    if(bigbadPlace.y-bigbadSize>height) {
   bigbad.remove(i);
     }
   }
 }
 
}

void customRenderer(World world) {
 stroke(0);

//character render
Vec2 screenCharacterPos=physics.worldToScreen(character.getWorldCenter());
float characterAngle=physics.getAngle(character);
pushMatrix();
translate(screenCharacterPos.x,screenCharacterPos.y);
fill(255);
if(left==true){
  scale(-1,1);
}
if(deaths>=15){
image(ghost,0,0,Ballsize*2,Ballsize*2);
}
if(deaths>=10 && deaths<15){
  image(coma,0,0,Ballsize*2,Ballsize*2);
}
if(deaths<10){
  image(cowled,0,0,Ballsize*2,Ballsize*2);
}

//shows shield, if there
if(shieldthere==true){
    fill(0,0,200,8);
    stroke(0, 0, 190);
    ellipse(0,0,shieldSize,shieldSize);
  }
popMatrix();

//alien render
 for (int i = 0; i < aliens.size(); i++)
  {
    Vec2 worldCenter = aliens.get(i).getWorldCenter();
    Vec2 alienPos = physics.worldToScreen(worldCenter);
    pushMatrix();
    translate(alienPos.x, alienPos.y);
    image(alien,0, 0, alienSize*2, alienSize*2);
    popMatrix();
  }
  
//hearts render
for (int i = 0; i < hearts.size(); i++)
  { 
    Vec2 worldCenter = hearts.get(i).getWorldCenter();
    Vec2 heartPos = physics.worldToScreen(worldCenter);
    float heartAngle = physics.getAngle(hearts.get(i));
    pushMatrix();
    translate(heartPos.x, heartPos.y);
    rotate(-heartAngle);
    image(heart,0, 0, heartSize*2, heartSize*2);
    popMatrix();
  }
  
//coins render  
  for (int i = 0; i < coins.size(); i++)
  { 
    Vec2 worldCenter = coins.get(i).getWorldCenter();
    Vec2 coinPos = physics.worldToScreen(worldCenter);
    float coinAngle = physics.getAngle(coins.get(i));
    pushMatrix();
    translate(coinPos.x, coinPos.y);
    rotate(-coinAngle);
    image(coin,0, 0, coinSize*2, coinSize*2);
    popMatrix();
  }
  
  //missile render
  for (int i = 0; i < missiles.size(); i++)
  { 
    Vec2 worldCenter = missiles.get(i).getWorldCenter();
    Vec2 missilePos = physics.worldToScreen(worldCenter);
    float missileAngle = physics.getAngle(missiles.get(i));
    pushMatrix();
    translate(missilePos.x, missilePos.y);
    rotate(-missileAngle);
    fill(122);
    image(missile.get(20,20,39,39),0, 0, missileSize*5, missileSize*5);
    popMatrix();
  }
  
  //shieldfuel render 
 for (int i = 0; i < shieldfuel.size(); i++)
  { 
    Vec2 worldCenter = shieldfuel.get(i).getWorldCenter();
    Vec2 shieldfuelPos = physics.worldToScreen(worldCenter);
    float shieldfuelAngle = physics.getAngle(shieldfuel.get(i));
    pushMatrix();
    translate(shieldfuelPos.x, shieldfuelPos.y);
    rotate(-shieldfuelAngle);
    image(battery,0,0, shieldfuelSize, shieldfuelSize);
    popMatrix();
  }
  
  //bigbad render
  for (int i = 0; i < bigbad.size(); i++)
  { 
    Vec2 worldCenter = bigbad.get(i).getWorldCenter();
    Vec2 bigbadPos = physics.worldToScreen(worldCenter);
    float bigbadAngle = physics.getAngle(bigbad.get(i));
    pushMatrix();
    translate(bigbadPos.x, bigbadPos.y);
    rotate(-bigbadAngle);
    image(bigbaddy,0, 0, bigbadSize*2, bigbadSize*2);
    popMatrix();
  }
}

void keyPressed(){
 //gets rid of splashscreen when you start the game
  if(playing==false){
   playing=true; 
  }
  
//deals with character movement
Vec2 move=new Vec2();
Vec2 bee=character.getPosition();
if(key==CODED) {
  if (keyCode==RIGHT) {
  move.x=200;
  left=false;
  
  }
  if(keyCode==LEFT) {
   move.x=-200;
   left=true;

  }
  if(keyCode==UP) {
  move.y=200; 
  }
  if(keyCode==DOWN) {
    move.y=-200;
  }
 //fires missiles
  if(keyCode==SHIFT) {
    if(missiles.size()<1){
    Vec2 place=physics.worldToScreen(character.getPosition());
    missiles.add(physics.createCircle(place.x+Ballsize,place.y+Ballsize,missileSize));
    }
  }
}
character.applyForce(move,character.getPosition());
} 



void collision(Body b1,Body b2,float impulse) {
  
//deals with alien-character collisions (damage, sound, alien movement), and gets rid of the shield once it collides with an alien
  for (int i=0;i<aliens.size();i++){
    if(b1==aliens.get(i) && b2==character && deaths<=16 ||b2==aliens.get(i) && b1==character && deaths<=16){
     if(shieldthere==false){
     deaths+=1;}
     if(shieldthere==true){
       shieldthere=false;
     }
     
     Vec2 impulsed=new Vec2(random(-20,20),random(-20,20));
     aliens.get(i).applyImpulse(impulsed,aliens.get(i).getWorldCenter());
     int sound=(int)random(4);
     if(sound==0) {
       aliensound1.speed(impulse);
       aliensound1.play();
     }
     else if(sound==1) {
       aliensound2.speed(impulse);
       aliensound2.play();
     }
     else if(sound==2) {
       growl1.speed(impulse);
       growl1.play();
     }
     else if(sound==3) {
       growl2.speed(impulse);
       growl2.play();
     }
     }
   }
   
//deals with heart-character collisions   
   for (int i=0;i<hearts.size();i++){
    if(b1==hearts.get(i) && b2==character && deaths<=16 ||b2==hearts.get(i) && b1==character && deaths<=16){
     if(deaths>0){deaths-=1;}
     hearts.remove(i);
     slurp.speed(impulse);
     slurp.play();
     }
   }
   
//deals with shieldfuel-character collisions, triggers shield creation   
   for (int i=0;i<shieldfuel.size();i++){
    if(b1==shieldfuel.get(i) && b2==character && deaths<=16 ||b2==shieldfuel.get(i) && b1==character && deaths<=16){
     shieldfuel.remove(i);
     if(shieldthere==false){
     shieldthere=true;
       }
     }
   }
   
//deals with bigbad-character collisions, shield, coin, and heart destruction   
   for (int i=0;i<bigbad.size();i++){
    if(b1==bigbad.get(i) && deaths<=16 ||b2==bigbad.get(i) && deaths<=16){
       if(b1==character||b2==character){
         if(shieldthere==false){
         deaths+=5;}
         else if(shieldthere==true){
         shieldthere=false;}
         } 
     for(int p=0;p<hearts.size();p++) {
        if (b1==hearts.get(p) ||b2==hearts.get(p)){
         hearts.remove(p);
         }
        }
    for(int q=0;q<coins.size();q++) {
        if (b1==coins.get(q) ||b2==coins.get(q)){
         coins.remove(q);
         }
        }
    }
   }
   
//deals with coin-character collisions   
for (int i=0;i<coins.size();i++){
    if(b1==coins.get(i) && b2==character && deaths<16 ||b2==coins.get(i) && b1==character && deaths<16){
     score+=1;
     coins.remove(i);
     coinsound.play();
     }
   }

//deals with missile-alien collisions   
for (int i=0;i<missiles.size();i++){
    if(b1==missiles.get(i) && deaths<25||b2==missiles.get(i) && deaths<25) {
      for (int p=0;p<aliens.size();p++) {
        if (b1==aliens.get(p) ||b2==aliens.get(p)){
     explosions.add(physics.worldToScreen(aliens.get(p).getPosition())); 
     missiles.remove(i);
     aliens.remove(p);
     kills+=1;
    //grows the bigbad with each level you gain 
     if (level*50+100<width-100){
      bigbadSize=100+(level*10);
      }
       }
     }
   }
   
   }
 }

 
  
