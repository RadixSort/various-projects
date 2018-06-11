/*
 * ps2.h
 *
 *  Created on: 2015-02-03
 *      Author: Daniel
 */

#ifndef PS2_H_
#define PS2_H_

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/alt_irq.h>

#include "audio.h"

#include "system.h"
#include "io.h"
#include "altera_up_avalon_ps2.h"
#include "altera_up_ps2_keyboard.h"
#include "altera_up_ps2_mouse.h"
#include "altera_up_avalon_video_pixel_buffer_dma.h"
#include "altera_up_avalon_video_character_buffer_with_dma.h"

#define WHITE 0xFFFF
#define RED 0xF000
#define YELLOW 0xFFE0
#define BLUE 0x001F
#define GREEN 0x07E0
#define PINK 0xF0F0
#define ORANGE 0xFA00
#define CYAN 0x0FFF
#define LIME 0x8F00
#define GAME_TIME_EASY 37
#define GAME_TIME_HARD 68
#define GAME_SPEED_EASY 3670
#define GAME_SPEED_HARD 1790
#define HIT 1
#define MISS 0
#define drawer_base (volatile int *) 0x00002100
#define notes_base (volatile int *) 0x6000

extern int ps2(void);

#endif /* PS2_H_ */
