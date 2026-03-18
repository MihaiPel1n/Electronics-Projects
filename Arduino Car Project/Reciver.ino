// Load up the libraries
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>
#include <Servo.h>

Servo myservo;
// define the pins
#define CE_PIN   9
#define CSN_PIN 10
int motor1pin1 = 2;
int motor1pin2 = 3;

int motor2pin1 = 4;
int  motor2pin2 = 5;

// Create a Radio
RF24 radio(CE_PIN, CSN_PIN); 

// The tx/rx address
const byte rxAddr[6] = "00001";

void setup()
{

  // Start the serial
  Serial.begin(9600);
  while(!Serial);
  Serial.println("NRF24L01P Receiver Starting...");
  
  myservo.attach(6); 
  pinMode(motor1pin1, OUTPUT);
  pinMode(motor1pin2, OUTPUT);
  pinMode(motor2pin1,  OUTPUT);
  pinMode(motor2pin2, OUTPUT);

  
  radio.begin();
  radio.setPALevel(RF24_PA_MIN);   
  radio.setDataRate( RF24_250KBPS ); 
  
  // Set the reading pipe and start listening
  radio.openReadingPipe(0, rxAddr);
  radio.startListening();
  
}

void loop()
{
  if (radio.available())
  {
    // the buffer to store the received message in
    int poz[2]={0};
    
    radio.read(&poz, sizeof(poz));

    if(poz[0]>500)
    {
      digitalWrite(motor1pin1,  LOW);
      digitalWrite(motor1pin2, HIGH);

      digitalWrite(motor2pin1, HIGH);
      digitalWrite(motor2pin2, LOW);
    }
    if(poz[0]<270 && poz[0]>0)
    {
      digitalWrite(motor1pin1,  HIGH);
      digitalWrite(motor1pin2, LOW);

      digitalWrite(motor2pin1, LOW);
      digitalWrite(motor2pin2, HIGH);
    }
    if(poz[0]>270 && poz[0]<500)
    {
      digitalWrite(motor1pin1,  LOW);
      digitalWrite(motor1pin2, LOW);

      digitalWrite(motor2pin1, LOW);
      digitalWrite(motor2pin2, LOW);
    }

  
    
    Serial.print("X: ");
    Serial.println( poz[0] );

  } 
}
