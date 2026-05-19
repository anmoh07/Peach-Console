#include "token.h"

typedef struct ast_node ast_node;

typedef enum
{

    NODE_BLOCK,
    NODE_INT_LITERAL,
    NODE_IDENTIFIER,
    NODE_BINARY_EXPR,
    NODE_UNARY_EXPR,
    NODE_ASSIGNMENT_EXPR,
    NODE_CALL_EXPR,
    NODE_VAR_DECL,
    NODE_FUNCTION_DECL,
    NODE_IF_STMT,
    NODE_WHILE_STMT,
    NODE_RETURN_STMT,
    NODE_EXPR_STMT

} node_type;

typedef struct
{

    int count;
    int capacity;
    ast_node **nodes;

} top_node_t;

typedef struct
{

    ast_node **nodes;
    int count; //how many there are
    int capacity; //the max amount that can be stored, use to allocate memory for nodes

} block_t;

typedef struct
{

    int value;

} int_literal_t;

typedef struct
{

    char *name;

} identifier_t;

typedef struct
{

    ast_node *left_value;
    ast_node *right_value;
    token_type op;

} binary_expression_t;

typedef struct
{

    ast_node *operand;
    token_type op;

} unary_expression_t;

typedef struct
{

    ast_node *left_value;
    token_type op;
    ast_node *right_value;

} assignment_expression_t;

typedef struct
{

    identifier_t callee;
    ast_node **arguments;
    int argument_count;
    int argument_capacity;

} call_expression_t;

typedef struct
{

    token_type var_type;
    identifier_t name;
    ast_node *initializer;

} var_declaration_t;

typedef struct
{

    token_type param_type;
    identifier_t name;

} parameter_t;

typedef struct
{

    token_type return_type;
    identifier_t name;

    parameter_t *parameters;
    int parameter_count;
    int parameter_capacity;

    block_t body;

} function_declaration_t;

typedef struct
{

    ast_node *condition;
    block_t then_block;
    block_t else_block;
    int has_else;

} if_statement_t;

typedef struct
{

    ast_node *condition;
    block_t body;

} while_statement_t;

typedef struct
{

    ast_node *value;

} return_statement_t;

typedef struct
{

    ast_node *expression;

} expression_statement_t;

typedef union
{

    block_t block;
    int_literal_t int_literal;
    identifier_t identifier;
    binary_expression_t binary_expression;
    unary_expression_t unary_expression;
    assignment_expression_t assignment_expression;
    call_expression_t call_expression;
    var_declaration_t var_declaration;
    function_declaration_t function_var_declaration;
    if_statement_t if_statement;
    while_statement_t while_statement;
    return_statement_t return_statement;
    expression_statement_t expr_statement;

} node_data;

struct ast_node
{

    node_type type;
    node_data data;

};

