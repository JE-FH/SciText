# First iteration

## Features
* Only SciText -> STIR
* bold text and italic text functions
* lorem ipsum function
* Page breaks

## Grammar for § calls
### Terminals
```
INVOKE := '§'
LPAREN = '('
RPAREN = ')'
COMMA = ','
STARTBLOCK = '§('
ENDBLOCK = '§)'
STRINGLITTERAL = '"' ([^"\\\n\r] | '\\' . )* '"'
IDENTIFIER := [^0-9 )(",§\n\r][^ )(",§\n\r]*
```

### Grammar
```
Invocation ::= INVOKE ExprBase FunctionCall
ActualArguments ::= LPAREN InnerActualArguments RPAREN
InnerActualArguments ::= Expr NextArgument | epsilon
NextArgument ::= COMMA InnerActualArguments | epsilon
Expr ::= ExprBase Expr2
Expr2 ::= FunctionCall | epsilon
ExprBase ::= IDENTIFIER | STRINGLITTERAL | BLOCK
FunctionCall ::= ActualArguments
BLOCK ::= STARTBLOCK context-sensitive-part ENDBLOCK
```

context-sensitive-part means it is the whole document grammar which will not be parsed by RD parser since its not ll(1) nor context free.  This means we have to hack the RD parser to do this which is fine
