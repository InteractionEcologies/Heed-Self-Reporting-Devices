#include <BLE_API.h>
#include <QueueList.h>
#include <Adafruit_NeoPixel.h>

#define DEVICE_NAME   "BLE-ESM-106d"
#define NEOPIXEL_POWER_PIN D1
#define NEOPIXEL_PIN A3
#define SOFT_POT_POWER_PIN D0
#define SOFT_POT_PIN A4 


#define NUMPIXELS      1
#define ledPin   13

#define TXRX_BUF_LEN         20

#define DEVICE_ID            0xFF

#define INPUT_ACTIVATE_DURATION 10
#define USER_NOTIFICATION_DURATION 60

BLE                          ble;
Ticker                    ticker_task1; // ticker for potentiometer detect

int sleepHour =  22*60*60; // sleep at 10pm
int awakeHour =  7*60*60; // awake at 7am

unsigned long secondsSinceBoot = 0; // keeps track of seconds since boot
int curHour = 12*60*60; // this gets synced from phone to keep track of night time. Stored as seconds for easy increment.


String deviceSessionId = "";

// The uuid of service and characteristics
static const uint8_t service1_uuid[]         = {0x71, 0x3D, 0, 0, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t service1_chars1_uuid[]  = {0x71, 0x3D, 0, 3, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t service1_chars2_uuid[]  = {0x71, 0x3D, 0, 2, 0x50, 0x3E, 0x4C, 0x75, 0xBA, 0x94, 0x31, 0x48, 0xF1, 0x8D, 0x94, 0x1E};
static const uint8_t uart_base_uuid_rev[]    = {0x1E, 0x94, 0x8D, 0xF1, 0x48, 0x31, 0x94, 0xBA, 0x75, 0x4C, 0x3E, 0x50, 0, 0, 0x3D, 0x71};

uint8_t chars1_value[TXRX_BUF_LEN] = {0};
uint8_t chars2_value[TXRX_BUF_LEN] = {0};

// Create characteristic and service
GattCharacteristic  characteristic1(service1_chars1_uuid, chars1_value, 1, TXRX_BUF_LEN, GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_WRITE | GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_WRITE_WITHOUT_RESPONSE );
GattCharacteristic  characteristic2(service1_chars2_uuid, chars2_value, 1, TXRX_BUF_LEN, GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_NOTIFY | GattCharacteristic::BLE_GATT_CHAR_PROPERTIES_READ);
GattCharacteristic *uartChars[] = {&characteristic1, &characteristic2};
GattService         uartService(service1_uuid, uartChars, sizeof(uartChars) / sizeof(GattCharacteristic *));


void disconnectionCallBack(const Gap::DisconnectionCallbackParams_t *params) {
  ble.startAdvertising();
}

int showUserNotificationTime = -55;
const int NO_OBS = 70;
String all[NO_OBS];

int curIndex = 0;
//String some[] = {"499:296","1501:109","2504:268","3517:496","4540:176","5571:92","6609:380","7659:586","8217:578","8785:579","9363:578","10449:240","11046:239","11654:238","12772:136"};


String lastMessage = "";
QueueList <String> queue;


void sendMessage(char *string){
      int err=  ble.updateCharacteristicValue(characteristic2.getValueAttribute().getHandle(), (uint8_t *)string, strlen(string) );
      // Serial.println(String(string) + " | Error = " + String(err));
      if (err>0){
          queue.push (String(string));
      }
  }

void sendMessageString(String toSend){
  char buf[25];
  toSend.toCharArray(buf, toSend.length() + 1);
  sendMessage(buf);
}

void sendAll(){ 
  String transmissionId = String(secondsSinceBoot/60) ;
  int noOfRecords = curIndex;
  String toSend = transmissionId + ":C:" + String(noOfRecords) + ":" + deviceSessionId;
  sendMessageString(toSend);
  
  for (int i=0; i<noOfRecords;i++)
  {
  toSend = transmissionId + ":D:"+ String(all[i]);
  queue.push(toSend);
  }
}

void gattServerWriteCallBack(const GattWriteCallbackParams *Handler) {
  uint8_t buf[TXRX_BUF_LEN];
  uint16_t bytesRead, index;

  // Serial.print("Write Handle : ");
  if (Handler->handle == characteristic1.getValueAttribute().getHandle()) {
    ble.readCharacteristicValue(characteristic1.getValueAttribute().getHandle(), buf, &bytesRead);
    String bufString = String((char *) buf);
    //  Serial.println(bufString);
     if (bufString.substring(0,2) == "Go"){
       String curHourString = bufString.substring(3,5); // hours in 24 hour format 
       curHour = curHourString.toInt(); curHour = curHour * 60 * 60;
       
       String awakeHourString = bufString.substring(6,8); // hours in 24 hour format 
       awakeHour = awakeHourString.toInt(); awakeHour = (awakeHour-1) * 60 * 60;
       
       String sleepHourString = bufString.substring(9,11); // hours in 24 hour format 
       sleepHour = sleepHourString.toInt(); sleepHour = (sleepHour+1) * 60 * 60;
             
      sendAll();
    } else if (bufString.substring(0,6) == "Notify"){
      awakeDevice(); // awake 
      showUserNotificationTime = secondsSinceBoot;
      String noOfRecs = bufString.substring(7);
      int no_of_recs = noOfRecs.toInt();
      clearArrayIfSyncSuccess(no_of_recs);
    } else if (bufString.substring(0,4) == "Done"){
      String noOfRecs = bufString.substring(5);
      int no_of_recs = noOfRecs.toInt();
      clearArrayIfSyncSuccess(no_of_recs);
    } 
    
  }
}

void clearArrayIfSyncSuccess(int no_of_recs){
  if (no_of_recs == curIndex)
  {
      curIndex = 0; // reset the index, equivalent to clearing the array
      blinkLED(150);blinkLED(150);
      queue.push("reset CH:" + String(curHour/60/60)+ ":" + String(awakeHour/60/60)+ ":" +String(sleepHour/60/60));
  }
      else 
        queue.push("nr CH:" + String(curHour/60/60)+ ":" + String(awakeHour/60/60)+ ":" +String(sleepHour/60/60));
}


void setup() {
  // put your setup code here, to run once
  // Serial.begin(9600);
  // Serial.println("Start ");
  randomSeed(analogRead(NEOPIXEL_PIN));
  deviceSessionId = String(random(1000));
  
  pinMode(ledPin, OUTPUT);
  pinMode(NEOPIXEL_POWER_PIN, OUTPUT);

  pinMode(SOFT_POT_POWER_PIN, OUTPUT);
  pinMode(SOFT_POT_PIN, INPUT);
  
  //should be on
  digitalWrite(SOFT_POT_POWER_PIN, HIGH);
  // Trigger LED. HIGH means off for BLE nano onboard LED
  digitalWrite(ledPin, HIGH);
  
  // Start timer for reading potentiometer
  ticker_task1.attach(everySecondExecution, 1);

  ble.init();
  ble.onDisconnection(disconnectionCallBack);
  ble.onDataWritten(gattServerWriteCallBack);
  
  // setup adv_data and srp_data
  ble.accumulateAdvertisingPayload(GapAdvertisingData::BREDR_NOT_SUPPORTED);

  
  // uint8_t* mac_address = NULL;
  // ble.gap().getAddress((BLEProtocol::AddressType_t *)BLEProtocol::AddressType::RANDOM_STATIC, mac_address);
  // char* buf_str = (char*) malloc (3);
  // char* buf_ptr = buf_str;
  // buf_ptr += sprintf(buf_str, "%02X", mac_address[0]);
  // *(buf_ptr + 1) = '\0';
  // Serial.println(String(*mac_address));
  String device_name = String(DEVICE_NAME) + String("-") + String(deviceSessionId); 
  char DEVICE_NAME_BUF[19];
  device_name.toCharArray(DEVICE_NAME_BUF, device_name.length() + 1);
  // Serial.println(device_name);
  
  ble.accumulateAdvertisingPayload(GapAdvertisingData::SHORTENED_LOCAL_NAME,(const uint8_t *)DEVICE_NAME_BUF, sizeof(DEVICE_NAME_BUF) - 1);
  ble.accumulateAdvertisingPayload(GapAdvertisingData::COMPLETE_LIST_128BIT_SERVICE_IDS,(const uint8_t *)uart_base_uuid_rev, sizeof(uart_base_uuid_rev));
  // set adv_type
  ble.setAdvertisingType(GapAdvertisingParams::ADV_CONNECTABLE_UNDIRECTED);
  // add service
  ble.addService(uartService);
  
  
  // set device name
  ble.setDeviceName((const uint8_t *)DEVICE_NAME_BUF);
  // set tx power,valid values are -40, -20, -16, -12, -8, -4, 0, 4
  ble.setTxPower(4);
  // set adv_interval, 100ms in multiples of 0.625ms.
  ble.setAdvertisingInterval(1000); //1000 for android
  // set adv_timeout, in seconds
  ble.setAdvertisingTimeout(0);
  
  ble.startAdvertising();
  // Serial.println("start advertising ");

  blinkNeoPixel(4, 1000);
}

void store(String toStore){
  if (curIndex == NO_OBS){
    curIndex = 0;
  }
  // Serial.println("Storing:" + String(curIndex) + ":" + toStore );
  
  all[curIndex] = String(curIndex) + ":" + toStore ;
  curIndex++;
}

void sendQueue(){
  if (ble.getGapState().connected) {
    if (!queue.isEmpty ()){
      sendMessageString(queue.pop());
      blinkLED(150);
    }
  } else {
    while (!queue.isEmpty ())
      queue.pop();
  }
}

void blinkLED(int delayDuration){
  digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)
  delay(delayDuration);                       // wait for a second
  digitalWrite(ledPin, HIGH);    // turn the LED off by making the voltage LOW
}

void blinkNeoPixel(int colorCode, int delayDuration){
  ticker_task1.detach();
  digitalWrite(NEOPIXEL_POWER_PIN, HIGH);
  delay(400); 
  Adafruit_NeoPixel pixels = Adafruit_NeoPixel(NUMPIXELS, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);
  pixels.begin();
  pixels.setBrightness(100);
  // for (int i =0; i< NUMPIXELS; i++)
  if (colorCode == -1)
    pixels.setPixelColor(0, pixels.Color(255,255,0)); //
  if (colorCode == 0)
    pixels.setPixelColor(0, pixels.Color(0,255,0)); //green
  if (colorCode == 1)
    pixels.setPixelColor(0, pixels.Color(0,0,255)); // blue
  if (colorCode == 2)
    pixels.setPixelColor(0, pixels.Color(255,255,255)); // white
  if (colorCode == 3)
    pixels.setPixelColor(0, pixels.Color(190,255,0)); // red
if (colorCode >= 4)
    pixels.setPixelColor(0, pixels.Color(255,0,0)); // red
    
  pixels.show();
  digitalWrite(ledPin, LOW);   // turn the LED on (HIGH is the voltage level)

  delay(delayDuration);  // wait for half a second

  pixels.setPixelColor(0, pixels.Color(0,0,0));
  pixels.show();
  digitalWrite(NEOPIXEL_POWER_PIN, LOW);  
  digitalWrite(ledPin, HIGH);    // turn the LED off by making the voltage LOW
  delay(200);  // wait until delayDuration
  ticker_task1.attach(everySecondExecution, 1);
}

long finalPressTimeStamp = -110;
long inputActivatedTimestamp = -130;

void incrementTimeByOneSecond(){
  secondsSinceBoot += 1; // increase time_since_boot every second 
  curHour += 1;
  if (curHour>=24*3600)
    curHour -= 24*3600;

  // Check if its night (>= sleepHour)). Need to stop every second function and stop advertising until morning. Instead start 
  if (checkIfSleep(curHour, sleepHour, awakeHour)){
    sleepFor(1800);    
  }
}

bool checkIfSleep(int c, int s, int e){
  if  (s <= e)
		return c>=s && (c<e);
	else 
		return c>=s || c<e;
}

long sleptFor = 0;
long sleptFrom = 0;
void sleepFor(long duration){
  sleptFrom = curHour;
  sleptFor = duration;
  blinkLED(150);blinkLED(350);blinkLED(150);
  // Time to sleep
  ticker_task1.detach();
  if (duration>= 25*60)
    ble.stopAdvertising();
  digitalWrite(SOFT_POT_POWER_PIN, LOW);
  ticker_task1.attach(afterAwake, duration);
}

void afterAwake(){
  secondsSinceBoot += sleptFor;
  curHour = sleptFrom+sleptFor;
  awakeDevice();
}

void awakeDevice(){
  digitalWrite(SOFT_POT_POWER_PIN, HIGH);
  ticker_task1.detach();
  ticker_task1.attach(everySecondExecution, 1);
  ble.startAdvertising();
}

bool inputActivated = false;
bool inputReceived = false;


unsigned long lastPressedTime = -120;

void everySecondExecution(){
  incrementTimeByOneSecond();

  int softPotADC = analogRead(SOFT_POT_PIN);
  
  int softPotPosition = map(softPotADC, 0, 1100, 0, 99);
  int ledLightPosition = map(softPotPosition, 0, 95, 0, 5);
  // Serial.println("--" + String(softPotADC) + "| pot pos = "+ softPotPosition + "| LED pos = "+ ledLightPosition);
  

  if (softPotPosition>0){
      if (secondsSinceBoot-lastPressedTime < 20*60){
        blinkNeoPixel(4, 150);
        return;
      }
      if (inputActivated){
        inputReceived = true;
        int minutesSinceBoot = secondsSinceBoot/60;
        String toStore = String(minutesSinceBoot) + ":" + String(softPotPosition);
        store(toStore);
        // queue.push(String(minutesSinceBoot) + ":N:"+String(minutesSinceBoot) + ":" + String(ledLightPosition) + ":" + String(softPotPosition));
        blinkNeoPixel(1, 400); 
        showUserNotificationTime -= 60; // stop notifications
    } else {
        inputActivatedTimestamp = secondsSinceBoot;
        // blinkNeoPixel(4, 150); // Red  for a short duration
        inputActivated = true;
      } 
  }

  if ((secondsSinceBoot - inputActivatedTimestamp > INPUT_ACTIVATE_DURATION) && (inputActivated)){
     // sleep for 10 minutes
     inputActivated = false;
     if (inputReceived){
       inputReceived = false;
      // sleepFor(20*60);
      lastPressedTime = secondsSinceBoot;      
     }
       
  }

  if ((secondsSinceBoot - showUserNotificationTime < USER_NOTIFICATION_DURATION) && !(inputActivated)){
     blinkNeoPixel(0, 300); 
  }

}

void loop() {
  sendQueue();
  ble.waitForEvent();
  
}
