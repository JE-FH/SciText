local json = require("json")

function printf(str, ...)
    local args = {...}
    print(str:format(table.unpack(args)))
end

function Enum(t)
    for k, v in pairs(t) do
        t[v] = k
    end
    return t;
end

local TokenType = Enum({
    INVOKE = 1,
    LPAREN = 2,
    RPAREN = 3,
    COMMA = 4,
    STRINGLITTERAL = 5,
    IDENTIFIER = 6,
    EOF = 7,
    STARTBLOCK = 8,
    ENDBLOCK = 9
})

local NonTerminalType = Enum({
    Invocation = 1,
    ActualArguments = 2,
    InnerActualArguments = 3,
    NextArgument = 4,
    Expr = 5,
    Expr2 = 6,
    ExprBase = 7,
    FunctionCall = 8
});

local Token = {};

function Token:New(type, literalValue, start, stop)
    local o = {
        type = type,
        literalValue = literalValue,
        start = start,
        stop = stop
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

local TokenStream = {};

function TokenStream:New(originalInput, parseFunction, startIndex)
    local o = {
        tokens = {},
        currentIndex = 1,
        originalInput = originalInput,
        parseFunction = parseFunction,
        currentInputIndex = startIndex
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function TokenStream:Append(token)
    self.tokens[#self.tokens + 1] = token
end

function TokenStream:Peek()
    if (self.currentIndex > #self.tokens) then
        if (self.currentInputIndex <= #self.originalInput) then
            local token = self.parseFunction(self.originalInput, self.currentInputIndex)
            self.currentInputIndex = token.stop + 1
            self:Append(token)
        end
    end
    local token = self.tokens[self.currentIndex]
    if token == nil then
        return Token:New(TokenType.EOF, "EOF", self.currentInputIndex, self.currentInputIndex);
    end
    return token
end

function TokenStream:Pop()
    local rv = self:Peek()
    if (rv.type ~= TokenType.EOF) then
        self.currentIndex = self.currentIndex + 1
    end
    return rv
end

function TokenStream:AcceptType(_type)
    local popped = self:Pop()
    if popped.type ~= _type then
        self:Error({_type}, popped)
    end
    return popped
end

function TokenStream:Error(expectedTokens, receivedToken)
    local message ="Expected one of ";
    for k, v in pairs(expectedTokens) do
        message = message .. tostring(TokenType[v]) .. " "
    end

    message = message .. "but got " .. tostring(TokenType[receivedToken.type])

    print(message)
    printf("Token value: %s", receivedToken.literalValue)
    printf("%s", self.originalInput:sub(math.max(1, receivedToken.start - 10), math.min(receivedToken.stop + 10, #self.originalInput)))
    print("          ^");
    printf("Error happened at %i", receivedToken.start)
    error("Syntax error")
end

function TokenStream:GetRemainingInput()
    return self.originalInput:sub(self.currentInputIndex)
end

function TokenStream:GetInputIndex()
    return self.currentInputIndex
end

local NonTerminal = {}

function NonTerminal:New(NonTerminalType)
    local o = {
        type = NonTerminalType
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function lexParseFunction(inputString, currentIndex)
    local codePoint = utf8.codepoint(inputString, currentIndex);
    local next = utf8.char(codePoint);
    if next == " " or next == "\n" or next == "\r" then
        -- a bit of a hack
        return lexParseFunction(inputString, currentIndex + 1)
    elseif next == "§" then
        local nextnext = utf8.char(utf8.codepoint(inputString, currentIndex + #next))
        if (nextnext == "(") then
            return Token:New(TokenType.STARTBLOCK, "§(", currentIndex, currentIndex + #next + #nextnext - 1)
        elseif (nextnext == ")") then
            return Token:New(TokenType.ENDBLOCK, "§)", currentIndex, currentIndex + #next + #nextnext - 1)
        else
            return Token:New(TokenType.INVOKE, "§", currentIndex, currentIndex + #next - 1)
        end
    elseif next == "(" then
        return Token:New(TokenType.LPAREN, "(", currentIndex, currentIndex)
    elseif next == ")" then
        return Token:New(TokenType.RPAREN, ")", currentIndex, currentIndex)
    elseif next == "," then
        return Token:New(TokenType.COMMA, ",", currentIndex, currentIndex)
    elseif next == "\"" then
        --parse string
        --since lua patterns are not closed under unification, we have to manually do that
        local acc = "";
        local start = currentIndex;
        currentIndex = currentIndex + 1;
        while true do
            local match = inputString:match("^[^\"\\\n\r]+", currentIndex);
            if match ~= nil then
                acc = acc .. match
                currentIndex = currentIndex + #match
            else
                local match = inputString:match("^\\.", currentIndex);
                if match ~= nil then
                    acc = acc .. match:sub(2)
                    currentIndex = currentIndex + #match
                else
                    break
                end
            end
        end
        if currentIndex == #inputString then
            error("Expected ending \" but got EOF");
        end
        currentIndex = currentIndex + 1;
        return Token:New(TokenType.STRINGLITTERAL, acc, start, currentIndex - 1)
    else
        --parse identifier
        --for this version § are not handled since that require unicode
        local match = inputString:match("^[^0-9 )(\",\n\r][^ )(\",\n\r]*", currentIndex)
        if match == nil then
            printf("Unrecognized token at %i", currentIndex)
            printf("%s", inputString:sub(math.max(1, currentIndex - 10), math.min(currentIndex + 10, #inputString)))
            print("          ^");
            error("Syntax error")
            print(inputString:sub(currentIndex, 20))
            print(utf8.codepoint(inputString, currentIndex))
            error("Unrecognized token at " .. tostring(currentIndex))
        end
        return Token:New(TokenType.IDENTIFIER, match, currentIndex, currentIndex + #match - 1)
    end
end

function lex(inputString, startIndex)
    return TokenStream:New(inputString, lexParseFunction, startIndex)
end


function dumpTable(t, level)
    local indent = ("    "):rep(level)
    print("{")
    local indentInner = ("    "):rep(level + 1)
    for k, v in pairs(t) do
        if type(v) == "table" then
            io.write(indentInner .. tostring(k) .. " = ");
            dumpTable(v, level+1)
        else
            if type(v) == "string" then
                print(indentInner .. tostring(k) .. " = ".. ("%q"):format(v));
            else 
                print(indentInner .. tostring(k) .. " = " .. tostring(v))
            end
        end
    end
    print(indent .. "}")
end



function ParseInvocation(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.Invocation)
    tokenStream:AcceptType(TokenType.INVOKE)
    rv.exprBase = ParseExprBase(tokenStream)
    rv.functionCall = ParseFunctionCall(tokenStream);
    return rv
end

function ParseActualArguments(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.ActualArguments)
    tokenStream:AcceptType(TokenType.LPAREN)
    rv.innerActualArguments = ParseInnerActualArguments(tokenStream)
    tokenStream:AcceptType(TokenType.RPAREN)
    return rv
end

function ParseInnerActualArguments(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.InnerActualArguments)
    local next = tokenStream:Peek()
    if next.type == TokenType.IDENTIFIER or next.type == TokenType.STRINGLITTERAL or next.type == TokenType.STARTBLOCK then
        rv.expr = ParseExpr(tokenStream);
        rv.nextArgument = ParseNextArgument(tokenStream);
    elseif next.type == TokenType.RPAREN then
        return nil
    else 
        print(("Unexpected token at %i"):format(next.start))
        tokenStream:Error({TokenType.IDENTIFIER, TokenType.STRINGLITTERAL, TokenType.STARTBLOCK}, next);
    end

    return rv
end

function ParseNextArgument(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.NextArgument)
    local next = tokenStream:Peek()
    if next.type == TokenType.COMMA then
        tokenStream:AcceptType(TokenType.COMMA);
        rv.actualArguments = ParseInnerActualArguments(tokenStream)
    elseif next.type == TokenType.RPAREN then
        return nil
    end
    return rv
end

function ParseExpr(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.Expr)
    rv.exprBase = ParseExprBase(tokenStream)
    rv.expr2 = ParseExpr2(tokenStream)
    return rv
end

function ParseExpr2(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.Expr2)
    local next = tokenStream:Peek()
    if next.type == TokenType.EOF or next.type == TokenType.COMMA or next.type == TokenType.RPAREN then
        return nil
    elseif next.type == TokenType.LPAREN then
        rv.functionCall = ParseFunctionCall(tokenStream)
    else
        tokenStream:Error({TokenType.LPAREN, TokenType.COMMA, TokenType.RPAREN, TokenType.EOF}, next);
    end
    return rv;
end

function ParseExprBase(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.ExprBase);
    local next = tokenStream:Peek()
    if next.type == TokenType.IDENTIFIER then
        rv.identifier = tokenStream:AcceptType(TokenType.IDENTIFIER);
    elseif next.type == TokenType.STRINGLITTERAL then
        rv.str = tokenStream:AcceptType(TokenType.STRINGLITTERAL);
    elseif next.type == TokenType.STARTBLOCK then
        tokenStream:AcceptType(TokenType.STARTBLOCK);
        rv.fragments, tokenStream.currentInputIndex = ParseFraments(tokenStream.originalInput, tokenStream:GetInputIndex())
    else
        tokenStream:Error({TokenType.IDENTIFIER, TokenType.STRINGLITTERAL, TokenType.STARTBLOCK}, next);
    end
    return rv;
end

function ParseFunctionCall(tokenStream)
    local rv = NonTerminal:New(NonTerminalType.FunctionCall);
    rv.actualArguments = ParseActualArguments(tokenStream)
    return rv;
end



local inputString = "§header1(textbf(fontsize(\"large\", \"Hello world!\")))\"ksdofk\"";


function ParseFraments(content, startIndex)
    startIndex = startIndex or 1
    local fragments = {}
    local currentInputFragment = ""
    
    
    local i = startIndex;
    while i <= #content do
        local codePoint = utf8.codepoint(content, i);
        local next = utf8.char(codePoint);
        if next == "§" then
            if (#currentInputFragment > 0) then
                fragments[#fragments + 1] = currentInputFragment
                currentInputFragment = ""
            end
            local nextnext = utf8.char(utf8.codepoint(content, i + #next))
            if (nextnext == ")") then
                i = i + #next + #nextnext
                break;
            elseif (nextnext == "(") then
                local newFragments;
                newFragments, i = ParseFraments(content, i + #next + #nextnext)
                fragments[#fragments+1] = newFragments
            else
                local tokenStream = lex(content, i)
                local ast = ParseInvocation(tokenStream)
    
                i = tokenStream:GetInputIndex()
    
                fragments[#fragments + 1] = ast
            end
        else
            currentInputFragment = currentInputFragment .. next
            i = i + #next
        end
    end
    if (#currentInputFragment > 0) then
        fragments[#fragments + 1] = currentInputFragment
        currentInputFragment = ""
    end
    return fragments, i
end

function ParseFile(filename)
    local f = assert(io.open(filename, "rb"))
    local content = f:read("*all")
    f:close()
    
    return ParseFraments(content)
end


local fragments = ParseFile("test.st")

local processed = ""

for k, v in pairs(fragments) do
    if (type(v) == "table") then
        processed = processed .. json.encode(v)
    else
        processed = processed .. v
    end
end

local outFile = assert(io.open("test.out", "w"))
outFile:write(processed .. "\n")
outFile:close()
