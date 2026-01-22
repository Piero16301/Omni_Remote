#include <WiFi.h>
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
const char* group_online_topic = "demo/online";

const char* switch_command_topic = "demo/switch/command";
const char* switch_status_topic = "demo/switch/status";

const char* number_command_topic = "demo/number/command";
const char* number_status_topic = "demo/number/status";

// --- 5. HARDWARE CONFIGURATION ---
const int SWITCH_PIN = 5;
int switch_state = LOW;

const int NUMBER_PIN_1 = 14;
const int NUMBER_PIN_2 = 12;
const int NUMBER_PIN_3 = 13;
const int NUMBER_PIN_4 = 15;
int number_value = 0;

// WiFi and MQTT client objects
WiFiClientSecure espClient;
PubSubClient mqttClient(espClient);


// =========================================================================
// CONNECTION AND RECONNECTION FUNCTIONS
// =========================================================================

void setupWifi() {
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

void mqttReconnect() {
  while (!mqttClient.connected()) {
    Serial.print("Attempting MQTT connection...");

    // Generate a unique Client ID
    String clientId = "ESP8266_Client_";
    clientId += String(random(0xffff), HEX);

    // Connection with authentication (Username and Password)
    // Using switch_online_topic as the main LWT topic
    if (mqttClient.connect(
      clientId.c_str(),
      mqtt_user,
      mqtt_password,
      group_online_topic,
      1,
      true,
      "0"
    )) {
      Serial.println("connected!");

      // Publish online status for group
      mqttClient.publish(group_online_topic, "1", true);
      
      // Subscribe to all topics
      if (mqttClient.subscribe(switch_command_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(switch_command_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(switch_command_topic);
      }

      if (mqttClient.subscribe(switch_status_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(switch_status_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(switch_status_topic);
      }

      if (mqttClient.subscribe(number_command_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(number_command_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(number_command_topic);
      }

      if (mqttClient.subscribe(number_status_topic, 1)) {
        Serial.print("Subscribed to: ");
        Serial.println(number_status_topic);
      } else {
        Serial.print("ERROR: Failed to subscribe to: ");
        Serial.println(number_status_topic);
      }

      // Turn off built-in LED when broker connection is complete
      digitalWrite(LED_BUILTIN, HIGH);
    } else {
      Serial.print("failed, rc=");
      Serial.print(mqttClient.state());
      Serial.println(" Retrying in 5 seconds...");
      delay(5000);
    }
  }
}

// =========================================================================
// MESSAGE RECEPTION FUNCTION (CALLBACK)
// =========================================================================

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received on topic: ");
  Serial.println(topic);

  String messageTemp;
  for (unsigned int i = 0; i < length; i++) {
    messageTemp += (char)payload[i];
  }

  Serial.print("Message: ");
  Serial.println(messageTemp);

  // Process switch topics
  if (String(topic) == switch_command_topic || String(topic) == switch_status_topic) {
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

    if (new_state != switch_state) {
        switch_state = new_state;

        digitalWrite(SWITCH_PIN, new_state);

        Serial.print("Light changed to: ");
        Serial.println(switch_state == HIGH ? "ON" : "OFF");

        // Only publish FEEDBACK if the message comes from the COMMAND topic
        // Avoids an infinite loop when receiving the retained message
        if (String(topic) == switch_command_topic) {
          String status_msg = (switch_state == HIGH) ? "1" : "0";
          mqttClient.publish(switch_status_topic, (uint8_t*)status_msg.c_str(), status_msg.length(), true);
        }
    }
  }
  // Process number topics
  else if (String(topic) == number_command_topic || String(topic) == number_status_topic) {
    int new_value = messageTemp.toInt();

    if (new_value < 0 || new_value > 15) {
      Serial.println("Invalid number command. Must be between 0 and 15.");
      return;
    }

    if (new_value != number_value) {
        number_value = new_value;

        // Set the number pins according to the binary representation of number_value
        // NUMBER_PIN_1 is the most significant bit (MSB - leftmost LED)
        digitalWrite(NUMBER_PIN_1, (number_value & 0x08) ? HIGH : LOW); // Bit 3 (MSB)
        digitalWrite(NUMBER_PIN_2, (number_value & 0x04) ? HIGH : LOW); // Bit 2
        digitalWrite(NUMBER_PIN_3, (number_value & 0x02) ? HIGH : LOW); // Bit 1
        digitalWrite(NUMBER_PIN_4, (number_value & 0x01) ? HIGH : LOW); // Bit 0 (LSB)

        Serial.print("Number changed to: ");
        Serial.println(number_value);

        // Only publish FEEDBACK if the message comes from the COMMAND topic
        // Avoids an infinite loop when receiving the retained message
        if (String(topic) == number_command_topic) {
          String status_msg = String(number_value);
          mqttClient.publish(number_status_topic, (uint8_t*)status_msg.c_str(), status_msg.length(), true);
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

  pinMode(SWITCH_PIN, OUTPUT);
  pinMode(NUMBER_PIN_1, OUTPUT);
  pinMode(NUMBER_PIN_2, OUTPUT);
  pinMode(NUMBER_PIN_3, OUTPUT);
  pinMode(NUMBER_PIN_4, OUTPUT);

  setupWifi();

  espClient.setInsecure();

  mqttClient.setServer(mqtt_server, mqtt_port);
  mqttClient.setCallback(mqttCallback);
}

void loop() {
  if (!mqttClient.connected()) {
    mqttReconnect();
  }
  mqttClient.loop();
}
