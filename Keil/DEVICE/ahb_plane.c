#include "ahb_plane.h"
#include "spriteRam.h"

void ahb_plane_Init(uint8_t Init_X,uint8_t Init_Y){
	AHBPLANE->update_clk=0;
	AHBPLANE->Hit=0;
	AHBPLANE->create=0;
	AHBPLANE->Init_POS_X=Init_X;
	AHBPLANE->Init_POS_Y=Init_Y;
	AHBPLANE->Init_HP=3;
	AHBPLANE->Init_Y_TURN0=Init_Y+50;
	AHBPLANE->Init_Y_TURN1=Init_Y+50+20;
	AHBPLANE->Init_Y_TURN2=Init_Y+50+20+40;
	AHBPLANE->Init_Y_TURN3=Init_Y+50+20+40+20;
	AHBPLANE->Init_X_TURN0=Init_X+20;
	AHBPLANE->Init_X_TURN1=Init_X+20+80;
}

void ahb_plane_create(void){
	AHBPLANE->create=1;
	AHBPLANE->create=0;
}
void ahb_plane_Update(void){
	AHBPLANE->update_clk=1;
	AHBPLANE->Hit=0;
	AHBPLANE->update_clk=0;
}
void ahb_plane_showAttitude(void){
	uint8_t posx = AHBPLANE->PosX_out;
	uint8_t posy = AHBPLANE->PosY_out;
	uint8_t atti = AHBPLANE->Attitude;
	writeOneSprite(0,AHBPLANE->PosX_out,AHBPLANE->PosY_out,AHBPLANE->Attitude,0x10);
}
