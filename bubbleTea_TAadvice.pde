/* From TA:
寫得很好啊 沒什麼可以修的哈
如果真的不想讓code這麼長，可以用物件導向的概念寫，把珍珠寫成另一個class，
然後把會用到的功能都寫成成員函式，像是放大/縮小/位移/變顏色，主程式就可以保留互動的部分
還有x,y和h,w也可以改用PVector宣告，可能看起來會簡潔一點
然後吸過珍珠後，好像滑鼠click的時候就會自動伸長到前一顆珍珠的高度xd
*/
/*
-----Description-----

An Interactive Bubbintea game.(For my mom's appetite :))

Bubbles moving back and forth,
with a random starting position, speed, color for each bubble.

The canvas size is responsive to the browser window size,
while the radius and speed for each bubble are only related to the window size in the beginning.

-----Interaction-----

1) window size: Your tea cup is resizable!!!

2) keyboard: 'z'/ 'x' for the size of the bubbles and the straw.
             UP/ DOWN for the speed of the bubbles.
             
3) mouse: 'Press' for catching bubbles.Catching multiple bubbles at the same time is enabled.
          Once a bubble is catched, the bubble deforms with its color changed.
          'Drag' for moving the catched bubbles around.
          
4) AudioInput: While keeping the mouse pressed,
               make some long sound near your microphone to eat the bubbles!!!
               The Louder, the faster!
*/

import processing.sound.*;
AudioIn in;
Amplitude amp;

PImage img;
java.awt.Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
//thinking about directly using diplayWidth & displayHeight...
int displayWidth = screenSize.height*2/5;
int displayHeight = screenSize.width*2/5;
float w = parseFloat(displayWidth);
float h = parseFloat(displayHeight);
int mx = mouseX;
int my = mouseY;

int num = 15;
float centerX = displayWidth/2;
float centerY = displayHeight/2;
float[] cPosX = new float[num];
float[] cPosY = new float[num];
float[] cSpeed = new float[num];
float[] cEatSpeed = new float[num];
float[] cDirection = new float[num];
float[] rW = new float[num]; //ellipse width/2
float[] rH = new float[num]; //ellipse height/2
float cRadius =  (float)Math.sqrt((w*h)/1280.0/720.0*5000.0);
float cRadiusW = 0.8 * cRadius;
float cRadiusH = 1.25 * cRadius;
float bd = cRadius * 0.5; //boundary for rebounding
color bgColor = (#DB7C70);
color strawColorS = color(200, 210, 215, 120);
color strawColorF = color(200, 210, 215, 70);
color[] cColor = new color[num];

//for mouse events
int[] pickInd = new int[num]; //thinking about if using Vector is better... 
int releaseInd = -1;
boolean isReleasing = false;
boolean isTaking = false;
//for releasing effect
int delay = 0;
int delayFrame = 15;
float loud = 2E-2;

/*void setting(){
  
}*/

void setup(){
  size(displayWidth,displayHeight);//,P3D);
  surface.setResizable(true);
  //img = loadImage("brush_gray.png"); 
  //img.resize(20, 20);
  
  for(int i=0;i<num;i++){
   cPosX[i] = bd + random(0.0, float(displayWidth)-2*bd);
   cPosY[i] = h*0.3 + random(0.0, h-h*0.4);
   cSpeed[i] = (float)Math.sqrt((h*w)/1280/720)*random(7.5, 12.5);
   cEatSpeed[i] = 0;
   cDirection[i] = 1;
   cColor[i] = color(138, 67,
     random(60.0, 100.0), random(120.0, 230.0));
   pickInd[i] = -1;
   rW[i] = cRadius;
   rH[i] = cRadius;
  } 

  // Create an Input stream which is routed into the Amplitude analyzer
  in = new AudioIn(this, 0);
  amp = new Amplitude(this);
  in.start();
  amp.input(in);
}

void draw(){
  //clear();
  //clear everything in the previous frame//not necessary
  background(bgColor);
  // cover the previous circles  
  //println(255 * amp.analyze()*10);
  //println(cRadius*amp.analyze()*10);
  println(amp.analyze());
  cursor(CROSS);
  mx = mouseX;
  my = mouseY;
  fill(strawColorF);
  stroke(strawColorS);
  strokeWeight(10);
  if(isReleasing == false || releaseInd == -1){
    quad(mx-cRadius/2, my, mx+cRadius/2, my-cRadius/2,
      mx+cRadius/2, my-height-10, mx-cRadius/2, my-height-10);
  }
  else{
    if(delay > 0){
      quad(mx-cRadius/2, cPosY[releaseInd], mx+cRadius/2, cPosY[releaseInd]-cRadius/2,
        mx+cRadius/2, my-height-10, mx-cRadius/2, my-height-10);     
      delay--;
    }
    else{
      quad(mx-cRadius/2, my, mx+cRadius/2, my-cRadius/2,
        mx+cRadius/2, my-height-10, mx-cRadius/2, my-height-10);
      isReleasing = false;
      //releaseInd = -1;(??????(Something I'm thinking about...
    }    
  }
  strokeWeight(0);

  for(int i=0;i<num;i++){
    
    fill(cColor[i]);
    stroke(cColor[i]);
    cPosY[i] *= height/h;
    if (isTaking == false){  //else: the catched bubble is deformed 
      rW[i] = cRadius;
      rH[i] = cRadius;
    }
    ellipse(cPosX[i], cPosY[i], rW[i], rH[i]); 
     
    //When a circle is very near to the boundary
    //and the user resize the window between frames,
    //the circle could be stucked.
    //so here we check if the circle happened to be stucked. 
    if(cPosX[i]>= width-bd){
       cSpeed[i] = - abs(cSpeed[i]);
       cPosX[i] += cSpeed[i];
    }
    else if(cPosX[i]<= bd){
       cSpeed[i] = abs(cSpeed[i]);
       cPosX[i] += cSpeed[i];            
    }    
    //check if reversing on the boundary or not
    else if((cPosX[i] + cSpeed[i] * cDirection[i] >= width - bd) || (cPosX[i] + cSpeed[i] * cDirection[i] <= bd)){
      cDirection[i] *= -1.0;
      cPosX[i] += cSpeed[i] * cDirection[i];
    }  
    else{
      cPosX[i] += cSpeed[i] * cDirection[i];
    }
    
    if (isTaking == false || amp.analyze() <  loud){
      cEatSpeed[i] = 0;
    }
    else if(amp.analyze()>loud && pickInd[i] >= 0){
      //cColor[i] = color(200, 100, 100, 255*amp.analyze()*10 + 60);
      cEatSpeed[i] = map(amp.analyze(), 0.0, 1.0, 0.0, 0.3*cRadius);        
    }
    cPosY[i] -= cEatSpeed[i];    
  }
  w = width;
  h = height;
}

void mousePressed(){
  println(mouseX, mouseY);
  isTaking = true;

  for(int i=0; i<num; i++){
    if(dist(mouseX,mouseY,0,cPosX[i],cPosY[i],0) < 0.95 * rW[i]){
      println("Over Ball" + i);
      pickInd[i]= i;
      cSpeed[i] = 0;
      cPosX[pickInd[i]] = mouseX;
      //cPosY[pickInd[i]] = mouseY;
      rW[i] = cRadiusW;
      rH[i] = cRadiusH;
      releaseInd = i;
      cColor[i] = color(235, 200, 199, random(80.0, 240.0));      
    }
  }
}

void mouseDragged(){
  int countY = 0;
  
  //prevent draging the bubbles outside of the cup
  
  //mousrY
  if(mouseY < 5*bd){
    for(int i=0; i<num; i++){
      if(pickInd[i] >= 0){
          cPosY[pickInd[i]] = 5*bd - cRadius * countY;
          countY++;
      }
    }
  }
  else if(mouseY > displayHeight-2*bd){
    for(int i=0; i<num; i++){
      if(pickInd[i] >= 0){
          cPosY[pickInd[i]] = displayHeight -2*bd - cRadius * countY;
          countY++;
      }
    } 
  }
  else{
    if(!(amp.analyze()>loud && isTaking == true)){
      for(int i=0; i<num; i++){
        if(pickInd[i] >= 0 && cPosY[pickInd[i]] > -bd){
            cPosY[pickInd[i]] = mouseY - cRadius * countY;
            countY++;
        }
      }
    }
  }
  
  //mouseX
  if(mouseX > displayWidth-bd){
    for(int i=0; i<num; i++){
        if(pickInd[i] >= 0){
          cPosX[pickInd[i]] = displayWidth-bd;
        }
     }
  }
  else if(mouseX < bd){
    for(int i=0; i<num; i++){
        if(pickInd[i] >= 0){
          cPosX[pickInd[i]] = bd;
        }
     }
  }
  else{
    for(int i=0; i<num; i++){
         if(pickInd[i] >= 0){
          cPosX[pickInd[i]] = mouseX;
        }
     }
  }
}

void mouseReleased(){
  isReleasing = true;  
  isTaking = false;
  delay = delayFrame;
  for(int i=0; i<num; i++){
    if(pickInd[i] >= 0){
      cSpeed[pickInd[i]] = (float)Math.sqrt((h*w)/1280/720)*random(7.5, 9.5);
      pickInd[i] = -1;
      rW[i] = cRadius;
      rH[i] = cRadius;
    }  
  }
}

void keyPressed(){
  println(key);
  if(key == CODED){
    if(keyCode == UP){
      for(int i=0; i<num; i++){
        cSpeed[i]*=1.11;
      }
    }
    else if(keyCode == DOWN){
      for(int i=0; i<num; i++){
        cSpeed[i]*=0.9;
      }      
    }
  }
  else{
    if(key == 'Z' || key == 'z'){
      cRadius *= 1.11;
      cRadiusW *= 1.11;
      cRadiusH *= 1.11;
    }
    else if(key == 'X' || key == 'x'){
      cRadius *= 0.9;
      cRadiusW *= 0.9;
      cRadiusH *= 0.9;
    }
  }
}
