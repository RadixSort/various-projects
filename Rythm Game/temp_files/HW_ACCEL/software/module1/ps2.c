#include "ps2.h"
#include "notes.c"

int ps2()
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
	int difficulty = 0;

	DrawGameScreen(pixel_buffer, char_buffer);
	printf("Initialization successful...\n");
	clearScreen(char_buffer);


	//Main loop for starting and ending the game
	while (1) {
		ascii = 50;

		if (decode_scancode(ps2, &code_type, &buf, &ascii) >= 0)
			printf("Keyboard code received: %d \n", ascii);

		if (ascii == 52){
			clearScreen(char_buffer);
			difficulty = 0;
			alt_up_char_buffer_string(char_buffer, ">EASY              HARD", 43, 40);
		} else if (ascii == 54){
			clearScreen(char_buffer);
			difficulty = 1;
			alt_up_char_buffer_string(char_buffer, " EASY             >HARD", 43, 40);
		} else if (ascii == 90 && difficulty == 0) {
			score = 0;
			clearScreen(char_buffer);
			ReadySequence(char_buffer);
			score += GenerateGame(pixel_buffer, char_buffer, ps2, GAME_TIME_EASY, GAME_SPEED_EASY);
			load_song("end.wav");
			play_songO();
			EndGame(pixel_buffer, char_buffer, score, GAME_TIME_EASY);
		} else if (ascii == 90 && difficulty == 1){
			score = 0;
			clearScreen(char_buffer);
			ReadySequence(char_buffer);
			score += GenerateGame(pixel_buffer, char_buffer, ps2, GAME_TIME_HARD, GAME_SPEED_HARD);
			load_song("end.wav");
			play_songO();
			EndGame(pixel_buffer, char_buffer, score, GAME_TIME_HARD);
			difficulty = 0;
		} else if (ascii == 82){
			clearScreen(char_buffer);
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
	alt_up_char_buffer_string(char_buffer, "SCORE:", 43, 6);
	UpdateHighScore(char_buffer, 0);

	// This draws the combo count box
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,70,220,70,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,110,220,110,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 170,70, 170,110,0xFFFF,0);
	alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 220,70,220,110,0xFFFF,0);
	alt_up_char_buffer_string(char_buffer, "COMBO:", 43, 18);
	UpdateCombo(char_buffer, 0, 2);

}

int GenerateGame(pixel_buffer, char_buffer, ps2, game_time, game_speed) {
	int Game[game_time];
	int Lanes[8] = {41,56,71,86,101,116,131,146};
	int Keys[8] = {65,83,68,70,72,74,75,76};
	int Color[8] = {RED,YELLOW,GREEN,BLUE,PINK,ORANGE,LIME,CYAN};
	int Translator[8] = {1,2,4,8,16,32,64,128}; // for drawing with hw
	int i, j;
	int high_score = 0;
	int combo = 0;
	KB_CODE_TYPE code_type_game;
	unsigned char buf_game;
	char ascii_game;

	//so basically, I gotta fuck around with this
	for(j=0; j<game_time; j++) {
		Game[j] = rand()%8; // get a random lane to draw in of the eight, use for random colours too!
		draw_note( Translator[Game[j]] );
		for (i=0; i<240; i++) {
			//alt_up_pixel_buffer_dma_draw_box(pixel_buffer, Lanes[Game[j]],i,Lanes[Game[j]]+13,i+5,Color[Game[j]],0); //draw the box
			//alt_up_pixel_buffer_dma_draw_box(pixel_buffer, Lanes[Game[j]],i,Lanes[Game[j]]+13,i,0x0000,0); // erase the row of px above
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,212,160,212,0xFFFF,0); //preserve the white lines
			alt_up_pixel_buffer_dma_draw_box(pixel_buffer, 40,220,160,220,0xFFFF,0); // uhuh
			decode_scancode(ps2, &code_type_game, &buf_game, &ascii_game); // grab any kb presses

			//hitbox detection here, kids
			if(i > 212 && i < 220) {
				if (ascii_game == Keys[Game[j]]) {
					printf("Hitbox detected!\n");
					FlashBox(pixel_buffer, Lanes[Game[j]], i,Lanes[Game[j]]+13, i+5, Color[Game[j]], Game[j]); // keep this for pretty fx. this shit draws the fire
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
			usleep(game_speed);
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

void clearScreen(char_buffer){
	alt_up_char_buffer_string(char_buffer, "WELCOME TO R.A.V.E.!", 43, 30);
	alt_up_char_buffer_string(char_buffer, "SET DIFFICULTY USING ARROW KEYS,", 43, 34);
	alt_up_char_buffer_string(char_buffer, "PRESS Z TO START THE GAME!", 43, 36);
	alt_up_char_buffer_string(char_buffer, "                          ", 43, 38);
	alt_up_char_buffer_string(char_buffer, "                          ", 43, 42);
	alt_up_char_buffer_string(char_buffer, ">EASY              HARD", 43, 40);
	alt_up_char_buffer_string(char_buffer, "                           ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "                           ", 43, 44);
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
	alt_up_char_buffer_string(char_buffer, "                                 ", 43, 40);
	alt_up_char_buffer_string(char_buffer, "LOADING GAME...               ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "                                 ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "                                ", 43, 36);
	load_song("game.wav");
	play_songR();
	alt_up_char_buffer_string(char_buffer, "GAME STARTING...              ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "READY                         ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "SET                           ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "GO!!                          ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "GAME IN PROGRESS!             ", 43, 32);
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

void EndGame(pixel_buffer, char_buffer, high_score, game_time) {
	alt_up_char_buffer_string(char_buffer, "           ", 44, 22);
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

	if (high_score == (game_time*5)){
		alt_up_char_buffer_string(char_buffer, "    SS", 43, 40);
		alt_up_char_buffer_string(char_buffer, "FULL COMBO!!!!!         ", 43, 42);
	} else if (high_score > (game_time*5) * 3/4) {
		alt_up_char_buffer_string(char_buffer, "    A ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "EXCELLENT!!!           ", 43, 42);
	} else if (high_score > (game_time*5) * 2/4) {
		alt_up_char_buffer_string(char_buffer, "    B ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "AWESOME!!!             ", 43, 42);
	} else if (high_score > (game_time*5) * 1/4) {
		alt_up_char_buffer_string(char_buffer, "    C ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "GOOD JOB!!             ", 43, 42);
	} else {
		alt_up_char_buffer_string(char_buffer, "    F ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "BETTER LUCK NEXT TIME!!", 43, 42);
	}
	alt_up_char_buffer_string(char_buffer, "PRESS R TO REPLAY~!        ", 43, 44);


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

void clearScreen(char_buffer){
	alt_up_char_buffer_string(char_buffer, "WELCOME TO R.A.V.E.!", 43, 30);
	alt_up_char_buffer_string(char_buffer, "SET DIFFICULTY USING ARROW KEYS,", 43, 34);
	alt_up_char_buffer_string(char_buffer, "PRESS Z TO START THE GAME!", 43, 36);
	alt_up_char_buffer_string(char_buffer, "                          ", 43, 38);
	alt_up_char_buffer_string(char_buffer, "                          ", 43, 42);
	alt_up_char_buffer_string(char_buffer, ">EASY              HARD", 43, 40);
	alt_up_char_buffer_string(char_buffer, "                           ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "                           ", 43, 44);
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
	alt_up_char_buffer_string(char_buffer, "                                 ", 43, 40);
	alt_up_char_buffer_string(char_buffer, "LOADING GAME...               ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "                                 ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "                                ", 43, 36);
	load_song("game.wav");
	play_songR();
	alt_up_char_buffer_string(char_buffer, "GAME STARTING...              ", 43, 32);
	alt_up_char_buffer_string(char_buffer, "READY                         ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "SET                           ", 43, 34);
	usleep(1000000);
	alt_up_char_buffer_string(char_buffer, "GO!!                          ", 43, 34);
	alt_up_char_buffer_string(char_buffer, "GAME IN PROGRESS!             ", 43, 32);
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

void EndGame(pixel_buffer, char_buffer, high_score, game_time) {
	alt_up_char_buffer_string(char_buffer, "           ", 44, 22);
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

	if (high_score == (game_time*5)){
		alt_up_char_buffer_string(char_buffer, "    SS", 43, 40);
		alt_up_char_buffer_string(char_buffer, "FULL COMBO!!!!!         ", 43, 42);
	} else if (high_score > (game_time*5) * 3/4) {
		alt_up_char_buffer_string(char_buffer, "    A ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "EXCELLENT!!!           ", 43, 42);
	} else if (high_score > (game_time*5) * 2/4) {
		alt_up_char_buffer_string(char_buffer, "    B ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "AWESOME!!!             ", 43, 42);
	} else if (high_score > (game_time*5) * 1/4) {
		alt_up_char_buffer_string(char_buffer, "    C ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "GOOD JOB!!             ", 43, 42);
	} else {
		alt_up_char_buffer_string(char_buffer, "    F ", 43, 40);
		alt_up_char_buffer_string(char_buffer, "BETTER LUCK NEXT TIME!!", 43, 42);
	}
	alt_up_char_buffer_string(char_buffer, "PRESS R TO REPLAY~!        ", 43, 44);
}
