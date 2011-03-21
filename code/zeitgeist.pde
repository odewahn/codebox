import controlP5.*;  
import java.net.URLEncoder; //Used to encode query strings

ControlP5 controlP5;  //ControlP5 object
Textfield userQuery;
Button findButton;


ArrayList suggestionList;  //Running list of suggestions

int oldTime = 0; 
int timeBetweenFetches = 5000;  //Fetch a new batch of suggestions every 5 second
int alphaIdx = 0;
boolean readImmediate = false;  //A flag we can set to bypass the timer and read the suggestions immeditely


int y;  //Current y position of the top most piece of text
int fontSize = 48;  //Size of the words
int buffer = 5;  //Number of pixels between text
int dy = 1;  //Number of pixels moved each frame


String baseURL = "http://google.com/complete/search?output=toolbar&";
String alphabet = "abcdedfhijklmnopqrstuvwxyz";

    
// Set up the key variables
void setup() {
   frameRate(45);
   textFont (createFont("", fontSize), fontSize);
   size(600, 450, P3D);
   //Set up user interface
   controlP5 = new ControlP5(this);
   controlP5.addTextfield("userQuery", 50, 60, 100,20);
   controlP5.addButton("findButton", 1, 160, 60, 50,20);
   //Set up data set to hold queries
   suggestionList = new ArrayList();
   // Set up timing for query
   oldTime = millis();
   readImmediate = true;
   // Set text position
   y = height;
}


//Encodes a parameter to use in a query string
String encode (String name, String value) {
  String retVal = "";
   try {
      retVal = name + "=" + URLEncoder.encode(value, "UTF-8"); 
    } catch (UnsupportedEncodingException ex) {
      throw new RuntimeException("UTF not supported");
    }
    return retVal;
}     


//Seems like there is some undocumented changes happeneing w/in XMLElement in processing
// This post in the forums helped clarify what was up
// http://forum.processing.org/topic/xmlelement-problem-function-getint-getstring-does-not-exist
void getSuggestions(String theURL) {
  String[] results = loadStrings(theURL);
  String suggestions = join(results,"\n");
  XMLElement xml = new XMLElement(suggestions);
  for (int j=0; j < xml.getChildCount(); j++) {
     XMLElement suggestion = xml.getChild(j);
     String s = suggestion.getChild(0).getStringAttribute("data");
     suggestionList.add(s);  //Add the suggestion to our data set
  }
}

  
//Called when the user presses a button.  This resets the query values passed 
//to google
public void findButton(int theValue) {
   alphaIdx = 0;  //Reset us back to the beginning of the alphabet
   suggestionList.clear();  //Clear the current list of suggestions
   oldTime = millis();  //Reset the current time
   readImmediate = true;  //Set the flag to bypass the time
   y = height;   //Reset the location of the y position of the text
}

void draw() {
  background(0);
  controlP5.draw();  //This is necessary when you're using 3D mode
  //Read a new set of suggestions every few seconds, as specified in timeBetweenFetches
  if (alphaIdx < alphabet.length()) {
     int passedTime = millis() - oldTime;
     if ( (passedTime > timeBetweenFetches) || readImmediate ) {  
        String uq = ((Textfield)controlP5.controller("userQuery")).getText();   
        String theQuery = encode("q", uq + " " + alphabet.charAt(alphaIdx));
        getSuggestions(baseURL + theQuery);
        alphaIdx += 1;
        oldTime = millis();
        readImmediate = false;
     }
  }

  //Now draw the scolling text
  fill(255,255,25);
  pushMatrix();
  // Idea to rotate the text comes from Luis Gonzalez's "Star Wars" sketch on openprocesing.org
  // http://www.openprocessing.org/visuals/?visualID=4167
  rotateX(PI/3.75);
  y -= dy;  //set the scroll variable
  for (int i=0; i < suggestionList.size(); i++) {
     String s = (String) suggestionList.get(i);
     int tx = (int) (width - textWidth(s))/2; //Centers the text on the x-axis
     int ty = y + i * (fontSize + buffer);  //Computes the y position
     text(s,tx,ty, -width/2);
  }
  popMatrix();
}

   
   
