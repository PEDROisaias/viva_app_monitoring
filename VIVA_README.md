<div align="center">

# 🛡️ VIVA APP MONITORING
### Aplicativo Mobile Companion para o Detector de Gases Tóxicos AM-032

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![MQTT](https://img.shields.io/badge/MQTT-mqtt__client%2010.2-660066?style=flat-square)](https://pub.dev/packages/mqtt_client)
[![License](https://img.shields.io/badge/Licença-MIT-green?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Plataforma-Android%20%7C%20iOS-lightgrey?style=flat-square)](https://flutter.dev)

</div>

---

## 📖 Sobre o Projeto

O **VIVA App Monitoring** é o app mobile companion para o dispositivo IoT **ESP32 AM-032**, um detector de gases tóxicos e qualidade do ar. O app consome dados em tempo real via protocolo **MQTT**, exibe leituras dos sensores MQ-7 (CO) e MQ-2/5 (Fumaça/Gases), emite alertas locais críticos e mantém histórico de medições para análise.

### Funcionalidades principais

- 📡 **Conexão MQTT em tempo real** com reconexão automática e backoff exponencial
- 🌡️ **Dashboard** com gauge animado de qualidade do ar (BOA / ATENÇÃO / PERIGO)
- 📊 **Gráfico de histórico** interativo com filtros por período (Hoje / Semana / Mês)
- 🚨 **Notificações locais críticas** com som e vibração, mesmo em background
- ⚙️ **Configuração de broker** com suporte a TCP, SSL e WebSocket
- 🔋 **Monitoramento do dispositivo** — bateria, sinal Wi-Fi e status online/offline

---

## 🖼️ Telas

| Dashboard | Histórico | Configurações |
|:---------:|:---------:|:-------------:|
| Gauge de qualidade do ar, leituras PPM e recomendações contextuais | Gráfico de linha interativo com filtros de período | Formulário de broker MQTT com teste de conexão |

---

## 🏗️ Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com separação estrita entre camadas:

```
lib/
├── data/                   → Serviços de dados (MQTT, armazenamento local)
├── models/                 → Entidades de domínio puras
├── repository/             → Interface + implementação do repositório MQTT
├── res/
│   ├── components/         → Widgets reutilizáveis
│   └── style/              → Design tokens e tema global
├── utils/                  → Utilitários (alertas, rotas)
├── view/
│   ├── home/               → Tela principal (Dashboard)
│   ├── history/            → Tela de histórico e análise
│   └── onboard/            → Configuração do broker
├── view_model/             → ViewModels com lógica de negócio
└── main.dart               → Entry point + injeção de dependências
```

### Fluxo de dados

```
ESP32 AM-032  →  MQTT Broker  →  MqttRepository  →  DashboardViewModel  →  UI
                                      ↓
                               AlertService (notificações locais)
                                      ↓
                           LocalStorageService (histórico + config)
```

---

## 📦 Dependências

| Pacote | Versão | Finalidade |
|--------|--------|------------|
| [`mqtt_client`](https://pub.dev/packages/mqtt_client) | ^10.2.1 | Comunicação MQTT (TCP / WebSocket) |
| [`provider`](https://pub.dev/packages/provider) | ^6.1.2 | Gerenciamento de estado MVVM |
| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | ^2.2.3 | Persistência local (config + histórico) |
| [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) | ^17.2.2 | Alertas locais em foreground e background |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | ^0.69.0 | Gráfico de linha interativo |
| [`intl`](https://pub.dev/packages/intl) | ^0.19.0 | Formatação de datas |

---

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK **3.19+**
- Dart **3.3+**
- Android Studio ou VS Code com extensão Flutter
- Dispositivo físico ou emulador Android API 21+ / iOS 13+

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/viva_app_monitoring.git
cd viva_app_monitoring

# 2. Instale as dependências
flutter pub get

# 3. Rode o app
flutter run
```

### Configuração do broker MQTT

Ao abrir o app pela primeira vez, acesse **Configurações** e preencha:

| Campo | Descrição | Padrão |
|-------|-----------|--------|
| Host | Endereço IP ou domínio do broker | `broker.hivemq.com` |
| Porta | 1883 (TCP), 8883 (SSL), 8083 (WS) | `1883` |
| Topic Prefix | Prefixo dos tópicos MQTT | `am032` |
| Client ID | Identificador único do cliente | Gerado automaticamente |
| Usuário / Senha | Credenciais (opcional) | — |

---

## 📡 Protocolo MQTT

O app se inscreve em três tópicos publicados pelo ESP32:

### `am032/sensors/data` — Leituras dos sensores
```json
{
  "device_id": "AM032-A1B2C3",
  "timestamp": 1720000000000,
  "sensors": {
    "mq7":   { "ppm": 12.4, "raw_adc": 845 },
    "mq2_5": { "ppm": 87.6, "raw_adc": 1023, "gas_type": "SMOKE" }
  },
  "battery": { "percentage": 78, "voltage": 3.85, "charging": false }
}
```

### `am032/sensors/status` — Estado geral de qualidade do ar
```json
{
  "device_id": "AM032-A1B2C3",
  "timestamp": 1720000000000,
  "state": 1,
  "triggered_by": "mq7",
  "thresholds": { "warning_ppm": 50, "danger_ppm": 150 }
}
```
> `state`: `0` = BOA · `1` = ATENÇÃO · `2` = PERIGO

### `am032/device/heartbeat` — Status online/offline (LWT)
```json
{
  "device_id": "AM032-A1B2C3",
  "status": "online",
  "timestamp": 1720000000000,
  "firmware_version": "1.2.0",
  "uptime_seconds": 3600,
  "wifi_rssi": -65
}
```
> Payload LWT (Last Will): `"offline"` com `retain=true` e `QoS=1`

---

## ⚠️ Limiares de Alerta

### Sensor MQ-7 — Monóxido de Carbono (CO)

| Concentração | Estado | Indicação |
|:---:|:---:|:---|
| 0 – 49 PPM | 🟢 BOA | Dentro dos padrões normais |
| 50 – 149 PPM | 🟡 ATENÇÃO | Ventilação recomendada |
| ≥ 150 PPM | 🔴 PERIGO | Evacuar imediatamente |

### Sensor MQ-2/5 — Fumaça e Gases Combustíveis

| Concentração | Estado | Indicação |
|:---:|:---:|:---|
| 0 – 149 PPM | 🟢 BOA | Ambiente seguro |
| 150 – 499 PPM | 🟡 ATENÇÃO | Verificar fonte de gás |
| ≥ 500 PPM | 🔴 PERIGO | Risco de incêndio/explosão |

> O estado final exibido é sempre o **pior caso** entre os dois sensores. O firmware do ESP32 pode sobrescrever o estado via tópico `sensors/status`.

*Referência: OSHA PEL CO = 50 ppm (TWA 8h) · IDLH = 1200 ppm*

---

## 🔔 Sistema de Alertas

### Canal DANGER (Nível 2 — PERIGO)
- Prioridade máxima com `fullScreenIntent` — exibe mesmo com tela bloqueada
- Notificação `ongoing` (não pode ser dispensada com swipe)
- Som de alarme personalizado + padrão de vibração intenso
- Cooldown de 30 segundos entre disparos para evitar spam

### Canal WARNING (Nível 1 — ATENÇÃO)
- Alta prioridade com som padrão e vibração
- Dispensável pelo usuário
- Cooldown de 30 segundos

---

## 🔁 Reconexão Automática

O app implementa **backoff exponencial com jitter** para reconexão ao broker MQTT:

| Tentativa | Delay aproximado |
|:---------:|:----------------:|
| 1ª | ~3s |
| 2ª | ~5s |
| 3ª | ~9s |
| 4ª | ~17s |
| 5ª | ~33s |
| 6ª | ~65s |
| 7ª – 8ª | ~120s (máximo) |
| > 8 | ❌ Para e emite erro |

Fórmula: `min(2000 × 2^(n-1) + rand(0–1000), 120000) ms`

---

## 🛠️ Configuração Android

### `android/app/build.gradle.kts`
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### `android/app/src/main/AndroidManifest.xml`
Permissões necessárias:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Sons de alarme
Adicione o arquivo de som em:
```
android/app/src/main/res/raw/alarm_danger.mp3
```

---

## 🍎 Configuração iOS

### `ios/Runner/Info.plist`
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

### Som de alarme
```
ios/Runner/alarm_danger.aiff
```

---

## 🧪 Testes sem Hardware

Para testar o app sem o dispositivo físico AM-032, use o [MQTT Explorer](https://mqtt-explorer.com/) ou o `mosquitto_pub`:

```bash
# Estado BOA
mosquitto_pub -h broker.hivemq.com -t "am032/sensors/data" -m \
'{"device_id":"AM032-TEST","timestamp":1720000000000,"sensors":{"mq7":{"ppm":10,"raw_adc":400},"mq2_5":{"ppm":50,"raw_adc":600,"gas_type":"SMOKE"}},"battery":{"percentage":85,"voltage":3.9,"charging":false}}'

# Estado ATENÇÃO
mosquitto_pub -h broker.hivemq.com -t "am032/sensors/status" -m \
'{"device_id":"AM032-TEST","timestamp":1720000000000,"state":1,"triggered_by":"mq7"}'

# Estado PERIGO (dispara notificação)
mosquitto_pub -h broker.hivemq.com -t "am032/sensors/status" -m \
'{"device_id":"AM032-TEST","timestamp":1720000000000,"state":2,"triggered_by":"both"}'

# Heartbeat online
mosquitto_pub -h broker.hivemq.com -r -t "am032/device/heartbeat" -m \
'{"device_id":"AM032-TEST","status":"online","timestamp":1720000000000,"firmware_version":"1.2.0","uptime_seconds":3600,"wifi_rssi":-58}'
```

---

## ✅ Checklist de Integração com o Firmware ESP32

- [ ] Publicar `am032/sensors/data` a cada **5 segundos** com QoS 1
- [ ] Publicar `am032/sensors/status` a cada mudança de estado + keepalive 5s
- [ ] Configurar LWT no `am032/device/heartbeat` com payload `"offline"`, `retain=true`, QoS 1
- [ ] Publicar heartbeat `"online"` ao conectar, com `retain=true`
- [ ] `device_id` único por dispositivo (recomendado: endereço MAC)
- [ ] `timestamp` em **milissegundos Unix UTC**
- [ ] Campo `gas_type` com um dos valores: `SMOKE | LPG | PROPANE | HYDROGEN | MIXED`

---

## 📁 Estrutura Completa do Projeto

```
lib/
├── data/
│   └── local_storage_service.dart     SharedPreferences (config + histórico)
├── models/
│   ├── sensor_reading.dart            SensorReading, MQ7Reading, MQ25Reading, BatteryInfo
│   ├── air_quality_status.dart        AirQualityState, AirQualityStatus
│   ├── device_heartbeat.dart          DeviceHeartbeat
│   ├── mqtt_broker_config.dart        MqttBrokerConfig
│   └── mqtt_events.dart               MqttEvent (sealed class)
├── repository/
│   ├── i_mqtt_repository.dart         Interface IMqttRepository
│   └── mqtt_repository.dart           Implementação com backoff exponencial
├── res/
│   ├── components/
│   │   ├── air_quality_card.dart      Gauge circular animado
│   │   ├── sensor_readings_card.dart  Leituras PPM com barra de progresso
│   │   ├── connection_header.dart     Badge de status MQTT
│   │   ├── recommendations_card.dart  Lista dinâmica de recomendações
│   │   └── battery_indicator.dart     Ícone de bateria
│   └── style/
│       └── app_theme.dart             AM032Colors, AM032Theme, design tokens
├── utils/
│   ├── alert_service.dart             Notificações locais (DANGER / WARNING)
│   └── routes/
│       └── app_routes.dart            Rotas nomeadas
├── view/
│   ├── home/
│   │   └── home_screen.dart           Dashboard principal
│   ├── history/
│   │   └── history_screen.dart        Gráfico + filtros de período
│   └── onboard/
│       └── settings_screen.dart       Configuração do broker
├── view_model/
│   ├── dashboard_view_model.dart      Lógica, estado e recomendações
│   └── settings_view_model.dart       Configuração e teste de conexão
└── main.dart                          Entry point + MultiProvider
```

---

## 📄 Licença

Distribuído sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.

---

<div align="center">
  Desenvolvido para o projeto <strong>VIVA — Detector de Gases Tóxicos AM-032</strong>
</div>
