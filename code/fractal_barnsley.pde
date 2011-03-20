import controlP5.*;

ControlP5 controlP5;

Radio ifsRadio;  //Controls which IFS system is being displayed
Knob iterationKnob;  //Controls how many iterations are used to create it

// variables that define the ranges of the points in the IFS
float X_MIN = 0.0;
float X_MAX = 0.0;
float Y_MIN = 0.0;
float Y_MAX = 0.0;

float N  = 50000;  //Start with 50K
float N_MIN = 5000;  //Min its for a discernable figure
float N_MAX = 200000;  //Max its allowed.  This creates a pretty detailed image

ArrayList points;  //These are the infividual points in the IFS
ArrayList patterns; //Ann array of IFS objects representing the different patterns we'll create
IFS currentIFS;  //The current IFS being displayed

boolean update = false;  //Flag if the image needs to be redrawn

// This code makes the fractal by 
void makeIFS(IFS c) {
  float x = 0;
  float y = 0;
  X_MIN = x;
  X_MAX = x;
  Y_MIN = y;
  Y_MAX = y;
  points.clear();  //Reset our array of points
  for (int i = 0; i < N; i++) {
     Transform t = c.selectRandomTransform(); 
     float x1 = t.evalX(x,y);  // Applies the selected transformation to the x-coordinate
     float y1 = t.evalY(x,y);  //Applies the selected transform to the y coordinate
     points.add(new Point(x1,y1));
     x = x1;
     y = y1;
     //Now update the min and max values for x and y
     if (x < X_MIN) {
        X_MIN = x;
     }
     if (x > X_MAX) {
       X_MAX = x;
     }
     if (y < Y_MIN) {
       Y_MIN = y;
     }
     if (y > Y_MAX) {
       Y_MAX = y;
     }
  }
}  
  


void setup() {
   background(255,255,255);
   size (600,600);
   IFS c; //temporary IFS

   points = new ArrayList();
   patterns = new ArrayList();

   // From http://books.google.com/books?id=oh7NoePgmOIC&printsec=frontcover#v=onepage&q&f=false
   c = new IFS("Sierpienski Triangle");
   c.addTransform( new Transform(0.5,0,0,0.5,1,1,0.33));
   c.addTransform( new Transform(0.5,0,0,0.5,1,50,0.33));
   c.addTransform( new Transform(0.5,0,0,0.5,50,50,0.34));
   patterns.add(c);
   
   //From http://en.wikipedia.org/wiki/Barnsley%27s_fern
   c = new IFS("Classic Barnsley Fern");
   c.addTransform( new Transform( 0.0,   0.0,   0.0,  0.16, 0.0, 0.0,  0.01));
   c.addTransform( new Transform( 0.85,  0.04, -0.04, 0.85, 0.0, 1.6,  0.85));
   c.addTransform( new Transform( 0.2,  -0.26,  0.23, 0.22, 0.0, 1.6,  0.07));
   c.addTransform( new Transform(-0.15,  0.28,  0.26, 0.24, 0.0, 0.44, 0.07));
   patterns.add(c);
   
   // From http://commons.wikimedia.org/wiki/File:Barnsley_fern_mutated_-Leptosporangiate_fern.PNG
   c = new IFS("Leptosporangiate Fern");
   c.addTransform( new Transform(0.0, 0.0, 0.0, 0.25, 0.0, -0.14, 0.02));
   c.addTransform( new Transform(0.85, 0.02, -0.02, 0.83, 0.0, 1.0, 0.84 ) );
   c.addTransform( new Transform(0.09,-0.28, 0.3, 0.11, 0.0, 0.6, 0.07));
   c.addTransform( new Transform( -.09, 0.28, 0.3, 0.09, 0.0, 0.7, 0.07)); 
   patterns.add(c);
   // From http://books.google.com/books?id=oh7NoePgmOIC&printsec=frontcover#v=onepage&q&f=false
   c = new IFS("Tree");
   c.addTransform( new Transform( 0.0,   0.0,   0.0,  0.5, 0.0, 0.0,  0.05));
   c.addTransform( new Transform( 0.42,  -0.42, 0.42, 0.42, 0.0, 0.2,  0.4));
   c.addTransform( new Transform( 0.42,  0.42,  -0.42, 0.42, 0.0, 0.2,  0.4));
   c.addTransform( new Transform( 0.1,  0.0,  0.0, 0.1, 0.0, 0.2, 0.15));
   patterns.add(c);
   
   //Create a Dragon  from http://ecademy.agnesscott.edu/~lriddle/ifs/ifs.htm
   c = new IFS ("Dragon");
   c.addTransform( new Transform(0.5, -0.5, 0.5, 0.5, 0.0,0.0,.50));
   c.addTransform( new Transform(-0.5,-0.5,0.5,-0.5,1.0,0.0, 0.50)); 
   patterns.add(c);
   
   //Sierpinski pentagon from http://ecademy.agnesscott.edu/~lriddle/ifs/ifs.htm
   c = new IFS ("Sierpinsk Pentagon");
   c.addTransform( new Transform(0.382,0,0,0.382,0,0,0.2));
   c.addTransform( new Transform(0.382, 0, 0, 0.382, 0.618,0,0.2));
   c.addTransform( new Transform(0.382,0,0,0.382,0.809,0.588,0.2));
   c.addTransform( new Transform(0.382,0,0,0.382,0.309,0.951,0.2));
   c.addTransform( new Transform(0.382,0,0,0.382,-0.191,0.588,0.2));
   patterns.add(c);
   
   //Create a new controlP5 variable to work with
   controlP5 = new ControlP5(this);  //Create a new controlP5 instance variable

   // Draw the first pattern
   currentIFS = (IFS) patterns.get(0);  //Grab the first IFS pattern and make it the current one to display
   update = true;
   makeIFS(currentIFS);
   
   //Setup the knob that controls the iterations
   iterationKnob = controlP5.addKnob("iterationKnob", N_MIN, N_MAX, N, 10,10,50);   
   //Set up the control for the radio buttin to select the fractal
   ifsRadio = controlP5.addRadio("ifsSelect",70,10);
   for (int i=0; i < patterns.size(); i++) {
     IFS p = (IFS) patterns.get(i);
     ifsRadio.add(p.description, i);
   } 
}

//
void ifsSelect(int theID) {
   currentIFS = (IFS) patterns.get(theID);
   makeIFS(currentIFS);
   println(currentIFS.description + " : " + currentIFS.toString());
   update = true;
}

//Controls the number of iterations used in the image
void iterationKnob(int theValue) {
  N = theValue;
  makeIFS(currentIFS);
  update = true;
}
  

void draw() {
  if (update) {
    background (0);
    for (int i = 0; i < points.size(); i++) {
       Point p = (Point) points.get(i);
       set((int) map(p.x,X_MIN,X_MAX, 0, width), (int) map(p.y, Y_MIN, Y_MAX, 0, height),  color(0,255,0));
    }
    update = false;
  }
} 

/*
***************************************************************
Represents a point.  Prety self-explanatory
***************************************************************
*/
class Point {
  float x,y;
  
  Point (float _x, float _y) {
    x = _x;
    y = _y;
  }
  
}

/*
***************************************************************
Handles the math involved in the transforms
***************************************************************
*/
class Transform {
  float a,b,c,d,e,f,p;  // Entries in the matrix to multiply
 
  Transform (float _a, float _b, float _c, float _d, float _e, float _f, float _p) {
     a = _a;
     b = _b;
     c = _c; 
     d = _d;
     e = _e;
     f = _f;
     p = _p;
  }

  
  float evalX(float x, float y) {
     float r = a * x + b * y + e;
     return r;
  }
  
  
    float evalY(float x, float y) {
     float r = c * x + d * y + f;
     return r;
  }

}

/*
***************************************************************
Represents a set of transforms that together make up an IFS
***************************************************************
*/

class IFS {
  
  ArrayList transforms;
  ArrayList hist;  //Used to randomly select a transform based on a frequency distribution
  String description = "";
  
  IFS (String _description) {
    description = _description;
    transforms = new ArrayList();
    hist = new ArrayList();
  }
  
  //Creates a string from the frequency distribution
  String toString() {
    String retVal = "";
    for (int i=0; i < hist.size(); i++) {
      int idx = (Integer) hist.get(i);
      retVal += idx;
    }
    return retVal;
  }
     
    
  //Fills an array with the indexes of the transformation in their proper proportion
  void addHistogram (Transform t) {
     int numToAdd = (int) (t.p * 100);  //Number of elements
     // Adds the index of the current element into the array
     for (int j = 0; j < numToAdd; j++) {
        hist.add (new Integer(transforms.size()-1));
      }
  }
   
  //Adds a new transform rule
  void addTransform (Transform t) {
     transforms.add(t);
     addHistogram(t);
  }
  
  //Returns a randomly selected transform based on the frequencey in the hist structure
  Transform selectRandomTransform() {
     int r = (int) random(hist.size());  // Selects a random transform from the histogram distribution
     int idx = (Integer) hist.get(r);
     return (Transform) transforms.get(idx);
  }
   
}

