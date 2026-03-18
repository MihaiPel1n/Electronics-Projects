// Load in the libraries
#include <SPI.h>
#include <nRF24L01.h>
#include <RF24.h>

// Set the CE & CSN pins
#define VRX_PIN  A1 
#define VRY_PIN  A0
#define CE_PIN   9
#define CSN_PIN 10

// This is the address used to send/receive
const byte rxAddr[6] = "00001";
int poz[3];
// Create a Radio
RF24 radio(CE_PIN, CSN_PIN); 

void setup() {
  
  // Start up the Serial connection
  while (!Serial);
  Serial.begin(9600);
  
  // Start the Radio!
  radio.begin();

  radio.setPALevel(RF24_PA_MIN); // RF24_PA_MIN, RF24_PA_LOW, RF24_PA_HIGH, RF24_PA_MAX
  
  // Slower data rate for better range
  radio.setDataRate( RF24_250KBPS ); // RF24_250KBPS, RF24_1MBPS, RF24_2MBPS
  
  // Number of retries and set tx/rx address
  radio.setRetries(15, 15);
  radio.openWritingPipe(rxAddr);

  // Stop listening, so we can send!
  radio.stopListening();
}

void loop() {

  poz[0] = analogRead(VRX_PIN);


  radio.write(&poz, sizeof(poz));
  
  // Let the ourside world know..
  Serial.print("X: ");
  Serial.print( poz[0] );

  
  // Wait a short while before sending the other one
  delay(50);
}
