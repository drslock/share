import ddf.minim.*;
import processing.serial.*;

Serial arduino;
Minim minim;
AudioPlayer wallSound, batSound, ceilingSound;
PImage ball, bat, back;
int batPosition;
float ballX, ballY;
float vertSpeed, horiSpeed;
int command;
int currentScore = 0;
int highScore = 0;

void setup()
{
  size(800,600,P2D);
  connectToArduinoWin();
  imageMode(CENTER);
  textSize(20);
  ball = loadImage("ball.png");
  bat = loadImage("bat.png");
  back = loadImage("back.png");
  minim = new Minim(this);
  wallSound = minim.loadFile("wall.mp3");
  batSound = minim.loadFile("bat.mp3");
  ceilingSound = minim.loadFile("ceiling.mp3");
  batPosition = bat.width/2;
  resetBall();
  fill(0,0,0);
}

void resetBall()
{
  ballX = 20;
  ballY = 200;
  vertSpeed = 6;
  horiSpeed = random(-6,6);
  currentScore = 0;
}

void draw()
{
  image(back,width/2,height/2,width,height);
  text("'Hello there' count: " + currentScore, 10, 20);
  text("Most 'Hello there's ever: " + highScore, 10, 50);
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
  if(key == 'a') batPosition = batPosition - 8;
  if(key == 'd') batPosition = batPosition + 8;
  if(mousePressed && (mouseX<width/2)) batPosition = batPosition - 8;
  if(mousePressed && (mouseX>width/2)) batPosition = batPosition + 8;

  // Stop the bat from going off the edge of the screen !
  if(batPosition>width) batPosition = width;
  if(batPosition<0) batPosition = 0;
}

void drawBat()
{
  image(bat,batPosition,height-bat.height);
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
  ceilingSound.rewind();
  ceilingSound.play();
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
    horiSpeed = -(1.1*distFromBatCenter/10);
    vertSpeed = -(1.1*vertSpeed);
    ballY = height-(bat.height*2);
    batSound.rewind();
    batSound.play();
    currentScore = currentScore + 1;
    if(currentScore > highScore) highScore = currentScore;
  }
}

boolean batTouchingBall()
{
  float distFromBatCenter = batPosition-ballX;
  return (ballY>height-(bat.height*2)) && (ballY<height-(bat.height/2)) && (abs(distFromBatCenter)<bat.width/2);
}