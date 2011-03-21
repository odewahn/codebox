import processing.video.*;

Capture cam;

PFont font;

// Variables to determine the size of the box used to acquire a target
int colorDist = 50;  //Controls how close the current pixel color must match to the target color
color targetColor =  color(255,255,255);   //Color of the target
boolean acquireMode = true;
int targetX = 10;
int targetY = 25;
int targetSide = 10;

//Used to find the geometric center of the target based on an average
float wandX = 0;
float wandY = 0;
boolean wandFound = false;

ArrayList targets;  //an ArrayList is a  dynamic way to manage arrays
int N = 5;  //Number of targets to keep on the screen at any given time

void setup() {
  size (640, 480); //set to 4x3 aspect ratio for screencasting
  cam = new Capture(this, width, height);
  frameRate(60);
  font = loadFont("Baskerville-Bold-48.vlw"); //Be sure to create the font using "Tools -> Create Font"
  targets = new ArrayList();  // Create a new list 
  for (int i=0; i < N; i++) {
    targets.add(new Target("Hat", "Rabbit"));
  }
  
}

void draw() {
  if (cam.available()) {
    cam.read(); 
    image(cam,0,0);
  }
  if(acquireMode) {
    //Display the current target color
    strokeWeight(1);
    fill(targetColor);
    rect(targetX,targetY - 2 * targetSide,targetSide, targetSide);     
    //Display the acquisition box 
    fill(color(255,255,255));
    rect(targetX,targetY,targetSide, targetSide);
    textSize(10);
    text("Place target in square and press any key when done.", targetX + 1.5 * targetSide,targetY + targetSide);
    // Set a new random color gradient      
    targetColor = acquireTargetColor();
  } 
  else {
    searchForTargetColor();
    //Process the list of targets
    fill(255,0,0);
    ellipse(wandX,wandY,10,10);
    for  (int i=0; i < targets.size(); i++) {
       Target t = (Target) targets.get(i); //Fetch the i'th target from the Array
       t.paint();  // Paint it
       //Check for collisions
       if (t.detectCollision(wandX, wandY)) {
          if (! t.inTarget) {
             t.toggle();
             t.inTarget = true;
          }
       } else {
         t.inTarget = false;
       }
       t.step(); // Advance it on the screen
       //If the current target has moved off the stage, delete it from the list and create a new target
       if (!t.onStage()) {
          targets.remove(i);
          targets.add(new Target("Hat", "Rabbit"));
       }     
    }
  }
}



// Finds the average target color that has been placed in the target box
// Loops through each pixel in the target acquisition area and determines 
// the "average" color
color acquireTargetColor() {
  int r = 0;
  int g = 0;
  int b = 0;
  int cnt = 0;
  cam.loadPixels();
  for (int i = 0; i < targetSide; i++) {
    for (int j=0; j < targetSide; j++) {
      cnt += 1;
      int x = targetX + i;  //x point inside the target box
      int y = targetY + j;  //y point inside the target box
      // Pull out the current pixel color
      color c = cam.pixels[y*width + x];
      r += red(c);
      g += green(c);
      b += blue(c);
    }
  }
  targetColor = color(r/cnt, g/cnt, b/cnt);
  return targetColor;
}

//Searches for the target color.  Searches each pixel in the entire image
// and compares it to the target color.  If the distance is less than the 
// threshold colorDist, it's assummed to be a match
void searchForTargetColor() {
  // Reset wand
  wandX = 0;
  wandY = 0;
  wandFound = false;
  cam.updatePixels();
  //Now search for pixels that match the target color
  int numPoints = 0;  //Number of points found
  int sx = 0;  //Sum of all x coordinates found
  int sy = 0;  //Sum of all the y coordinates found
  for (int i=0; i < width; i++) {
    for (int j=0; j < height; j++) {
      color pix = cam.pixels[j*width + i]; //Grab pixel at i,j
      float dr = red(targetColor) - red(pix);
      float dg = green(targetColor) - green(pix);
      float db = blue(targetColor) - blue(pix);
      float d = sqrt ( pow(dr,2) + pow(dg,2) + pow(db,2));
      // If it's a match, then keep a running total
      if (d < colorDist) {
        numPoints += 1;
        sx += i;
        sy += j;
      }
    }
  }
  // If we found the target color, set the wand coordinates
  if (numPoints > 0) {
    wandX = sx / numPoints;
    wandY = sy / numPoints;
    wandFound = true;
  }
}


//Toggle the acquire mode
void keyPressed() {
  acquireMode = !acquireMode;
}


class Target {
  
  float x, y, dx, dy;
  float w, h;  //Width and height of the box
  Boolean inTarget = false;
  int fontSize = 48;
  String currentText, beforeText, afterText;
  
  // Constructor -- called when the object is created with "new"
  Target(String _beforeText, String _afterText) { 
     beforeText = _beforeText;
     afterText = _afterText;
     currentText = _beforeText;
     x = random(0,width);
     y = random(0,height);
     dx = random(-5,5);
     dy = random(-5,5);
     setBox();
  }
  
  //Advances the object to a new position
  // This is discussed in Chapter 7
  void step() {
    x += dx;
    y += dy;
  }
  
  //Determines if the object is still on the stage
  Boolean onStage() {
    Boolean retVal = false;
    if (((x+w) > 0) && (x < width) && (y > 0) && ((y-h) < height)) {
        retVal = true;
    }
    return retVal;
  }
  
  //Sete the height and width of the bounding text box
  void setBox() {
     h = fontSize;
     textFont(font, fontSize);
     w = textWidth(currentText);
  }
  
  //Determines is a particular x,y coordinate is within the box
  boolean detectCollision(float cx, float cy) {
     boolean retVal = false;
     if ( (cx > x) && (cx < (x+w)) && (cy > (y-h)) && (cy < y)) {
        retVal= true;
     }
     return retVal;
  }
  
  //Toggles the state of the 
  void toggle() {
     if (currentText == beforeText) {
        currentText = afterText;
     } else {
       currentText = beforeText;
     }
     setBox();
  }
  
  //Displays the text at x,y
  void paint() {
    fill(255);
    textFont(font,fontSize);
    textSize(fontSize);
    text(currentText,x,y);
  }
    
  
}