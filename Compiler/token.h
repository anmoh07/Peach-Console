typedef enum
{


    TOKEN_IDENTIFIER, //Variable names, 0 
    TOKEN_LITERAL_INT, //Integer literals,


    //Keywords


    TOKEN_KW_INT,
    TOKEN_KW_UNSIGNED,
    TOKEN_KW_IF,
    TOKEN_KW_ELSE,
    TOKEN_KW_WHILE,
    TOKEN_KW_RETURN,
    TOKEN_KW_STRUCT,


    //Arithmetic Operators


    TOKEN_ASSIGNMENT,
    TOKEN_PLUS,
    TOKEN_MINUS,
    TOKEN_STAR,
    TOKEN_SLASH,
    TOKEN_PERCENT,


    //Operators

    TOKEN_EXCLAMATION, //!
    TOKEN_EQUALITY, //==
    TOKEN_NOT_EQUAL, //!=
    TOKEN_LESS_THAN, //<
    TOKEN_LESS_THAN_EQUAL_TO, //<=
    TOKEN_GREATER_THAN, //>
    TOKEN_GREATER_THAN_EQUAL_TO, //>=
    TOKEN_AND, //&&
    TOKEN_OR, //||
    TOKEN_AND_BW, //for bitwise AND, and address of, &
    TOKEN_OR_BW, // |
    TOKEN_XOR_BW, //^
    TOKEN_NOT_BW, //~
    TOKEN_LEFT_SHIFT_BW, //<<
    TOKEN_RIGHT_SHIFT_BW, //>>
    TOKEN_DOT, //.


    //Punctuation


    TOKEN_SEMICOLON,
    TOKEN_COMMA,
    TOKEN_LEFT_PAREN,
    TOKEN_RIGHT_PAREN,
    TOKEN_LEFT_BRACE,
    TOKEN_RIGHT_BRACE,


    //Special


    TOKEN_NONE,
    TOKEN_EOF,
    TOKEN_ERROR,
    TOKEN_COUNT //Since it's it the end, it's numeric value is the amount of tokens before it


} token_type; //Types of tokens classified in an enum

typedef struct
{

    token_type type;
    const char* start;
    unsigned long length;
    int line;

} token; //Defines a token with it's type, start in memory, and length

typedef struct 
{
    
    token* tokens;
    int program_length;

} program_information;
