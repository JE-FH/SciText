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
IDENTIFIER := [^0-9()",§][^ ()",§]*
```

### Grammar
```
Call ::= INVOKE ExprEXPR
ActualArguments ::= LPAREN InnerActualArguments RPAREN
InnerActualArguments ::= Expr NextArgument
NextArgument ::= COMMA InnerActualArguments | epsilon
Expr ::= IDENTIFIER Expr2 
Expr2 ::= FunctionCall | epsilon
FunctionCall ::= ActualArguments
```
