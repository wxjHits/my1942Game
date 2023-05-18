#include <stdint.h>

//pulse0
//#define PULSE0_00                       *((volatile uint8_t *) (0x50004000))    //volatile:防止被优化；uint8_t *:将后面的数字强转为指针；
#define PULSE0_00                       (0x50030000)
#define PULSE0_01                       (0x50030001)
#define PULSE0_10                       (0x50030002)
#define PULSE0_11                       (0x50030003)

//pulse1
#define PULSE1_00                       (0x50030004)
#define PULSE1_01                       (0x50030005)
#define PULSE1_10                       (0x50030006)
#define PULSE1_11                       (0x50030007)

//triangle
#define TRIANGLE_00                     (0x50030008)
#define TRIANGLE_01                     (0x50030009)
#define TRIANGLE_10                     (0x5003000A)
#define TRIANGLE_11                     (0x5003000B)

//noise
#define NOISE_00                        (0x5003000C)
#define NOISE_01                        (0x5003000D)
#define NOISE_10                        (0x5003000E)
#define NOISE_11                        (0x5003000F)

//state
#define STATE                           (0x50030015)

//frame
#define FRAME                           (0x50030017)

//void set_pulse0_00(uint32_t data);
void set_pulse0_00(uint8_t data);
void set_pulse0_01(uint8_t data);
void set_pulse0_10(uint8_t data);
void set_pulse0_11(uint8_t data);

void set_pulse1_00(uint8_t data);
void set_pulse1_01(uint8_t data);
void set_pulse1_10(uint8_t data);
void set_pulse1_11(uint8_t data);

void set_triangle_00(uint8_t data);
void set_triangle_01(uint8_t data);
void set_triangle_10(uint8_t data);
void set_triangle_11(uint8_t data);

void set_noise_00(uint8_t data);
void set_noise_01(uint8_t data);
void set_noise_10(uint8_t data);
void set_noise_11(uint8_t data);

void set_state(uint8_t data);

void set_frame(uint8_t data);
