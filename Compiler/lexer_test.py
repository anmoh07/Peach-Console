import pytest
import subprocess


def run_lexer(source_code):
    result = subprocess.run(
        ["./lexer.exe"], input=source_code, text=True, capture_output=True, check=True
    )
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]

TEST_CASES = [

    # ==================================================
    # EMPTY INPUT / EOF
    # ==================================================

    ("", [
        "EOF",
    ]),


    # ==================================================
    # KEYWORDS
    # ==================================================

    ("int", [
        "KW_INT int",
        "EOF",
    ]),

    ("char", [
        "KW_CHAR char",
        "EOF",
    ]),

    ("unsigned", [
        "KW_UNSIGNED unsigned",
        "EOF",
    ]),

    ("struct", [
        "KW_STRUCT struct",
        "EOF",
    ]),

    ("if", [
        "KW_IF if",
        "EOF",
    ]),

    ("else", [
        "KW_ELSE else",
        "EOF",
    ]),

    ("while", [
        "KW_WHILE while",
        "EOF",
    ]),

    ("return", [
        "KW_RETURN return",
        "EOF",
    ]),


    # ==================================================
    # IDENTIFIERS
    # ==================================================

    ("x", [
        "IDENTIFIER x",
        "EOF",
    ]),

    ("abc", [
        "IDENTIFIER abc",
        "EOF",
    ]),

    ("_x", [
        "IDENTIFIER _x",
        "EOF",
    ]),

    ("hello_world", [
        "IDENTIFIER hello_world",
        "EOF",
    ]),

    ("x123", [
        "IDENTIFIER x123",
        "EOF",
    ]),

    ("abc_123_xyz", [
        "IDENTIFIER abc_123_xyz",
        "EOF",
    ]),

    ("ABC", [
        "IDENTIFIER ABC",
        "EOF",
    ]),

    ("Int", [
        "IDENTIFIER Int",
        "EOF",
    ]),


    # ==================================================
    # KEYWORD BOUNDARIES
    #
    # These make sure keyword detection is based on the
    # entire identifier rather than just its prefix.
    # ==================================================

    ("integer", [
        "IDENTIFIER integer",
        "EOF",
    ]),

    ("intx", [
        "IDENTIFIER intx",
        "EOF",
    ]),

    ("int2", [
        "IDENTIFIER int2",
        "EOF",
    ]),

    ("int_x", [
        "IDENTIFIER int_x",
        "EOF",
    ]),

    ("character", [
        "IDENTIFIER character",
        "EOF",
    ]),

    ("unsigned_value", [
        "IDENTIFIER unsigned_value",
        "EOF",
    ]),

    ("structure", [
        "IDENTIFIER structure",
        "EOF",
    ]),

    ("iffy", [
        "IDENTIFIER iffy",
        "EOF",
    ]),

    ("elsewhere", [
        "IDENTIFIER elsewhere",
        "EOF",
    ]),

    ("while_loop", [
        "IDENTIFIER while_loop",
        "EOF",
    ]),

    ("return_value", [
        "IDENTIFIER return_value",
        "EOF",
    ]),


    # ==================================================
    # INTEGER LITERALS
    # ==================================================

    ("0", [
        "LITERAL_INT 0",
        "EOF",
    ]),

    ("5", [
        "LITERAL_INT 5",
        "EOF",
    ]),

    ("10", [
        "LITERAL_INT 10",
        "EOF",
    ]),

    ("123456789", [
        "LITERAL_INT 123456789",
        "EOF",
    ]),

    ("000123", [
        "LITERAL_INT 000123",
        "EOF",
    ]),


    # ==================================================
    # ARITHMETIC OPERATORS
    # ==================================================

    ("+", [
        "PLUS +",
        "EOF",
    ]),

    ("-", [
        "MINUS -",
        "EOF",
    ]),

    ("*", [
        "STAR *",
        "EOF",
    ]),

    ("/", [
        "SLASH /",
        "EOF",
    ]),

    ("%", [
        "PERCENT %",
        "EOF",
    ]),


    # ==================================================
    # ASSIGNMENT / EQUALITY
    # ==================================================

    ("=", [
        "ASSIGNMENT =",
        "EOF",
    ]),

    ("==", [
        "EQUALITY ==",
        "EOF",
    ]),

    ("!", [
        "EXCLAMATION !",
        "EOF",
    ]),

    ("!=", [
        "NOT_EQUAL !=",
        "EOF",
    ]),


    # ==================================================
    # COMPARISON OPERATORS
    # ==================================================

    ("<", [
        "LESS_THAN <",
        "EOF",
    ]),

    ("<=", [
        "LESS_EQUAL <=",
        "EOF",
    ]),

    (">", [
        "GREATER_THAN >",
        "EOF",
    ]),

    (">=", [
        "GREATER_EQUAL >=",
        "EOF",
    ]),


    # ==================================================
    # LOGICAL OPERATORS
    # ==================================================

    ("&&", [
        "AND &&",
        "EOF",
    ]),

    ("||", [
        "OR ||",
        "EOF",
    ]),


    # ==================================================
    # BITWISE OPERATORS
    # ==================================================

    ("&", [
        "AND_BW &",
        "EOF",
    ]),

    ("|", [
        "OR_BW |",
        "EOF",
    ]),

    ("^", [
        "XOR_BW ^",
        "EOF",
    ]),

    ("~", [
        "NOT_BW ~",
        "EOF",
    ]),

    ("<<", [
        "LEFT_SHIFT_BW <<",
        "EOF",
    ]),

    (">>", [
        "RIGHT_SHIFT_BW >>",
        "EOF",
    ]),


    # ==================================================
    # PUNCTUATION
    # ==================================================

    (";", [
        "SEMICOLON ;",
        "EOF",
    ]),

    (",", [
        "COMMA ,",
        "EOF",
    ]),

    ("(", [
        "LEFT_PAREN (",
        "EOF",
    ]),

    (")", [
        "RIGHT_PAREN )",
        "EOF",
    ]),

    ("{", [
        "LEFT_BRACE {",
        "EOF",
    ]),

    ("}", [
        "RIGHT_BRACE }",
        "EOF",
    ]),

    (".", [
        "DOT .",
        "EOF",
    ]),


    # ==================================================
    # OPERATOR AMBIGUITY
    # ==================================================

    ("= == =", [
        "ASSIGNMENT =",
        "EQUALITY ==",
        "ASSIGNMENT =",
        "EOF",
    ]),

    ("! != !", [
        "EXCLAMATION !",
        "NOT_EQUAL !=",
        "EXCLAMATION !",
        "EOF",
    ]),

    ("< <= <<", [
        "LESS_THAN <",
        "LESS_EQUAL <=",
        "LEFT_SHIFT_BW <<",
        "EOF",
    ]),

    ("> >= >>", [
        "GREATER_THAN >",
        "GREATER_EQUAL >=",
        "RIGHT_SHIFT_BW >>",
        "EOF",
    ]),

    ("& && &", [
        "AND_BW &",
        "AND &&",
        "AND_BW &",
        "EOF",
    ]),

    ("| || |", [
        "OR_BW |",
        "OR ||",
        "OR_BW |",
        "EOF",
    ]),


    # ==================================================
    # WHITESPACE
    # ==================================================

    ("   int   x   ", [
        "KW_INT int",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("\tint\tx\t", [
        "KW_INT int",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("\rint\rx\r", [
        "KW_INT int",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("\nint\nx\n", [
        "KW_INT int",
        "IDENTIFIER x",
        "EOF",
    ]),

    (" \t\r\nint \t\r\n x \t\r\n", [
        "KW_INT int",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("     ", [
        "EOF",
    ]),

    ("\t\r\n\n\t", [
        "EOF",
    ]),


    # ==================================================
    # TOKENS WITH NO WHITESPACE
    # ==================================================

    ("int x=5;", [
        "KW_INT int",
        "IDENTIFIER x",
        "ASSIGNMENT =",
        "LITERAL_INT 5",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("x+5", [
        "IDENTIFIER x",
        "PLUS +",
        "LITERAL_INT 5",
        "EOF",
    ]),

    ("x<<2", [
        "IDENTIFIER x",
        "LEFT_SHIFT_BW <<",
        "LITERAL_INT 2",
        "EOF",
    ]),

    ("x!=0", [
        "IDENTIFIER x",
        "NOT_EQUAL !=",
        "LITERAL_INT 0",
        "EOF",
    ]),

    ("a&&b", [
        "IDENTIFIER a",
        "AND &&",
        "IDENTIFIER b",
        "EOF",
    ]),

    ("a||b", [
        "IDENTIFIER a",
        "OR ||",
        "IDENTIFIER b",
        "EOF",
    ]),

    ("x.y", [
        "IDENTIFIER x",
        "DOT .",
        "IDENTIFIER y",
        "EOF",
    ]),


    # ==================================================
    # SIMPLE LANGUAGE CONSTRUCTS
    # ==================================================

    ("int x = 5;", [
        "KW_INT int",
        "IDENTIFIER x",
        "ASSIGNMENT =",
        "LITERAL_INT 5",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("unsigned int x;", [
        "KW_UNSIGNED unsigned",
        "KW_INT int",
        "IDENTIFIER x",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("int *ptr;", [
        "KW_INT int",
        "STAR *",
        "IDENTIFIER ptr",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("x = *ptr;", [
        "IDENTIFIER x",
        "ASSIGNMENT =",
        "STAR *",
        "IDENTIFIER ptr",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("ptr = &x;", [
        "IDENTIFIER ptr",
        "ASSIGNMENT =",
        "AND_BW &",
        "IDENTIFIER x",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("return x;", [
        "KW_RETURN return",
        "IDENTIFIER x",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("if(x==5){return x;}", [
        "KW_IF if",
        "LEFT_PAREN (",
        "IDENTIFIER x",
        "EQUALITY ==",
        "LITERAL_INT 5",
        "RIGHT_PAREN )",
        "LEFT_BRACE {",
        "KW_RETURN return",
        "IDENTIFIER x",
        "SEMICOLON ;",
        "RIGHT_BRACE }",
        "EOF",
    ]),

    ("while(x<10){x=x+1;}", [
        "KW_WHILE while",
        "LEFT_PAREN (",
        "IDENTIFIER x",
        "LESS_THAN <",
        "LITERAL_INT 10",
        "RIGHT_PAREN )",
        "LEFT_BRACE {",
        "IDENTIFIER x",
        "ASSIGNMENT =",
        "IDENTIFIER x",
        "PLUS +",
        "LITERAL_INT 1",
        "SEMICOLON ;",
        "RIGHT_BRACE }",
        "EOF",
    ]),

    ("struct node { int value; };", [
        "KW_STRUCT struct",
        "IDENTIFIER node",
        "LEFT_BRACE {",
        "KW_INT int",
        "IDENTIFIER value",
        "SEMICOLON ;",
        "RIGHT_BRACE }",
        "SEMICOLON ;",
        "EOF",
    ]),

    ("node.value", [
        "IDENTIFIER node",
        "DOT .",
        "IDENTIFIER value",
        "EOF",
    ]),


    # ==================================================
    # EXPRESSIONS
    # ==================================================

    ("a+b-c*d/e%f", [
        "IDENTIFIER a",
        "PLUS +",
        "IDENTIFIER b",
        "MINUS -",
        "IDENTIFIER c",
        "STAR *",
        "IDENTIFIER d",
        "SLASH /",
        "IDENTIFIER e",
        "PERCENT %",
        "IDENTIFIER f",
        "EOF",
    ]),

    ("a&b|c^d", [
        "IDENTIFIER a",
        "AND_BW &",
        "IDENTIFIER b",
        "OR_BW |",
        "IDENTIFIER c",
        "XOR_BW ^",
        "IDENTIFIER d",
        "EOF",
    ]),

    ("~x", [
        "NOT_BW ~",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("!x", [
        "EXCLAMATION !",
        "IDENTIFIER x",
        "EOF",
    ]),

    ("(a+b)", [
        "LEFT_PAREN (",
        "IDENTIFIER a",
        "PLUS +",
        "IDENTIFIER b",
        "RIGHT_PAREN )",
        "EOF",
    ]),


    # ==================================================
    # MULTIPLE SAME-TYPE TOKENS
    # ==================================================

    ("a b c d", [
        "IDENTIFIER a",
        "IDENTIFIER b",
        "IDENTIFIER c",
        "IDENTIFIER d",
        "EOF",
    ]),

    ("1 2 3 4", [
        "LITERAL_INT 1",
        "LITERAL_INT 2",
        "LITERAL_INT 3",
        "LITERAL_INT 4",
        "EOF",
    ]),

    ("++++", [
        "PLUS +",
        "PLUS +",
        "PLUS +",
        "PLUS +",
        "EOF",
    ]),


    # ==================================================
    # INVALID / UNSUPPORTED CHARACTERS
    # ==================================================

    ("@", [
        "ERROR @",
        "EOF",
    ]),

    ("$", [
        "ERROR $",
        "EOF",
    ]),

    ("x@y", [
        "IDENTIFIER x",
        "ERROR @",
        "IDENTIFIER y",
        "EOF",
    ]),

    ("int @ x;", [
        "KW_INT int",
        "ERROR @",
        "IDENTIFIER x",
        "SEMICOLON ;",
        "EOF",
    ]),


    # ==================================================
    # EOF BOUNDARIES
    # ==================================================

    ("x", [
        "IDENTIFIER x",
        "EOF",
    ]),

    ("123", [
        "LITERAL_INT 123",
        "EOF",
    ]),

    ("=", [
        "ASSIGNMENT =",
        "EOF",
    ]),

    ("==", [
        "EQUALITY ==",
        "EOF",
    ]),

    ("x\n", [
        "IDENTIFIER x",
        "EOF",
    ]),


    # ==================================================
    # REALISTIC MULTI-LINE INPUT
    # ==================================================

    (
        "int x = 5;\n"
        "int y = 10;\n"
        "if (x < y) {\n"
        "    x = x + 1;\n"
        "}\n",
        [
            "KW_INT int",
            "IDENTIFIER x",
            "ASSIGNMENT =",
            "LITERAL_INT 5",
            "SEMICOLON ;",

            "KW_INT int",
            "IDENTIFIER y",
            "ASSIGNMENT =",
            "LITERAL_INT 10",
            "SEMICOLON ;",

            "KW_IF if",
            "LEFT_PAREN (",
            "IDENTIFIER x",
            "LESS_THAN <",
            "IDENTIFIER y",
            "RIGHT_PAREN )",
            "LEFT_BRACE {",

            "IDENTIFIER x",
            "ASSIGNMENT =",
            "IDENTIFIER x",
            "PLUS +",
            "LITERAL_INT 1",
            "SEMICOLON ;",

            "RIGHT_BRACE }",
            "EOF",
        ],
    ),
]

# Reallocation / growth test
source = " ".join(f"x{i}" for i in range(100))

expected = [
    *(f"IDENTIFIER x{i}" for i in range(100)),
    "EOF",
]

TEST_CASES.append((source, expected))

@pytest.mark.parametrize("source, expected", TEST_CASES)
def test_lexer_suite(source, expected):
    actual = run_lexer(source)
    assert actual == expected
