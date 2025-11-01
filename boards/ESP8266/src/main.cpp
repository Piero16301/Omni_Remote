#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

// --- 1. WIFI NETWORK CONFIGURATION ---
const char* ssid = "ENGOMOHE-2.4G";
const char* password = "0178691930";

// --- 2. MQTT BROKER CONFIGURATION ---
const char* mqtt_server = "4a3d7cdffc0943709189065b2b48eece.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;

// --- 3. BROKER AUTHENTICATION ---
const char* mqtt_user = "pmorales";
const char* mqtt_password = "qweASD123*";

// --- 4. TOPIC DEFINITIONS ---
const char* command_topic = "legos/camp_nou/command";
const char* status_topic = "legos/camp_nou/status";
const char* online_topic = "legos/camp_nou/online";

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
    if (client.connect(
      clientId.c_str(),
      mqtt_user,
      mqtt_password,
      online_topic,
      1,
      true,
      "0"
    )) {
      Serial.println("connected!");

      // Publish "1" status
      client.publish(online_topic, "1", true);
      
      // Subscribe to command topic
      if (client.subscribe(command_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(command_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(command_topic);
      }

      // Subscribe to status topic
      if (client.subscribe(status_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(status_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(status_topic);
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

  // Process only defined topics (command_topic and status_topic)
  if (String(topic) == command_topic || String(topic) == status_topic) {
    int new_state;

    // Map ON/OFF to pin logic (Active-High for external LED)
    if (messageTemp == "1" || messageTemp.equalsIgnoreCase("ON")) {
      new_state = HIGH;
    } else if (messageTemp == "0" || messageTemp.equalsIgnoreCase("OFF")) {
      new_state = LOW;
    } else {
      Serial.println("Invalid MQTT command.");
      return;
    }

    if (new_state != led_state) {
        led_state = new_state;

        digitalWrite(RELAY_PIN, new_state);

        Serial.print("Light changed to: ");
        Serial.println(led_state == HIGH ? "ON" : "OFF");

        // Only publish FEEDBACK if the message comes from the COMMAND topic
        // Avoids an infinite loop when receiving the retained message
        if (String(topic) == command_topic) {
          String status_msg = (led_state == HIGH) ? "1" : "0";
          client.publish(status_topic, (uint8_t*)status_msg.c_str(), status_msg.length(), true);
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