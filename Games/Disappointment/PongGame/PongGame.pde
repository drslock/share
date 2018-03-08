import ddf.minim.*;
import processing.serial.*;

Serial arduino;
Minim minim;
AudioPlayer wallSound, batSound, music;
PImage ball, bat, back, bat2, bat3;
int batPosition;
float ballX, ballY;
float vertSpeed, horiSpeed;
int command;
int currentScore = 1;
float batX, batY;

void setup()
{
  size(800,600,P2D);
  connectToArduinoWin();
  imageMode(CENTER);
  textSize(20);
  ball = loadImage("tennisball.png");
  bat = loadImage("raquet.png");
  bat2 = loadImage("raquet1.png");
  bat3 = loadImage("raquet2.png");
  back = loadImage("background.png");
  minim = new Minim(this);
  wallSound = minim.loadFile("wii racket sound.mp3");
  batSound = minim.loadFile("wii racket sound.mp3");
  music = minim.loadFile("Wii Sports Music - Tennis Training.mp3");
  batPosition = bat.width/2;
  resetBall();
  music.play();
}

void resetBall()
{
  ballX = 20;
  ballY = 200;
  vertSpeed = 6;
  horiSpeed = random(-6,6);
}

void draw()
{
  image(back,width/2,height/2,width,height);
  text("Score: " + currentScore, 40, 60);
  updateBatPosition();
  drawBat();
  updateBallPosition();
  drawBall();
  checkForCollision();
}

void updateBatPosition()
{
  if((arduino != null) && (arduino.available()>0)) {
    command = arduino.read();
    if(command == 'z') batPosition = batPosition - 8;
    else if(command == 'x') batPosition = batPosition + 8;
  }
  if(key == 'z') batPosition = batPosition - 8;
  if(key == 'x') batPosition = batPosition + 8;
  if(mousePressed && (mouseX<width/2)) batPosition = batPosition - 8;
  if(mousePressed && (mouseX>width/2)) batPosition = batPosition + 8;

  // Stop the bat from going off the edge of the screen !
  if(batPosition>width) batPosition = width;
  if(batPosition<0) batPosition = 0;
  
  //batX = bat.get(x);
  //batY = bat.get(y);
}

void drawBat()
{
  image(bat,batPosition,height-bat.height);
  
  batX = batPosition;
  batY = height-bat.height;
  
  //if(batPosition > 300) image(bat2, batX, batY);
  
  //if(batPosition > 500) image(bat3, batX, batY);
  //translate(batX, batY);
  //rotate(90);
  //image(bat,batPosition,height-bat.height);
}

void updateBallPosition()
{
  ballX = ballX + horiSpeed;
  ballY = ballY + vertSpeed;
  if(ballY >= height) resetBall();
  if(ballY <= 0) ceilingBounce();
  if(ballX >= width) wallBounce();
  if(ballX <= 0) wallBounce();
}

void wallBounce()
{
  horiSpeed = -horiSpeed;
  wallSound.rewind();
  wallSound.play();
}

void ceilingBounce()
{
  vertSpeed = -vertSpeed;
  wallSound.rewind();
  wallSound.play();
}

void drawBall()
{
  translate(ballX,ballY);
  if(vertSpeed > 0) rotate(-sin(horiSpeed/vertSpeed));
  else rotate(PI-sin(horiSpeed/vertSpeed));
  image(ball,0,0);
}

void checkForCollision()
{
  if(batTouchingBall()) {
    float distFromBatCenter = batPosition-ballX;
    horiSpeed = -distFromBatCenter/10;
    vertSpeed = -vertSpeed;
    ballY = height-(bat.height*2);
    currentScore++;
    batSound.rewind();
    batSound.play();
    vertSpeed--;
    horiSpeed--;
    
  }
}

boolean batTouchingBall()
{
  float distFromBatCenter = batPosition-ballX;
  return (ballY>height-(bat.height*2)) && (ballY<height-(bat.height/2)) && (abs(distFromBatCenter)<bat.width/2);
}
