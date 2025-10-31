#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

// --- 1. CONFIGURACIÓN DE RED WIFI ---
const char* ssid = "ENGOMOHE-2.4G";
const char* password = "0178691930";

// --- 2. CONFIGURACIÓN DEL BROKER MQTT (IMPORTANTE) ---
const char* mqtt_server = "4a3d7cdffc0943709189065b2b48eece.s1.eu.hivemq.cloud";
const int mqtt_port = 8883;

// --- 3. AUTENTICACIÓN DEL BROKER ---
const char* mqtt_user = "pmorales";
const char* mqtt_password = "qweASD123*";

// --- 4. DEFINICIÓN DE TÓPICOS ---
const char* in_topic = "casa/legos/camp_nou/comando"; 
const char* out_topic = "casa/legos/camp_nou/estado"; 

// --- 5. CONFIGURACIÓN DEL HARDWARE ---
const int RELAY_PIN = 5;
int led_state = LOW;

// Objetos cliente WiFi y MQTT
WiFiClientSecure espClient;
PubSubClient client(espClient);


// =========================================================================
// FUNCIONES DE CONEXIÓN Y RECONEXIÓN
// =========================================================================

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Conectando a la red: ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi Conectado!");
  Serial.print("Dirección IP: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Intentando conexión MQTT...");

    // Genera un ID de Cliente único
    String clientId = "ESP8266_Cliente_";
    clientId += String(random(0xffff), HEX);

    // Conexión con autenticación (Usuario y Contraseña)
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_password)) {
      Serial.println("conectado!");
      
      // Suscripción al tópico de comando
      if (client.subscribe(in_topic, 1)) {
        Serial.print("Suscrito a: ");
        Serial.println(in_topic);
      } else {
        Serial.print("ERROR: Falló la suscripción a: ");
        Serial.println(in_topic);
      }

      // Suscripción al tópico de estado
      if (client.subscribe(out_topic, 1)) {
        Serial.print("Suscrito a: ");
        Serial.println(out_topic);
      } else {
        Serial.print("ERROR: Falló la suscripción a: ");
        Serial.println(out_topic);
      }

      // Apagar LED integrado cuando la conexión al broker esté completa
      digitalWrite(LED_BUILTIN, HIGH);
    } else {
      Serial.print("falló, rc=");
      Serial.print(client.state());
      Serial.println(" Intentando de nuevo en 5 segundos...");
      delay(5000);
    }
  }
}


// =========================================================================
// FUNCIÓN DE RECEPCIÓN DE MENSAJES (CALLBACK)
// =========================================================================

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Mensaje recibido en el tópico: ");
  Serial.println(topic);

  String messageTemp;
  for (unsigned int i = 0; i < length; i++) {
    messageTemp += (char)payload[i];
  }

  Serial.print("Mensaje: ");
  Serial.println(messageTemp);

  // Procesar solo los tópicos definidos (in_topic y out_topic)
  if (String(topic) == in_topic || String(topic) == out_topic) {
    int new_state;
    int pin_output;

    // Mapeo de ON/OFF a la lógica del pin (Activo-Alto para LED externo)
    if (messageTemp == "1" || messageTemp.equalsIgnoreCase("ON")) {
      new_state = HIGH; 
      pin_output = HIGH; 
    } else if (messageTemp == "0" || messageTemp.equalsIgnoreCase("OFF")) {
      new_state = LOW; 
      pin_output = LOW;  
    } else {
      Serial.println("Comando MQTT inválido.");
      return; 
    }

    if (new_state != led_state) {
        led_state = new_state;

        digitalWrite(RELAY_PIN, pin_output);

        Serial.print("Luz cambiada a: ");
        Serial.println(led_state == HIGH ? "ENCENDIDO" : "APAGADO");

        // Solo publica RETROALIMENTACIÓN si el mensaje proviene del tópico de COMANDO
        // Evita un loop infinito al recibir el mensaje retenido
        if (String(topic) == in_topic) {
          String status_msg = (led_state == HIGH) ? "1" : "0";
          client.publish(out_topic, (uint8_t*)status_msg.c_str(), status_msg.length(), true);
        }
    }
  }
}


// =========================================================================
// SETUP Y LOOP
// =========================================================================

void setup() {
  Serial.begin(115200);

  // Configurar LED integrado
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW); // LED ON (LOW enciende el LED integrado en ESP8266)

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