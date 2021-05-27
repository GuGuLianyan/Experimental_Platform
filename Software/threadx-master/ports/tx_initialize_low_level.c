#include "tx_api.h"
#include "tx_initialize.h"
#include "tx_thread.h"
#include "tx_timer.h"

extern void _tx_timer_interrupt(void);


//VOID   _tx_initialize_low_level(VOID)
//{
	
//}


void SysTick_Handler(void)
{
	_tx_timer_interrupt();
}