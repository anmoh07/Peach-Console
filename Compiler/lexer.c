#include "token.h"
#include "shared.h"
#include <stdio.h>
#include <stdlib.h>

//Function declarations
program_information lexer(const char* start);
token* increase_program_size(token* program, int program_size);
int equals(const char* str1, int len1, const char* str2, int len2);
int is_alpha(char c);
int is_num(char c);
int is_alpha_or_num(char c);
void add_token(token* list, token add, int index);
token reset_token();
token set_token(int length, const char* start, token_type type);
const char* token_type_to_string(token_type type);


//the lexer recieves a C style string (terminated by '\0') and turns it into tokens



int main()
{
    char input[1024];

    fgets(input, sizeof(input), stdin);

    program_information p;

    p = lexer(input);

    int i = 0;
    while (1)
    {
        printf("%s %.*s\n",
            token_type_to_string(p.tokens[i].type),
            p.tokens[i].length,
            p.tokens[i].start);

        if (p.tokens[i].type == TOKEN_EOF)
        {
            printf("PROGRAM SIZE: %d\n", p.program_length);
            break;
        }

        i++;
    }

    printf("%d\n", p.tokens[i].type);

    return 0;
}

//The lexer, groups text into tokens
program_information lexer(const char* start) //Takes in the C program as a string
{

    token* program; //The array of tokens to be filled and return
    int program_size = 64;

    program = malloc(program_size * sizeof(token));
    assert(program != 0); //checks if pointer is valid

    int program_count = 0; //Amount of tokens, also doubles as the index of the next token
    int i = 0; //what character are we on?

    token current_token;
    current_token.start = 0;
    current_token.length = 0;

    char current_char;


    while(*(start + i) != '\0')
    {
        if (program_count >= program_size)
        {
            program_size *= 2;
            program = increase_program_size(program, program_size);
        }
        current_char = *(start + i);
        current_token.length = 0;

        if (is_alpha(current_char)) //If it starts with a character
        {
            current_token.start = (start + i);
            while (is_alpha_or_num(current_char))
            {
                current_token.length++; //How many characters this token has
                i++; //what character of the program we are on
                current_char = *(start + i);     
            }
            if (equals(current_token.start, current_token.length, "int", 3))
            {
                current_token.type = TOKEN_KW_INT;
            }
            else if (equals(current_token.start, current_token.length, "if", 2))
            {
                current_token.type = TOKEN_KW_IF;
            }
            else if (equals(current_token.start, current_token.length, "else", 4))
            {
                current_token.type = TOKEN_KW_ELSE;
            }
            else if (equals(current_token.start, current_token.length, "while", 5))
            {
                current_token.type = TOKEN_KW_WHILE;
            }
            else if (equals(current_token.start, current_token.length, "return", 6))
            {
                current_token.type = TOKEN_KW_RETURN;
            }
            else
            {
                current_token.type = TOKEN_IDENTIFIER;
            }
            add_token(program, current_token, program_count++);
            current_token = reset_token();
            
        }
        else if (is_num(current_char)) //Integer literal, gonna finish later
        {  
            current_token.start = (start + i);
            while (is_num(current_char))
            {
                i++;
                current_char = *(start + i);
                current_token.length++;
            }
            current_token.type = TOKEN_LITERAL_INT;
            add_token(program, current_token, program_count++);
            current_token = reset_token();
        }
        else
        {
            switch (current_char)
            {
                case '+':
                    current_token = set_token(1, start + i, TOKEN_PLUS);
                    i++;
                    break;
                case '-':
                    current_token = set_token(1, start + i, TOKEN_MINUS);
                    i++;
                    break;
                case '*':
                    current_token = set_token(1, start + i, TOKEN_STAR);
                    i++;
                    break;
                case '/':
                    current_token = set_token(1, start + i, TOKEN_SLASH);
                    i++;
                    break;
                case '%':
                    current_token = set_token(1, start + i, TOKEN_PERCENT);
                    i++;
                    break;
                case ';':
                    current_token = set_token(1, start + i, TOKEN_SEMICOLON);
                    i++;
                    break;
                case ',':
                    current_token = set_token(1, start + i, TOKEN_COMMA);
                    i++;
                    break;
                case '(':
                    current_token = set_token(1, start + i, TOKEN_LEFT_PAREN);
                    i++;
                    break;
                case ')':
                    current_token = set_token(1, start + i, TOKEN_RIGHT_PAREN);
                    i++;
                    break;
                case '{':
                    current_token = set_token(1, start + i, TOKEN_LEFT_BRACE);
                    i++;
                    break;
                case '}':
                    current_token = set_token(1, start + i, TOKEN_RIGHT_BRACE);
                    i++;
                    break;
                case '=':
                {
                    if (*(start + i + 1) == '=')
                    {
                        current_token = set_token(2, start + i, TOKEN_EQUALITY);
                        i += 2;
                    }
                    else
                    {
                        current_token = set_token(1, start + i, TOKEN_ASSIGNMENT);
                        i++;
                    }
                    break;
                }
                case '!':
                {
                    if (*(start + i + 1) == '=')
                    {
                        current_token = set_token(2, start + i, TOKEN_NOT_EQUAL);
                        i += 2;
                    }
                    else //error for now, easier to deal with once ! is supported
                    {
                        current_token = set_token(1, start + i, TOKEN_ERROR);
                        i++;
                    }
                    break;
                }
                case '<':
                {
                    if (*(start + i + 1) == '=')
                    {
                        current_token = set_token(2, start + i, TOKEN_LESS_THAN_EQUAL_TO);
                        i += 2;
                    }
                    else
                    {
                        current_token = set_token(1, start + i, TOKEN_LESS_THAN);
                        i++;
                    }
                    break;
                }
                case '>':
                {
                    if (*(start + i + 1) == '=')
                    {
                        current_token = set_token(2, start + i, TOKEN_GREATER_THAN_EQUAL_TO);
                        i += 2;
                    }
                    else
                    {
                        current_token = set_token(1, start + i, TOKEN_GREATER_THAN);
                        i++;
                    }
                    break;
                }
                case ' ': 
                case '\n':
                case '\t':
                    i++;
                    continue; //skip over them
                default:
                    current_token = set_token(1, start + i, TOKEN_ERROR);
                    i++;
                    break;
                
            }
            add_token(program, current_token, program_count++);
            current_token = reset_token();
        }
    }

    if (program_count == program_size)
    {
        program_size += 1; //Creates one more space for the eof token if needed
        program = increase_program_size(program, program_size);
    }

    current_token = set_token(0, start + i, TOKEN_EOF); //Creating EOF token
    add_token(program, current_token, program_count++); //Adding it to tokens array

    program_information p; //passing in program length 
    p.program_length = program_count++; 
    p.tokens = program;

    return p; //Returns the program as an array of tokens

}

// This function takes the program array, assuming it's full
// It allocates it to a new array with the new size (usually double)
token* increase_program_size(token* program, int program_size)
{
        token* temp_program;
        temp_program = realloc(program, program_size * sizeof(token)); //Reallocated to array to double the size, program_size is doubled (or increased) before call to function
        assert(temp_program != 0);
        return temp_program;
}

//Checks if two strings are equal. Returns 1 for yes 0 for no
int equals(const char* str1, int len1, const char* str2, int len2)
{

    assert(str1 && str2);

    if (len1 != len2) //If they have different lengths they can't be equal
    {
        return 0;
    }

    const char* end = str1 + len1;

    while (str1 < end)
    {
        if (*str1 != *str2)
        {
            return 0;
        }
        str1++;
        str2++;
    }

    return 1;
}

//Checks if a char is a letter or underscore
//Returns 1 for yes, 0 for no
int is_alpha(char c)
{
    if (((c <= 'z') && (c >= 'a')) || ((c <= 'Z') && (c >= 'A')) || (c == '_'))
    {
        return 1;
    }
    return 0;
}

//Checks if a char is a number
//1 for yes 0 for no
int is_num(char c)
{

    if ((c <= '9') && (c >= '0'))
    {
        return 1;
    }

    return 0;
}

//Checks if a char is a letter, underscore or number
//Returns 1 for yes, 0 for no
int is_alpha_or_num(char c)
{
    if (is_alpha(c))
    {
        return 1;
    }
    else if (is_num(c))
    {
        return 1;
    }
    return 0;
}

//Adds a token to the token array
void add_token(token* list, token add, int index)
{
    list[index] = add;
}

//Resets a token to the default state
token reset_token()
{
    token reset;
    reset.length = 0;
    reset.start = 0;
    reset.type = TOKEN_NONE;
    return reset;
}   

//Initilaizes a token, behaves like a constructor
token set_token(int length, const char* start, token_type type)
{
    token token;
    token.length = length;
    token.start = start;
    token.type = type;
    return token;
}

//Takes in a token type and outputs a string of it to output for debugging
const char* token_type_to_string(token_type type) 
{
    switch(type)
    {
        case TOKEN_IDENTIFIER: return "IDENTIFIER";
        case TOKEN_LITERAL_INT: return "LITERAL_INT";
        case TOKEN_KW_INT: return "KW_INT";
        case TOKEN_KW_IF: return "KW_IF";
        case TOKEN_KW_ELSE: return "KW_ELSE";
        case TOKEN_KW_WHILE: return "KW_WHILE";
        case TOKEN_KW_RETURN: return "KW_RETURN";

        case TOKEN_PLUS: return "PLUS";
        case TOKEN_MINUS: return "MINUS";
        case TOKEN_STAR: return "STAR";
        case TOKEN_SLASH: return "SLASH";
        case TOKEN_PERCENT: return "PERCENT";

        case TOKEN_ASSIGNMENT: return "ASSIGNMENT";
        case TOKEN_EQUALITY: return "EQUALITY";
        case TOKEN_NOT_EQUAL: return "NOT_EQUAL";

        case TOKEN_LESS_THAN: return "LESS_THAN";
        case TOKEN_LESS_THAN_EQUAL_TO: return "LESS_EQUAL";
        case TOKEN_GREATER_THAN: return "GREATER_THAN";
        case TOKEN_GREATER_THAN_EQUAL_TO: return "GREATER_EQUAL";

        case TOKEN_LEFT_PAREN: return "LEFT_PAREN";
        case TOKEN_RIGHT_PAREN: return "RIGHT_PAREN";
        case TOKEN_LEFT_BRACE: return "LEFT_BRACE";
        case TOKEN_RIGHT_BRACE: return "RIGHT_BRACE";

        case TOKEN_SEMICOLON: return "SEMICOLON";
        case TOKEN_COMMA: return "COMMA";

        case TOKEN_ERROR: return "ERROR";
        case TOKEN_EOF: return "EOF";

        default: return "UNKNOWN";
    }
}