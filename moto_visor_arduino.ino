#include <SPI.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SH110X.h>

#define i2c_Address 0x3c
#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels
#define OLED_RESET -1   //   QT-PY / XIAO
Adafruit_SH1106G display = Adafruit_SH1106G(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

#define NUMFLAKES 10
#define XPOS 0
#define YPOS 1
#define DELTAY 2

const int buttonPin = 4;  
const int ledPin =  2;
int buttonState = 0;  
String message = "";
int buttonPushCounter = 0;   // variable pour le comptage du nombre d'appuis sur le bouton poussoir
int funcState = 0;
const int BATTERYPIN = A0; //pin de la batterie
const float TensionMin = 3.2; //tension min
const float TensionMax = 4.2; //tension max
String battery ="";
boolean cmd = 0;
String dir ="";
String speed ="";


void setup() {
  display.begin( i2c_Address, true );
  display.setRotation(1);
  display.clearDisplay();
  display.display();
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT);
  Serial.begin(9600);
}


void loop() {
    
if(!cmd){
while(Serial.available() > 0){
  message = Serial.readString();
  
  cmd = true;
//  Serial.println("----------------------------");
  Serial.println(message);
 }
}

if(cmd){
  if(message != "dir" and message !="speed"){
    cmd = false;
//    Serial.println("0000000000000000000");
    message ="";
  }
  if(message == "speed") {
    while(Serial.available() > 0){
      speed = Serial.readString();
//      Serial.println("+++++++++++++++");
  Serial.println(speed);
      cmd = false;
      message ="";
    }
  }
  if(message == "dir"){
    while(Serial.available() > 0){
      dir = Serial.readString();
  //    Serial.println("iiiiiiiiiiiiiiii");
      cmd = false;
      message ="";
    }
  }

}
    
setMode();
getBattery();
buttonPressed();
}

enum fcnMode {
 OFF,
 MOD1,
 MOD2,
 MOD3,
 NBSTATE
}; // OFF = 0 and NBSTATE=4

void buttonPressed(){

buttonState = digitalRead(buttonPin);

if (buttonState == HIGH) {
    // turn LED on:
    digitalWrite(ledPin, HIGH);
    
      buttonPushCounter++;

      funcState = buttonPushCounter % NBSTATE;
  display.setTextSize(1);
display.setTextColor(SH110X_WHITE);

      
      
delay(400);

    
  } else {
    // turn LED off:
    digitalWrite(ledPin, LOW);

  }
}

void setMode() {

 switch (funcState) {
   case OFF:
    mode4();
     break;
   case MOD1:
     mode1();
     break;
   case MOD2:
     mode2();
     break;
   case MOD3:
     mode3();
     break;
 }
}



void mode1() {
  
display.setTextSize(1);
display.setTextColor(SH110X_WHITE);
display.setCursor(0, 0);
display.clearDisplay();

  display.print(speed);
  display.display();


}

void mode2() {
  display.setTextSize(1);
display.setTextColor(SH110X_WHITE);
display.setCursor(0, 0);
display.clearDisplay();
display.print(dir);
display.display();
}
void mode3() {
  display.setTextSize(1);
display.setTextColor(SH110X_WHITE);
display.setCursor(0, 0);
display.clearDisplay();

display.print("batterie :" + battery);
display.display(); 
}
void mode4() {
display.clearDisplay();
display.display(); 
}

int getBattery ()
{
  float b = analogRead(BATTERYPIN); //valeur analogique
  int minValue = (1023 * TensionMin) / 5; //Arduino
  int maxValue = (1023 * TensionMax) / 5; //Arduino
  b = ((b - minValue) / (maxValue - minValue)) * 100; //mettre en pourcentage

  if (b > 100) //max is 100%
    b = 100;

  else if (b < 0) //min is 0%
    b = 0;
  int valeur = b;
  battery = b;
  return b;
}
