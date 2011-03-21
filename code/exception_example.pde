import processing.serial.*;

//Variables for writing sensor data
Serial port;  // Create object from Serial class
int oldTime;  //timer variable
int reportingInterval = 1000;  //Number of miliiseconds between when sensor data is recorded

int idx = 0;  // Index that counts the number of iterations so far
float val = 0.0;  // The value read from the port

boolean arduinoOK = false; //Ad a flag to test when the port is OK

void setup() {
  size(200,100);  
  textFont(createFont("",12),12);
}

// Reads the port
void readPort() {
  val = 0.0;
  if (port.available() > 0) { // If data is available,
    val = port.read();        // read it and store it in val
  }
  //Determine if we need to report the level
  if ((millis() - oldTime) > reportingInterval) {
    oldTime = millis();
    idx += 1;
  }      
}

void draw() {
  background(0);
  if (!arduinoOK) {  
     text("No arduino!", 10, height/2);
     println(Serial.list());
     try {
        String arduinoPort = Serial.list()[0];  
        port = new Serial(this, arduinoPort, 9600);
        arduinoOK = true;
     } catch (Exception e) {
        arduinoOK = false;
     }
  } else {
    readPort();
    text(idx + ": " + val, width/2, height/2);
  }
}



