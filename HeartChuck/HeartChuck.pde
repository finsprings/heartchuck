//
// nunchuck header file from WiichuckDemo;
// see http://todbot.com/blog/2008/02/18/wiichuck-wii-nunchuck-adapter-available/
//
// OpenHeart LED code derived from the OpenHeart Programmer at:
// http://www.jimmieprodgers.com/OpenHeartProgrammer.html
//
#include <Wire.h>
#include "nunchuck_funcs.h"

const int OH_NUM_LEDS = 27;

// Mapping of OpenHeart pins to Arduino pins
const int OH_PIN1 = 10;
const int OH_PIN2 = 11;
const int OH_PIN3 = 8;
const int OH_PIN4 = 9;
const int OH_PIN5 = 12;
const int OH_PIN6 = 13;

// Mapping for each OpenHeart LED to its positive and negative pins
// (the OpenHeart uses charlieplexing to minimize the number of pins needed)
const int OH_LED_TO_PINS[OH_NUM_LEDS][2] =
{
  { OH_PIN3, OH_PIN1 },
  { OH_PIN1, OH_PIN3 },
  { OH_PIN2, OH_PIN1 },
  { OH_PIN1, OH_PIN2 },
  { OH_PIN3, OH_PIN4 },
  { OH_PIN4, OH_PIN1 },
  { OH_PIN1, OH_PIN4 },
  { OH_PIN1, OH_PIN5 },
  { OH_PIN6, OH_PIN1 },
  { OH_PIN1, OH_PIN6 },
  { OH_PIN6, OH_PIN2 },
  { OH_PIN4, OH_PIN3 },
  { OH_PIN3, OH_PIN5 },
  { OH_PIN5, OH_PIN3 },
  { OH_PIN5, OH_PIN1 },
  { OH_PIN2, OH_PIN5 },
  { OH_PIN5, OH_PIN2 },
  { OH_PIN2, OH_PIN6 },
  { OH_PIN4, OH_PIN5 },
  { OH_PIN5, OH_PIN4 },
  { OH_PIN3, OH_PIN2 },
  { OH_PIN6, OH_PIN5 },
  { OH_PIN5, OH_PIN6 },
  { OH_PIN4, OH_PIN6 },
  { OH_PIN2, OH_PIN3 },
  { OH_PIN6, OH_PIN4 },
  { OH_PIN4, OH_PIN2 }
};

// ranges derived from observing the joystick values displayed
// by nunchuck_print_data(); note that the actual observed
// ranges are a little larger than these, but using the actual
// ranges makes it very hard to get to the LEDs in the corners.
const int JOY_Y_MIN = 40;
const int JOY_Y_MAX = 200;
const int JOY_X_MIN = 40;
const int JOY_X_MAX = 200;

// pretend the LEDs on the OpenHeart are in a rectangular 7x6 grid
const int GRID_X_MIN = 0;
const int GRID_X_MAX = 6;
const int GRID_Y_MIN = 0;
const int GRID_Y_MAX = 5;

// map from the notional 7x6 grid to the actual
// heart-shaped LED grid of the OpenHeart;
// this is used to decide which LED to turn on
// for every position of the notional grid, and
// since the actual grid is a subset you can
// see repeated LEDs in this mapping
const int GRID_TO_LED[GRID_Y_MAX+1][GRID_X_MAX+1] =
{
  {  0,   0,   1,   1,   2,   3,   3  },
  {  4,   5,   6,   7,   8,   9,  10  },
  { 11,  12,  13,  14,  15,  16,  17  },
  { 18,  18,  19,  20,  21,  22,  22  },
  { 23,  23,  23,  24,  25,  25,  25  },
  { 26,  26,  26,  26,  26,  26,  26  }
};

// the LED position the joystick was last at
int curLed = -1;

void setup()
{
  nunchuck_setpowerpins();
  nunchuck_init();
  oh_all_off();
}

void loop()
{
  nunchuck_get_data();

  // use map() to convert from the joystick scale to the grid scale.
  // the constrain is necessary because our joystick scale is a subset
  // of the actual joystick scale (see description at the top of the file).
  // note that map() can invert a scale, so we intentionally map
  // JOY_Y_MIN->JOY_Y_MAX to GRID_Y_MAX->GRID_Y_MIN, since the Y value
  // of the joystick increases from bottom to top and we want the Y
  // value in our grid to increase from top to bottom
  const int x = constrain(map(nunchuck_joyx(),
                              JOY_X_MIN, JOY_X_MAX,
                              GRID_X_MIN, GRID_X_MAX),
                          GRID_X_MIN,
                          GRID_X_MAX);
  const int y = constrain(map(nunchuck_joyy(),
                              JOY_Y_MIN, JOY_Y_MAX,
                              GRID_Y_MAX, GRID_Y_MIN),
                          GRID_Y_MIN,
                          GRID_Y_MAX);
  const int newLed = GRID_TO_LED[y][x];

  // only bother to update the OpenHeart if the LED
  // we're at is different from the last one; if we
  // didn't do this we'd be turning the LED on and
  // off so fast it would just appear off.
  if (newLed != curLed)
  { 
    curLed = newLed;       
    oh_all_off();
    oh_led_on(curLed);
  }
}

void oh_led_on(const int led)
{
  const int posPin = OH_LED_TO_PINS[led][0];
  const int negPin = OH_LED_TO_PINS[led][1];
  pinMode(posPin, OUTPUT);
  pinMode(negPin, OUTPUT);
  digitalWrite(posPin, HIGH);
  digitalWrite(negPin, LOW);
}

void oh_all_off()
{
  pinMode(OH_PIN1, INPUT);
  pinMode(OH_PIN2, INPUT);
  pinMode(OH_PIN3, INPUT);
  pinMode(OH_PIN4, INPUT);
  pinMode(OH_PIN5, INPUT);
  pinMode(OH_PIN6, INPUT);
}
