#include "enemyBullet.h"

extern const uint8_t ENEMY_BULLETS_NUMMAX;

const uint8_t ANGLE_NUMMAX=10;
const int16_t sin_array[ANGLE_NUMMAX]={1,2,2,2,3,4,4,4,5,5};
const int16_t cos_array[ANGLE_NUMMAX]={4,4,4,4,4,3,2,2,1,0};
const float tan_array[ANGLE_NUMMAX]={0.00,0.18,0.36,0.58,0.84,1.19,1.73,2.75,5.67,200};

void enmey_BulletInit(BULLETType* bullet){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++)
        (bullet+i)->liveFlag=0;
}

void s_grey_createOneEnmeyBullet(BULLETType* bullet,S_GREY_PLANEType* plane,MYPLANEType* myplane){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if((bullet+i)->liveFlag==0){
            (bullet+i)->PosX=plane->PosX+8;
            (bullet+i)->PosY=plane->PosY-8;
            (bullet+i)->liveFlag=1;

            int16_t enemy_x = (plane->PosX);
            int16_t enemy_y = (plane->PosY);
            int16_t myplane_x = myplane->PosX;
            int16_t myplane_y = myplane->PosY;

            int16_t PosX_SUB = myplane->PosX-(plane->PosX);
            int16_t PosY_SUB = myplane->PosY-(plane->PosY);
            float PosX_SUB_Abs= (PosX_SUB<0)?(-PosX_SUB):PosX_SUB;//绝对值
            float PosY_SUB_Abs= (PosY_SUB<0)?(-PosY_SUB):PosY_SUB;//绝对值
            float tanValue = PosY_SUB_Abs/PosX_SUB_Abs;
            for(int j=0;j<ANGLE_NUMMAX;j++){
                if(tan_array[j]-tanValue>=0){
                    (bullet+i)->PosX_ADD=cos_array[j];
                    (bullet+i)->PosY_ADD=sin_array[j];
                    if(PosX_SUB<0)
                        (bullet+i)->PosX_ADD=-(bullet+i)->PosX_ADD;
                    if(PosY_SUB<0)
                        (bullet+i)->PosY_ADD=-(bullet+i)->PosY_ADD;
                    break;
                }
            }
            break;
        }
    }
}
void updateEnemyBulletData(BULLETType* bullet){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if((bullet+i)->FpsCnt==4){
            (bullet+i)->FpsCnt=0;
            if((bullet+i)->liveFlag!=0){
                (bullet+i)->PosY+=(bullet+i)->PosY_ADD;
                (bullet+i)->PosX+=(bullet+i)->PosX_ADD;
                if((bullet+i)->PosY>BOTTOM_LINE||(bullet+i)->PosY<TOP_LINE){//超出边界
                    (bullet+i)->liveFlag=0;
                }
                else if((bullet+i)->PosX>RIGHT_LINE||(bullet+i)->PosX<LEFT_LINE){//超出边界
                    (bullet+i)->liveFlag=0;
                }
            }
        }
        else
            (bullet+i)->FpsCnt+=1;
    }
}

void enmeyBulletDraw(BULLETType* bullet,uint8_t* spriteRamAddr){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if((bullet+i)->liveFlag!=0){
            writeOneSprite((*spriteRamAddr),(bullet+i)->PosX,(bullet+i)->PosY,0x30,0x10);
            (*spriteRamAddr)+=1;
        }
    }
}
