local TokenTypes = {
    INVOKE = 1,
    LPAREN = 2,
    RPAREN = 3,
    COMMA = 4,
    STRINGLITTERAL = 5,
    IDENTIFIER = 6
}

local Token = {};

function Token:New(type, literalValue, start, stop)
    local o = {
        type = type,
        literalValue = literalValue
        start = start,
        stop = stop
    }
    setmetatable(o, self)
    self.__index = self
    return o
end


function lex(inputString)
    --Since every terminals starts with a different character, this is simple
    
    local currentIndex = 1;
    local rv = {}


    while (currentIndex <= #inputString) do
        local next = inputString:sub(currentIndex)
        if next == "§" then
            rv[#rv + 1] = Token:new(TokenType.INVOKE, "§", currentIndex, currentIndex)
            currentIndex = currentIndex + 1
        elseif next == "(" then
            rv[#rv + 1] = Token:new(TokenType.LPAREN, "(", currentIndex, currentIndex)
            currentIndex = currentIndex + 1
        elseif next == ")" then
            rv[#rv + 1] = Token:new(TokenType.RPAREN, ")", currentIndex, currentIndex)
            currentIndex = currentIndex + 1
        elseif next == "," then
            rv[#rv + 1] = Token:new(TokenType.COMMA, ",", currentIndex, currentIndex)
            currentIndex = currentIndex + 1
        elseif next == "\"" then
            --parse string
            --since lua patterns are not closed under unification, we have to manually parse each character
            local acc = "";
            currentIndex = currentIndex + 1;
            while true do
                local match = inputString:match("[^\"\\]*", currentIndex);
                if (match != nil) then
                    acc = acc .. match
                    currentIndex = currentIndex + #match
                else
                    local match = inputString:match("\\.", currentIndex);
                    if (match != nil) then
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
        else
            --parse identifier
            local match = inputString:match("[^0-9 )(\",§\n\r][^ )(\",§\n\r]*")
        end

    end
end


function ParseCall(inputStream)

end

function ParseActualArguments(inputStream)

end

function ParseInnerActaulArguments(inputStream)

end

function ParseNextArgument(inputStream)

end

function ParseExpr(inputStream)

end

function ParseExpr2(inputStream)

end

function ParseFunctionCall(inputStream)

end
