// Straus mini-game
// by Alexander Alexeychuk kikudjiro@gmail.com
// 2013-07-17

Maxim maxim;

int _width = 800;
int _height = 480;
int groundHeight =  100;
int horizon = _height - groundHeight;

PImage imgBackSky;

RuinsManager ruins;
CloudsManager clouds;
CarManager car;

AudioPlayer playerSteps;
AudioPlayer playerJump;

int nAnimStraus = 8;
PImage[] animStraus = new PImage[nAnimStraus];
int nStrausHeight = 163;
int iAnimStraus = 0;
boolean jumping = false;
float aStraus = .7;
float vStartStraus = -15;
float vStraus;
float yStrausBase;
float xStraus = 500;
float yStraus;

void setup() {
  frameRate(30);
  size(_width, _height);
  background(#f6b286);
  imgBackSky = loadImage("img/back_sky.png");
  
  maxim = new Maxim(this);
  
  playerJump = maxim.loadFile("jump.wav");
  playerJump.stop();
  playerJump.setLooping(false);

  playerSteps = maxim.loadFile("11-steps.wav", true);
  playerSteps.setLooping(true);
  playerSteps.cue(0);
  playerSteps.speed(3);
  //playerSteps.play();

  ruins = new RuinsManager();
  clouds = new CloudsManager();
  car = new CarManager();
    
  for (int i = 0; i < nAnimStraus; ++i)
    animStraus[i] = loadImage("img/s/st" + (i+1) + ".png");
    
  yStrausBase = _height - nStrausHeight - 20;
  yStraus = yStrausBase;
}
void draw() {
  imageMode(CORNERS);
  
  image(imgBackSky, 0, 0);
  strokeWeight(2);
  fill(#b0b696);
  stroke(#000000);
  rect(-10, horizon, _width + 20, groundHeight + 10);
  
  ruins.draw();
  clouds.draw();
  car.draw();

  if (jumping) {
    yStraus += vStraus;
    vStraus += aStraus;
    if (yStraus > yStrausBase) {
      yStraus = yStrausBase;
      iAnimStraus = 0;
      jumping = false;

      playerJump.stop();
      playerJump.cue(0);

      playerSteps.cue(0);
      playerSteps.speed(3);
      playerSteps.play();

    } else if (yStraus < yStrausBase - 100) {
      iAnimStraus = 4;
    } else {
      iAnimStraus = 6;
    }
  } else {
    if (++iAnimStraus >= /*2 **/ nAnimStraus)
      iAnimStraus = 0;
  }  
  image(animStraus[iAnimStraus], xStraus, yStraus);
  
}
void mouseClicked() {
  if (jumping)
    return;
  jumping = true;
  vStraus = vStartStraus;

  playerSteps.stop();
  playerSteps.cue(0);

  playerJump.cue(0);
  playerJump.play();
  
}


class MovableObject {
  PImage img;
  float x, y;
  float v;
  boolean visible;
  public MovableObject(float v, PImage img) {
    this.img = img;
    visible = false;
    this.v = v;
  }
  public void draw() {
    if (visible) {
      x += v * (jumping ? 1.7 : 1.0);
      if (x > _width)
        visible = false;
      image(img, x, y);
    }    
  }
  public void show() {
    if (visible)
      return;
    visible = true;
    x = - img.width;
  }
}

public class RuinsManager {
  int nRuins = 2;
  float vRuins = 1.5;
  int nextRuinTime = 0;
  Ruin[] ruins = new Ruin[nRuins];
  public RuinsManager() {
    ruins[0] = new Ruin(this, loadImage("img/ruin1.png"), 169, 82);
    ruins[1] = new Ruin(this, loadImage("img/ruin2.png"), 318, 53);
  }
  public void draw() {
    for (int i = 0; i < nRuins; ++i) {
      ruins[i].draw();
    }
    if (nextRuinTime <= 0) {
      for (int i = 0; i < nRuins; ++i) {
        if (!ruins[i].visible) {
          ruins[i].show();
          break;
        }
      }
    } else {
      --nextRuinTime;
    }
  }
}
public class Ruin extends MovableObject {
  RuinsManager manager;
  int width, height;
  public Ruin(RuinsManager manager, PImage img, int width, int height) {
    super(manager.vRuins, img);
    this.width = width;
    this.height = height;
    this.manager = manager;
    y = horizon - this.height + 1;
  }
  public void show() {
    super.show();
    manager.nextRuinTime = (int)(random(this.width + 10, 2 * _width / 3) / manager.vRuins);
  }

}


public class CloudsManager {
  int nClouds = 2;
  float vClouds = 0.8;
  Cloud[] clouds = new Cloud[nClouds];
  int dCloud = 30;
  int cloudWidth = 275;
  int cloudHeight = 49;
  public CloudsManager() {
    int dH = (_height - groundHeight - dCloud * (nClouds+1) - 100) / nClouds;
    for (int i = 0; i < nClouds; ++i) {
      clouds[i] = new Cloud(this, loadImage("img/cloud" + (i+1) + ".png"), dCloud + i * (dH + dCloud), (i + 1) * (dH + dCloud));
      clouds[i].show();
      clouds[i].x = random(0, _width - cloudWidth);
    }
  }
  public void draw() {
    for (int i = 0; i < nClouds; ++i) {
      clouds[i].draw();
    }
  }
}
public class Cloud extends MovableObject {
  int top, bottom;
  int nextTime = -1;
  CloudsManager manager;
  public Cloud(CloudsManager manager, PImage img, int top, int bottom) {
    super(manager.vClouds, img);
    this.manager = manager;
    this.top = top;
    this.bottom = bottom;
    y = horizon - manager.cloudHeight + 1;
  }
  public void show() {
    super.show();
    y = (int)random(top, bottom - manager.cloudHeight);
  }
  public void draw() {
    super.draw();
    if (!visible) {
      if (-1 == nextTime)
        nextTime = (int)(random(10, _width / 3) / manager.vClouds);
      else if (--nextTime <= 0) {
        nextTime = -1;
        show();
      }
    }    
  }

}


public class CarManager {
  float vCar = 4;
  int nextRuinTime = -1;
  Car car;
  public CarManager() {
    car = new Car(this, loadImage("img/car.png"));
  }
  public void draw() {
    car.draw();
    if (!car.visible) {
      if (-1 == nextRuinTime)
        nextRuinTime = (int)(random(2 * _width / 3, 3 * _width / 2) / vCar);
       else if (--nextRuinTime <= 0) {
         nextRuinTime = -1;
         car.show();
       }
    }    
  }
}
public class Car extends MovableObject {
  CarManager manager;
  int carHeight = 65;
  public Car(CarManager manager, PImage img) {
    super(manager.vCar, img);
    this.manager = manager;
    y = _height - carHeight - 20;
  }
  public void show() {
    super.show();
    manager.nextRuinTime = -1;
  }

}



