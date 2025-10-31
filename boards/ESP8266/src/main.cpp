#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

// --- 1. WIFI NETWORK CONFIGURATION ---
const char* ssid = "SSID_NAME_HERE";
const char* password = "PASSWORD_HERE";

// --- 2. MQTT BROKER CONFIGURATION ---
const char* mqtt_server = "MQTT_BROKER_ADDRESS_HERE";
const int mqtt_port = 8883;

// --- 3. BROKER AUTHENTICATION ---
const char* mqtt_user = "MQTT_USERNAME_HERE";
const char* mqtt_password = "MQTT_PASSWORD_HERE";

// --- 4. TOPIC DEFINITIONS ---
const char* in_topic = "RECEIVE_TOPIC_HERE";
const char* out_topic = "STATUS_TOPIC_HERE";

// --- 5. HARDWARE CONFIGURATION ---
const int RELAY_PIN = 5;
int led_state = LOW;

// WiFi and MQTT client objects
WiFiClientSecure espClient;
PubSubClient client(espClient);


// =========================================================================
// CONNECTION AND RECONNECTION FUNCTIONS
// =========================================================================

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to network: ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    // Generate a unique Client ID
    String clientId = "ESP8266_Client_";
    clientId += String(random(0xffff), HEX);

    // Connection with authentication (Username and Password)
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_password)) {
      Serial.println("connected!");
      
      // Subscribe to command topic
      if (client.subscribe(in_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(in_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(in_topic);
      }

      // Subscribe to status topic
      if (client.subscribe(out_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(out_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(out_topic);
      }

      // Turn off built-in LED when broker connection is complete
      digitalWrite(LED_BUILTIN, HIGH);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}


// =========================================================================
// MESSAGE RECEPTION FUNCTION (CALLBACK)
// =========================================================================

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received on topic: ");
  Serial.println(topic);

  String messageTemp;
  for (unsigned int i = 0; i < length; i++) {
    messageTemp += (char)payload[i];
  }

  Serial.print("Message: ");
  Serial.println(messageTemp);

  // Process only defined topics (in_topic and out_topic)
  if (String(topic) == in_topic || String(topic) == out_topic) {
    int new_state;
    int pin_output;

    // Map ON/OFF to pin logic (Active-High for external LED)
    if (messageTemp == "1" || messageTemp.equalsIgnoreCase("ON")) {
      new_state = HIGH;
      pin_output = HIGH;
    } else if (messageTemp == "0" || messageTemp.equalsIgnoreCase("OFF")) {
      new_state = LOW;
      pin_output = LOW;
    } else {
      Serial.println("Invalid MQTT command.");
      return;
    }

    if (new_state != led_state) {
        led_state = new_state;

        digitalWrite(RELAY_PIN, pin_output);

        Serial.print("Light changed to: ");
        Serial.println(led_state == HIGH ? "ON" : "OFF");

        // Only publish FEEDBACK if the message comes from the COMMAND topic
        // Avoids an infinite loop when receiving the retained message
        if (String(topic) == in_topic) {
          String status_msg = (led_state == HIGH) ? "1" : "0";
          client.publish(out_topic, (uint8_t*)status_msg.c_str(), status_msg.length(), true);
        }
    }
  }
}


// =========================================================================
// SETUP AND LOOP
// =========================================================================

void setup() {
  Serial.begin(115200);

  // Configure built-in LED
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW); // LED ON (LOW turns on the built-in LED on ESP8266)

  pinMode(RELAY_PIN, OUTPUT);

  setup_wifi();

  espClient.setInsecure();

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}