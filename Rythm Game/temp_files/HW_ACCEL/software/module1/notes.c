#include "ps2.h"


void draw_note( int notes_vector) 
{
	int i;

	int rand_val;
	printf("Hi");
	srand(time(NULL));

	rand_val = rand() % 32;
	IOWR_32DIRECT(notes_base,0,notes_vector); // Set Notes
	printf( "Note sent \n");
	IOWR_32DIRECT(notes_base,20,1);  // Start drawing
	while(IORD_32DIRECT(drawer_base,20)==0); // wait until done */

	return;
}

