#include "token.h"
#include "ast.h"



typedef struct //So the parser can have the program and its index through the tokens
{

    program_information program;
    int current_token;
    top_node_t top_node;

} parse_info;

//Next make array of function pointers and start the parse functions
typedef void (*handler_function)(parse_info*); //Change the function pointer parametrs
handler_function functions[TOKEN_COUNT] =
{
    [TOKEN_IDENTIFIER] = parse_identifier_statement, //function name
    [TOKEN_KW_INT] = ,
    [TOKEN_MINUS] = ,
    [TOKEN_LEFT_PAREN] = ,
    [TOKEN_KW_IF] = ,
    [TOKEN_KW_WHILE] = ,
    [TOKEN_KW_RETURN] = parse_return_statement,
    [TOKEN_LEFT_BRACE] = 

};  

int parser(program_information program)
{
    int program_length;
    
    parse_info program_parsed;
    program_parsed.current_token = 0;
    program_parsed.program = program;

    while (program_parsed.program.tokens[program_parsed.current_token].type != TOKEN_EOF)
    {
        if (functions[program_parsed.program.tokens[program_parsed.current_token].type] != 0) //valid start
        {
                functions[program_parsed.program.tokens[program_parsed.current_token].type](&program_parsed);
        }
        else    
        {
            exit(1); //If they equal null it's a syntax error
        }        
    }
    return 0;
}

ast_node parse_identifier_statement(parse_info *program_parsed)
{

    program_parsed->current_token++;
    return_statement_t return_statement;

    if (program_parsed->program.tokens[program_parsed->current_token].type == TOKEN_SEMICOLON)
    {
        program_parsed->current_token++;
        program_parsed->top_node.count++;
        program_parsed->top_node.nodes[program_parsed->top_node.count++]; 
        return;
    }

    switch (program_parsed->program.tokens[program_parsed->current_token].type)
    {
        case: 




    }

}

