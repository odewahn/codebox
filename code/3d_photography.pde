PImage left = loadImage("/Users/odewahn/Desktop/flowers_l.png");
PImage right = loadImage("/Users/odewahn/Desktop/flowers_r.png");
String outfile = "/Users/odewahn/Desktop/out.png";

int rx = 0;  // x offest
int ry = 0;  // y offset
int dSize = 10;  // # of pixels to shift
Intersection overlap;

PImage merged;

class Intersection {
  //Defines the overlap reqion
  int w, h; // width and height of overlap 1
  int x, y; // x,y of the top left point of the overlap
  
  // Defines the width and height of the 2 reqions.  They must be of equal size.
  int W, H;  // Width and height of the 2 regions
  int rx, ry;  // x,y position of region
  
  //Defines the mapping of a point p in the overlap into a point in region 1 and region 2
  int eqX1, eqY1;
  int eqX2, eqY2;
  
  //Construct a new region
  Intersection(int _W, int _H) {
    W = _W;
    H = _H;
  }
  
  // Set the offset values of region 2
  void setOffset (int _rx, int _ry) {
    rx = _rx;
    ry = _ry;
    compute();
  }
  
  //Computes the intersection between the two image based on the current offset
  void compute() {
    if (rx < 0) {
       if (ry < 0) {
          // Case A
          w = W + rx;
          h = H + ry;
          x = 0;
          y = 0;
       } else {
          //Case C
          w = W + rx;
          h = H - ry;
          x = 0;
          y = ry;
       }
    } else {
       if (ry < 0) {
          //Case B
          w = W - rx;
          h = H + ry;
          x = rx;
          y = 0;
       } else {
          //Case D
          w = W - rx;
          h = H - ry;
          x = rx;
          y = ry;
       }
    }
  }
  
  //Given a point (x,y) in the intersection, this method finds the correspongin point in the 2 regions
  void findEquivPoint (int x, int y) {
    if (rx < 0) {
       if (ry < 0) {
          // Case A
          eqX1 = x;
          eqY1 = y;
          eqX2 = x - rx;
          eqY2 = y - ry;
       } else {
          //Case C
          eqX1 = x;
          eqY1 = y + ry;
          eqX2 = x - rx;
          eqY2 = y;
       }
    } else {
       if (ry < 0) {
          //Case B
          eqX1 = x + rx;
          eqY1 = y;
          eqX2 = x;
          eqY2 = y - ry;
       } else {
          //Case D
          eqX1 = x + rx;
          eqY1 = y + ry;
          eqX2 = x;
          eqY2 = y;
       }
    }     
  }
}

//Create a merged image
PImage merge() {
  int loc;
  PImage merged = createImage(overlap.w, overlap.h, RGB);
  left.loadPixels();
  right.loadPixels();
  merged.loadPixels();
  //now process the left and right pixels one by one and merge them into a new color
  for (int x = 0; x < overlap.w; x++) {
    for (int y = 0; y < overlap.h; y++) {
      overlap.findEquivPoint(x,y);
      loc = overlap.eqX1 + overlap.eqY1*overlap.W;
      //Pull out RGB for the left image
      float r1 = red(left.pixels[loc]);
      float g1 = green(left.pixels[loc]);
      float b1 = blue(left.pixels[loc]);
      // Pull rgb for the right image
      loc = overlap.eqX2 + overlap.eqY2*overlap.W;
      float r2 = red(right.pixels[loc]);
      float g2 = green(right.pixels[loc]);
      float b2 = blue(right.pixels[loc]);
      //Compute new pixel color in the merged image
      float r = 0.299 * r1 + 0.587 * g1 + 0.114 * b1;
      float g = g2;
      float b = b2;
      //Now set new color
      loc = x + y*merged.width;
      merged.pixels[loc] = color(r,g,b);
    }
  }
  return merged;
}



void setup() {
  size(left.width, left.height);
  overlap = new Intersection(left.width, left.height);
  overlap.setOffset(0,0);
  merged = merge();
}


void keyPressed() {
  switch (key) {
     case 'q':
        ry -= dSize;
        break;
     case 'a':
        ry += dSize;
        break;
     case 'l':
        rx += dSize;
        break;
     case 'k':
        rx -= dSize;
        break;
     case '1':
        dSize = 10;
        break;
     case '2':
        dSize = 1;
        break;
     case 'e':
        merged.save(outfile);
        break;
  }
  overlap.setOffset(rx,ry);
  merged = merge();
}

void draw() {
   background(#ffffff);
   image(merged,0,0);
}  

