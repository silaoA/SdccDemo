#include "common.h"

/**********************************************************************************
������  :  void Delay(unsigned int unMs);
��  ��  :  unMs--Ҫ��ʱ��ʱ��(����)
��  ��  �� ��
��  ��  :  ��ʱ������(����ֵ) 
**********************************************************************************/
void Delay(unsigned int unMs)
{
    //unsigned int i = 500;
	unsigned char i = 250;

    while (unMs--)
    {
        while (i--)
		{
			__asm
            nop
			__endasm;
		}
    }	    
}
