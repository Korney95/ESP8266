// Pinout dht11 +3v, g, out D1, esp8266 NODEMCU
// Import required libraries
#include "ESP8266WiFi.h"
#include <aREST.h>
#include "DHT.h" 
// DHT11 sensor pins
#define DHTPIN 5
#define DHTTYPE DHT11

// Create aREST instance
aREST rest = aREST();

// Initialize DHT sensor
DHT dht(DHTPIN, DHTTYPE, 15);
const char* host = "dweet.io";
// WiFi parameters
const char* ssid = "kirusha";
const char* password = "logotip69";

// The port to listen for incoming TCP connections 
#define LISTEN_PORT           80

// Create an instance of the server
WiFiServer server(LISTEN_PORT);

// Variables to be exposed to the API
float temperature;
float humidity;

void setup(void)
{  
  // Start Serial
  Serial.begin(115200);
  
  // Init DHT 
  dht.begin();
  
  // Init variables and expose them to REST API
  rest.variable("temperature",&temperature);
  rest.variable("humidity",&humidity);
    
  // Give name and ID to device
  rest.set_id("2517");
  rest.set_name("korneenkov");
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
 
  // Start the server
  server.begin();
  Serial.println("Server started");
  
  // Print the IP address
  Serial.println(WiFi.localIP());
  
}

void loop() {
    
 Serial.print("Connecting to ");
  Serial.println(host);
  
  // Use WiFiClient class to create TCP connections
  WiFiClient client;
  const int httpPort = 80;
  if (!client.connect(host, httpPort)) {
    Serial.println("connection failed");
    return;
  }
  
  // Reading temperature and humidity
  int h = dht.readHumidity();
  // Read temperature as Celsius
  int t = dht.readTemperature();
  
  // This will send the request to the server
  client.print(String("GET /dweet/for/kirusha?temperature=") + String(t) + "&humidity=" + String(h) + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" + 
               "Connection: close\r\n\r\n");
  delay(10);
  
  // Read all the lines of the reply from server and print them to Serial
  while(client.available()){
    String line = client.readStringUntil('\r');
    Serial.print(line);
  }
  
  Serial.println();
  Serial.println("closing connection");
  
  // Repeat every 10 seconds
  delay(10000);
 
 
}