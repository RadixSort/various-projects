/*
 * cardreader.h
 *
 *  Created on: 2015-02-03
 *      Author: Daniel
 */

#ifndef CARDREADER_H_
#define CARDREADER_H_

#include <stdio.h>
#include <stdlib.h>
#include <sys/alt_irq.h>
#include <altera_up_sd_card_avalon_interface.h>
#include <altera_up_avalon_audio.h>
#include <altera_up_avalon_audio_and_video_config.h>
#include "altera_up_ps2_mouse.h"
#include "altera_up_avalon_video_pixel_buffer_dma.h"
#include "altera_up_avalon_video_character_buffer_with_dma.h"

#define key1 (volatile char*) 0x00002030
#define key2 (volatile char*) 0x00002020
#define BUFFER_SIZE 96 //DO NOT CHANGE!

extern void av_config_setup(void);
extern int load_song(char* song_name);
void start_songR();
void start_songO();

#endif
