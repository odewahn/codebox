PImage pic = loadImage("/Users/odewahn/Desktop/hydrant_r.png");


// Create filter here
float mat[][] = {
  {0.0, 0.0, 0.0},
  {0.0,1.0,0.0},
  {0.0, 0.0, 1.0} 
};

//Applies the passed filter to the image and returns a new image
PImage filter(PImage img, float[][] filter) {
  int loc;
  PImage retVal = createImage(img.width, img.height, RGB);
  img.loadPixels();  //Required to read and write the pixels
  retVal.loadPixels();  // Required to read and write pixels
  //Process the pixels in img, apply filter, and then create a new pixel in retVal
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      loc = x + y*img.width; //Convert the (x,y) coordinate into a position in the array
      //Pull out RGB for the left image
      float[] pix = new float[3];  // Create a 3x1  matrix of pixels
      pix[0] = red(img.pixels[loc]);
      pix[1] = green(img.pixels[loc]);
      pix[2] = blue(img.pixels[loc]);
      //Compute new pixel color in the merged image
      float res[] = { 0.0, 0.0, 0.0 } ;  //Define the 3x1 matrix for the output
      //Perform the matrix multiplication
      for (int i=0;  i < filter[0].length; i++) {
        for (int j=0; j < pix.length; j++) {
           res[j] += filter[i][j] * pix[j];
        }
      }
      //Now set new color
      retVal.pixels[loc] = color(res[0],res[1],res[2]);
    }
  }
  return retVal;
}

void setup() {
  size(pic.width, pic.height);
}


void draw() {
  image(filter(pic, mat),0,0);
}