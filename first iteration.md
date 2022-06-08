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
STRINGLITTERAL = '"' ([^"\\] | '\\' . )* '"'
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
ExprBase ::= IDENTIFIER | STRINGLITTERAL
FunctionCall ::= ActualArguments
```
