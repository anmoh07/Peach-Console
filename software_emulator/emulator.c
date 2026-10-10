#include <stdint.h>
#include <stdbool.h>

//Signals that can't change
uint16_t pc;
uint16_t memory[32768];


//Console Top


void console_top(bool reset) //leaving for now
{

    

}

//RAM

/*

* ram module for accessing instructions through address

*/
uint16_t ram_module(uint16_t address)
{

    return memory[address >> 1];

}

//DM

//Address checker

//Controller

//GPU

//CPU


typedef struct
{

    uint16_t current_pc;


} cpu_top_data_t; //variable for now


/*

* where the top level cpu conntections live

*/

cpu_top_data_t cpu_top(bool reset, uint16_t instruction) //variable parameters for now
{

    //List of intermediate signals
    cpu_top_data_t cpu_top_data;



    cpu_top_data.current_pc = pc( , reset) //no next pc for right now

    
}


/*

* updates the current pc

*/
uint16_t pc_module(uint16_t next_pc, bool reset)
{
    if (!reset)
        pc = next_pc;
    else    
        pc = 0;


        return pc;
}
