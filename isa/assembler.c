#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

typedef enum 
{
    INVALID = 0,
    ADD, SUB, AND, OR, XOR, SLT, SLTU, ADDI,  //ALU
    LOADI, LOAD, STORE, //Memory
    BEQ, BNE, BLT, //BRANCH
    JMP_REL12, //last non special
    JMP, CALL, RET, HALT, RES1, MUL, XORI, SHL, SHR, PUSH, POP, RES2, SHLI, SHRI, RES3, DIV //Special
} opcode_t;

typedef struct
{

    opcode_t opcode;
    char* string_opcode;
    uint16_t len;


} opcode_data;

static const opcode_data OPCODE_TABLE[64] = 
{
    [4]  = {AND, "AND", 3},
    [6]  = {MUL, "MUL", 3},
    [8]  = {SHR, "SHR", 3},
    [9]  = {SHRI, "SHRI", 4},
    [17] = {BLT, "BLT", 3},
    [18] = {SHL, "SHL", 3},
    [19] = {SHLI, "SHLI", 4},
    [21] = {CALL, "CALL", 4},
    [23] = {JMP, "JMP", 3},
    [26] = {HALT, "HALT", 4},
    [29] = {JMP_REL12, "JMP_REL12", 9},
    [33] = {POP, "POP", 3},
    [34] = {SLT, "SLT", 3},
    [35] = {SLTU, "SLTU", 4},
    [39] = {STORE, "STORE", 5},
    [40] = {BEQ, "BEQ", 3},
    [41] = {PUSH, "PUSH", 4},
    [46] = {BNE, "BNE", 3},
    [48] = {ADD, "ADD", 3},
    [49] = {ADDI, "ADDI", 4},
    [50] = {SUB, "SUB", 3},
    [51] = {RET, "RET", 3},
    [53] = {OR, "OR", 2},
    [55] = {LOAD, "LOAD", 4},
    [56] = {LOADI, "LOADI", 5},
    [59] = {XOR, "XOR", 3},
    [60] = {XORI, "XORI", 4},
    [63] = {DIV, "DIV", 3}
};

//prototypes

uint16_t assemble(char fields[4][10]);
uint16_t decoder(opcode_t opcode, char* field1, char* field2, char* field3);
uint16_t immediate_checker(opcode_t opcode, char* immediate_str);
uint16_t reg_string_to_num(char* field);
opcode_t tokenize(char* opcode);
uint16_t strings_equal(const char* str1, uint16_t len1, const char* str2, uint16_t len2);
uint8_t hash_opcode(const char *str, size_t len);


/*

* Reads .asm file line by line for instructions, newline seperating instructions
* Records up to four fields, giving a value for each field or writing
* Calls assemble function
* Writes instructions to .hex file
* 

*/
int main(void)
{

    uint16_t binary_instruction;
    FILE *assembly = fopen("program.asm", "r");
    FILE *binary = fopen("binary.hex", "wb");

    if (assembly == NULL) 
    {
        perror("Could not open file");
        return 1;
    }
    if (binary == NULL) 
    {
        perror("Could not create file");
        return 1;
    }

    char fields[4][10]; 
    int counter = 0; //which field counter

    int ch = 0; //current character
    int i = 0; //indexing through fields
    int has_content = 0; //checks whether there is unwritten content to handle cases where last character is not a new line

    while (1) 
    {

        //read
        ch = fgetc(assembly);
        
        if (ch == EOF)
        {
            
            if (ferror(assembly))
            {
                perror("Read Error");
                return 1;
            }

            if (counter < 4)
            {
                fields[counter][i] = '\0';
            }

            while (counter < 3)
            {
                counter++;
                fields[counter][0] = '\0'; 
            }

            if (has_content == 1)
            {

                //assemble
                binary_instruction = assemble(fields);
                //write
                fprintf(binary, "%04X\n", (unsigned)binary_instruction);
            }

            break;
        }
        else if (ch == ' ')
        {
            if (i == 0)
            {
                continue;
            }

            if (counter < 4)
            {
                fields[counter][i] = '\0';
            }  
            counter++;
            i = 0;
            continue;
        }
        else if (ch == '\n')
        {
            if (counter < 4)
            {
                fields[counter][i] = '\0';
            }

            while (counter < 3)
            {
                counter++;
                fields[counter][0] = '\0'; 
            }

            counter = 0;
            i = 0;

            if (has_content == 0)
            {
                continue;
            }

            //assemble
            binary_instruction = assemble(fields);
            //write
            fprintf(binary, "%04X\n", (unsigned)binary_instruction);

            has_content = 0;
            continue;
        }
        else if (ch == '\r')
        {
            continue;
        }
        else
        {
            has_content = 1;

            if ((counter < 0) || (counter > 3))
            {
                printf("Five fields on a line, invalid assembly file");
                return 1;
            }
            else if ((counter > 0) && (counter <= 3))
            {
                if (i == 6) 
                {
                    printf("invalid assembly, too many characters");
                    return 1;
                }
            }
            else if (counter == 0)
            {
                if (i == 9) 
                {
                    printf("invalid assembly, too many characters");
                    return 1;
                }
            }

            fields[counter][i] = ch;
            i++;
            continue;
        }   
    }


    fclose(binary);
    fclose(assembly);

}

/*

* Takes in four fields
* Matches fields to instruction encodings
* Checks if instructions are valid, if so returns
* If not valid, calls error

*/
uint16_t assemble(char fields[4][10])
{

    opcode_t opcode = tokenize(fields[0]); //turn char[1] into enum tokens

    return decoder(opcode, fields[1], fields[2], fields[3]); //check by enum for proper arguements and turn that into bits, that are then shited to an instruction

}

uint16_t decoder(opcode_t opcode, char* field1, char* field2, char* field3)
{
    uint16_t instruction = 0;
    uint16_t byte0 = 0;
    uint16_t byte1 = 0;
    uint16_t byte2 = 0;
    uint16_t byte3 = 0;
    uint16_t immediate = 0;
    uint16_t expected_fields = 0;

    byte0 = (uint16_t) opcode - 1;
    if ( (uint16_t) opcode > 15) //remeber, enum opcode is shifted up by 1
    {
        byte0 = 15;
        byte2 = (uint16_t) opcode % 16;
    } 

  
    switch (opcode)
    {
        // ALU
        case ADD:
        case SUB:
        case AND:
        case OR:
        case XOR:
        case SLT:
        case SLTU:
        {

            byte1 = reg_string_to_num(field1);
            byte2 = reg_string_to_num(field2);
            byte3 = reg_string_to_num(field3); 
            expected_fields = 3;

            break;
        }
        case ADDI:
        {

            byte1 = reg_string_to_num(field1);
            byte2 = reg_string_to_num(field2);
            byte3 = immediate_checker(opcode, field3);
            expected_fields = 3;

            break;
        }

        // Memory
        case LOADI:
        {

            byte1 = reg_string_to_num(field1);
            immediate = immediate_checker(opcode, field2);
            byte2 = (immediate >> 4) & 0xF;
            byte3 = (immediate) & 0xF;
            expected_fields = 2;

            break;
        }
        case LOAD:
        {

            byte1 = reg_string_to_num(field1);
            byte2 = reg_string_to_num(field2);
            immediate = immediate_checker(opcode, field3);
            byte3 = (immediate) & 0xF; 
            expected_fields = 3;

            break;
        }
        case STORE:
        {

            byte2 = reg_string_to_num(field1);
            immediate = immediate_checker(opcode, field2);
            byte1 = (immediate) & 0xF; 
            byte3 = reg_string_to_num(field3);
            expected_fields = 3;

            break;
        }

        // Branch
        case BEQ:
        case BNE:
        case BLT:
        {

            byte2 = reg_string_to_num(field1);
            byte3 = reg_string_to_num(field2);
            immediate = immediate_checker(opcode, field3);
            byte1 = (immediate) & 0xF; 
            expected_fields = 3;

            break;
        }
        case JMP_REL12:
        {

            immediate = immediate_checker(opcode, field1);
            byte1 = (immediate >> 8) & 0xF;
            byte2 = (immediate >> 4) & 0xF;
            byte3 = (immediate) & 0xF;
            expected_fields = 1;

            break;

        }

        // Special
        case JMP:
        case CALL:
        {
            byte3 = reg_string_to_num(field1);
            expected_fields = 1;

            break;
        }
        case RET:
        case HALT:
        {

            expected_fields = 0;

            break;
        }
        case MUL:
        {
            byte1 = reg_string_to_num(field2);
            byte3 = reg_string_to_num(field1);
            expected_fields = 2;

            break;
        }
        case XORI:
        {

            byte1 = reg_string_to_num(field1);
            immediate = immediate_checker(opcode, field2);
            byte3 = (immediate) & 0xF;
            expected_fields = 2;

            break;
        }
        case SHL:
        case SHR:
        {
            byte1 = reg_string_to_num(field1);
            byte3 = reg_string_to_num(field2);
            expected_fields = 2;

            break;
        }
        case PUSH:
        case POP:
        {
            byte1 = reg_string_to_num(field1);

            if (opcode == POP)
            {
                if ((byte1 & 0xF) == 15)
                {
                    printf("illegal to pop R15\n");
                    exit(1);
                }
            }

            expected_fields = 1;

            break;
        }
        case SHLI:
        case SHRI:
        {

            byte1 = reg_string_to_num(field1);
            immediate = immediate_checker(opcode, field2);
            byte3 = (immediate) & 0xF;
            expected_fields = 2;

            break;
        }
        case DIV:
        {

            byte1 = reg_string_to_num(field2);
            byte3 = reg_string_to_num(field1);
            expected_fields = 2;

            break;
        }

        default:
        {
            printf("Not a valid opcode\n");
            exit(1);
            break;
        }
    }

    if ( ( (expected_fields < 1) && (field1[0] != '\0') ) || ( (expected_fields < 2) && (field2[0] != '\0') ) || ( (expected_fields < 3) && (field3[0] != '\0') ) )
    {

        printf("Instruction has too many operands\n");
        exit(1);

    }


    instruction += ((byte0 & 0xF) << 12);
    instruction += ((byte1 & 0xF) << 8);
    instruction += ((byte2 & 0xF) << 4);
    instruction += ((byte3 & 0xF));

    return instruction;

}

/*

    takes an opcode, decides if it uses and immediate
    turns immediate string to a number

*/
uint16_t immediate_checker(opcode_t opcode, char* immediate_str)
{

    if (immediate_str == NULL || immediate_str[0] == '\0') 
    {
        printf("No number\n");
        exit(1);
    }

    int32_t immediate = 0;
    int32_t minus_flag = 1;
    uint16_t i = 0;
    

    if (*(immediate_str + i) == '-')
    {
        i++;
        minus_flag = -1;
        if (immediate_str[i] == '\0') 
        { 
            printf("Not a number, lone '-'\n");
            exit(1);
        }
    }

    while ( *(immediate_str + i) != '\0' )
    {

        if (!(('0' <= *(immediate_str + i)) && (*(immediate_str + i) <= '9')))
        {
            printf("Not a number\n");
            exit(1);
        }
        immediate = (immediate * 10) +  (*(immediate_str + i) - '0');
        i++;
    }
    immediate *= minus_flag;
    
    switch (opcode)
    {

        case ADDI: // range: -8 to 7
        case LOAD:
        case STORE:
        case BEQ:
        case BNE:
        case BLT:
        case XORI:
        {
            
            if ( !((immediate >= -8) && (immediate <= 7)) )
            {

                printf("Immediate out of range\n");
                exit(1);
            }

            break;
        }

        case SHLI: // range: 0 to 15
        case SHRI:
        {
            
            if ( !((immediate >= 0) && (immediate <= 15)) )
            {

                printf("Immediate out of range\n");
                exit(1);
            }

            break;
        }

        case LOADI: // range: 0 to 255
        {

            if ( !((immediate >= 0) && (immediate <= 255)) )
            {

                printf("Immediate out of range\n");
                exit(1);
            }
            
            break;
        }

        case JMP_REL12: // range: -2048 to 2047
        {

            if ( !((immediate >= -2048) && (immediate <= 2047)) )
            {

                printf("Immediate out of range\n");
                exit(1);
            }
            
            break;
        }

        default:
        {
            printf("Instruction does not take an immediate\n");
            exit(1);
        }

    }

    immediate &= 0x0000FFFF;

    return (uint16_t) immediate;

}

/*

    checks for proper register syntax and returns the number

*/
uint16_t reg_string_to_num(char* field)
{

    uint8_t error = 0;
    uint16_t number;

    int i = 0;
    while (*(field + i) != '\0')
    {
        i++;
    }
    if (i > 3 || i < 2)
    {
        printf("Register length not long enough\n"); //exits right away to prevent a null string read
        exit(1);
    }
    //now we have a 2-3 character string

    if (field[0] != 'R')
    {
        error = 1;
    }
    if ('0' <= field[1] && field[1] <= '9')
    {
        if ( ('0' <= field[2] && field[2] <= '5') && field[1] == '1')
        {
            number = (field[2] - '0') + 10;
        }
        else if (field[2] == '\0')
        {
            number = field[1] - '0';
        }
        else
        {
            error = 1;
        }
    }
    else
    {
        error = 1;
    }

    if (error)
    {
        printf("Invalid Register Syntax\n");
        exit(1);
    }

    return number;

}

/*

    takes a string and returns a token

*/
opcode_t tokenize(char* opcode)
{

    size_t len = 0;
    
    while (*(opcode + len) != '\0')
    {
        len++;
    }

    uint8_t index = hash_opcode(opcode, len);

    opcode_t opcode_token;

    opcode_token = OPCODE_TABLE[index].opcode;
    
    if (!strings_equal(opcode, len, OPCODE_TABLE[index].string_opcode, OPCODE_TABLE[index].len))
    {
        printf("invalid token\n");
        exit(1);
    }
    return opcode_token;

}

/*

    checks if two strings are equal

*/
uint16_t strings_equal(const char* str1, uint16_t len1, const char* str2, uint16_t len2)
{
    if (str1 == NULL || str2 == NULL || len1 == 0 || len1 != len2)
    {
        return 0;
    }

    
    for (uint16_t i = 0; i < len1; i++)
    {

        if (*(str1 + i) != *(str2 + i)) return 0;

    }

    return 1;

}

/*

    hash function, returns a unique index for each token

*/
uint8_t hash_opcode(const char *str, size_t len) 
{
    uint8_t c0 = (uint8_t)str[0];
    uint8_t c1 = (uint8_t)str[1];
    uint8_t c2 = (len > 2) ? (uint8_t)str[2] : 0;

    return (c0 + (c1 * 34) + (c2 * 41) + (uint8_t)len) & 63;
}
