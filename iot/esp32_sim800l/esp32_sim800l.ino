#include <TinyGPSPlus.h>
#include <PubSubClient.h>
#include <SoftwareSerial.h>
#include <WiFiClientSecure.h>

// SIM800L serial pins
static const int SIM800_RX = 16;
static const int SIM800_TX = 17;

// Neo-6M GPS pins
static const int GPS_RX = 4;
static const int GPS_TX = 5;

static const int LED_PIN = 2;

TinyGPSPlus gps;
SoftwareSerial gpsSerial(GPS_RX, GPS_TX);
SoftwareSerial sim800Serial(SIM800_RX, SIM800_TX);

WiFiClientSecure secureClient;
PubSubClient mqttClient(secureClient);

const char* MQTT_BROKER = "broker.example.com";
const int MQTT_PORT = 8883;
const char* MQTT_PUB_TOPIC = "lifepath/ambulance/telemetry";
const char* MQTT_SUB_TOPIC = "lifepath/ambulance/status";

unsigned long lastPublish = 0;

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  String message;
  for (unsigned int i = 0; i < length; i++) {
    message += static_cast<char>(payload[i]);
  }

  if (String(topic) == MQTT_SUB_TOPIC && message == "GREEN_WAVE") {
    digitalWrite(LED_PIN, HIGH);
  } else {
    digitalWrite(LED_PIN, LOW);
  }
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  Serial.begin(115200);
  gpsSerial.begin(9600);
  sim800Serial.begin(9600);

  // TODO: Configure SIM800L with APN and establish GPRS connection.

  mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
  mqttClient.setCallback(onMqttMessage);
}

void ensureMqttConnection() {
  while (!mqttClient.connected()) {
    mqttClient.connect("AMB_001");
    mqttClient.subscribe(MQTT_SUB_TOPIC);
  }
}

void loop() {
  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  ensureMqttConnection();
  mqttClient.loop();

  unsigned long now = millis();
  if (now - lastPublish >= 2000 && gps.location.isValid()) {
    lastPublish = now;

    char payload[256];
    snprintf(
      payload,
      sizeof(payload),
      "{\"device_id\":\"AMB_001\",\"lat\":%.6f,\"lon\":%.6f,\"speed\":%.2f,\"emergency_mode\":true}",
      gps.location.lat(),
      gps.location.lng(),
      gps.speed.kmph()
    );

    mqttClient.publish(MQTT_PUB_TOPIC, payload);
  }
}
