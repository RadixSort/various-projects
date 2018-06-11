#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/alt_irq.h>
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
#define GAME_TIME 20
#define HIT 1
#define MISS 0
#define drawer_base (volatile int *) 0x00002100

int main()
{
	// Initialization code for the character buffer
	alt_up_char_buffer_dev *char_buffer = alt_up_char_buffer_open_dev("/dev/char_drawer");
	alt_up_char_buffer_init(char_buffer);

	// Initialization code for the pixel buffer
	alt_up_pixel_buffer_dma_dev* pixel_buffer = alt_up_pixel_buffer_dma_open_dev("/dev/pixel_buffer_dma");
	alt_up_pixel_buffer_dma_change_back_buffer_address(pixel_buffer, PIXEL_BUFFER_BASE);
	alt_up_pixel_buffer_dma_swap_buffers(pixel_buffer);
	while (alt_up_pixel_buffer_dma_check_swap_buffers_status(pixel_buffer));
	alt_up_pixel_buffer_dma_clear_screen(pixel_buffer, 0);

	// Initialization code for the PS/2 keyboard
	alt_up_ps2_dev * ps2 = alt_up_ps2_open_dev("/dev/ps2_0");
	alt_up_ps2_init(ps2);

	// Variables go here
	KB_CODE_TYPE code_type;
	unsigned char buf;
	char ascii;
	int i;
	int Game[5];
	int score;

	DrawGameScreen(pixel_buffer, char_buffer);
	printf("Initialization successful...\n");

	while (1) {
		if (decode_scancode(ps2, &code_type, &buf, &ascii) >= 0) {
			printf("Keyboard code received: %d \n", ascii);
		}

		if (ascii == 90) {
			ReadySequence(char_buffer);
			score = GenerateGame(pixel_buffer, char_buffer, ps2);
			EndGame(pixel_buffer, char_buffer, score);
			system("PAUSE");
		}
	}

	return 0;
}

void DrawGameScreen(pixel_buffer, char_buffer) {
	// This draws the 8 lanes
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,0,40,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "A", 11, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 55,0,55,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "S", 15, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 70,0,70,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "D", 19, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 85,0,85,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "F", 23, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 100,0,100,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "H", 26, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 115,0,115,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "J", 30, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 130,0,130,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "K", 34, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 145,0,145,240,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "L", 38, 56);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 160,0,160,240,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,212,160,212,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,220,160,220,0xFFFF,0);

	// This draws the high score box
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,20,220,20,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,60,220,60,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,20,170,60,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 220,20,220,60,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "HIGH SCORE:", 43, 6);
	UpdateHighScore(char_buffer, 0);

	// This draws the combo count box
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,70,220,70,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,110,220,110,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,70, 170,110,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 220,70,220,110,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "COMBO:", 43, 18);
	UpdateCombo(char_buffer, 0, 2);

	alt_up_char_buffer_string(char_buffer, "WELCOME TO R.A.V.E.!", 43, 30);
	alt_up_char_buffer_string(char_buffer, "PRESS Z TO START THE GAME!", 43, 32);
}

int GenerateGame(pixel_buffer, char_buffer, ps2) {
	int Game[GAME_TIME];
	int Lanes[8] = {41,56,71,86,101,116,131,146};
	int Keys[8] = {65,83,68,70,72,74,75,76};
	int Color[8] = {RED,YELLOW,GREEN,BLUE,PINK,ORANGE,LIME,CYAN};
	int i, j;
	int high_score = 0;
	int combo = 0;
	KB_CODE_TYPE code_type_game;
	unsigned char buf_game;
	char ascii_game;

	for(j=0; j<GAME_TIME; j++) {
		Game[j] = rand()%8;
		for (i=0; i<240; i++) {
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, Lanes[Game[j]],i,Lanes[Game[j]]+13,i+5,Color[Game[j]],0);
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, Lanes[Game[j]],i,Lanes[Game[j]]+13,i,0x0000,0);
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,212,160,212,0xFFFF,0);
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,220,160,220,0xFFFF,0);
			decode_scancode(ps2, &code_type_game, &buf_game, &ascii_game);
			if(i > 212 && i < 220) {
				if (ascii_game == Keys[Game[j]]) {
					printf("Hitbox detected!\n");
					FlashBox(pixel_buffer, Lanes[Game[j]], i,Lanes[Game[j]]+13, i+5, Color[Game[j]], Game[j]);
					high_score = high_score+5;
					combo = combo+1;
					UpdateHighScore(char_buffer, high_score);
					UpdateCombo(char_buffer, combo, HIT);
					break;
				} else {
					combo = 0;
					UpdateCombo(char_buffer, combo, MISS);
				}
			}
			usleep(6000);
		}
	}

	return high_score;
}

void UpdateHighScore(char_buffer, high_score) {
	int FIFTH_DIGIT, FOURTH_DIGIT, THIRD_DIGIT, SECOND_DIGIT, FIRST_DIGIT;
	char hs[] = "00000";

	FIFTH_DIGIT = high_score/10000;
	FOURTH_DIGIT = (high_score/1000) % 10;
	THIRD_DIGIT = (high_score/100) % 10;
	SECOND_DIGIT = (high_score/ 10) % 10;
	FIRST_DIGIT = high_score % 10;
	hs[0] = FIFTH_DIGIT+48;
	hs[1] = FOURTH_DIGIT+48;
	hs[2] = THIRD_DIGIT+48;
	hs[3] = SECOND_DIGIT+48;
	hs[4] = FIRST_DIGIT+48;
	alt_up_char_buffer_string(char_buffer, hs, 44, 8);
	return;
}

void UpdateCombo(char_buffer, combo, status) {
	int FIFTH_DIGIT, FOURTH_DIGIT, THIRD_DIGIT, SECOND_DIGIT, FIRST_DIGIT;
	char hs[] = "00000";

	if (status == HIT) {
		alt_up_char_buffer_string(char_buffer, "NICE!", 44, 22);
	} else if (status == MISS) {
		alt_up_char_buffer_string(char_buffer, "MISS!", 44, 22);
	} else {

	}

	FIFTH_DIGIT = combo/10000;
	FOURTH_DIGIT = (combo/1000) % 10;
	THIRD_DIGIT = (combo/100) % 10;
	SECOND_DIGIT = (combo/ 10) % 10;
	FIRST_DIGIT = combo % 10;
	hs[0] = FIFTH_DIGIT+48;
	hs[1] = FOURTH_DIGIT+48;
	hs[2] = THIRD_DIGIT+48;
	hs[3] = SECOND_DIGIT+48;
	hs[4] = FIRST_DIGIT+48;
	alt_up_char_buffer_string(char_buffer, hs, 44, 20);
	return;
}

void ReadySequence(char_buffer) {
	alt_up_char_buffer_string(char_buffer, "GAME STARTING...          ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "READY,                    ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "SET,                      ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "GO!!                      ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "GAME IN PROGRESS!         ", 43, 32);
	return;
}

void FlashBox (pixel_buffer, x1, y1, x2, y2, color, lane) {
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, x1, y1, x2, y2, WHITE, 0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15),214,54+(lane*15),219,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+1,209,54+(lane*15)-1,214,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+2,204,54+(lane*15)-2,209,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+3,199,54+(lane*15)-3,204,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+4,194,54+(lane*15)-4,199,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+5,189,54+(lane*15)-5,194,WHITE,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15)+6,184,54+(lane*15)-6,189,WHITE,0);
	usleep(100000);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 41+(lane*15),0,54+(lane*15),219,0x0000,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40+(lane*15),212,55+(lane*15),212,0xFFFF,0);
}

void EndGame(pixel_buffer, char_buffer, high_score) {
	alt_up_char_buffer_string(char_buffer, "GAME FINISHED!               ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "                          ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS                ", 43, 38);
	usleep(500000);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS.               ", 43, 38);
	usleep(500000);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS..              ", 43, 38);
	usleep(500000);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS...             ", 43, 38);
	usleep(500000);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS....            ", 43, 38);
	usleep(500000);
	alt_up_char_buffer_string(char_buffer, "YOUR GRADE IS.....           ", 43, 38);

	if (high_score == (GAME_TIME*5)){
		alt_up_char_buffer_string(char_buffer, "SS", 46, 40);
		alt_up_char_buffer_string(char_buffer, "FULL COMBO!!!!!         ", 43, 42);
	} else if (high_score > (GAME_TIME*5) * 3/4) {
		alt_up_char_buffer_string(char_buffer, "A ", 46, 40);
		alt_up_char_buffer_string(char_buffer, "EXCELLENT!!!           ", 43, 42);
	} else if (high_score > (GAME_TIME*5) * 2/4) {
		alt_up_char_buffer_string(char_buffer, "B ", 46, 40);
		alt_up_char_buffer_string(char_buffer, "AWESOME!!!             ", 43, 42);
	} else if (high_score > (GAME_TIME*5) * 1/4) {
		alt_up_char_buffer_string(char_buffer, "C ", 46, 40);
		alt_up_char_buffer_string(char_buffer, "GOOD JOB!!             ", 43, 42);
	} else {
		alt_up_char_buffer_string(char_buffer, "F ", 46, 40);
		alt_up_char_buffer_string(char_buffer, "BETTER LUCK NEXT TIME!!", 43, 42);
	}
}
