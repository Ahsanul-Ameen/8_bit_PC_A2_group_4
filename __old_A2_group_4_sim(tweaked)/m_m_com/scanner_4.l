%{

#include<bits/stdc++.h>
using namespace std;

struct SymbolInfo {
    string codeBlock = "";
    vector<SymbolInfo*> blocks;

    SymbolInfo(string f = "") { this->codeBlock = f; }

    string getMCode() {
        string s = "";
        for(SymbolInfo* str : blocks)
            s = s + str->codeBlock;
        return s;
    }

    bool operator==(SymbolInfo& rhs) { return this->codeBlock == rhs.codeBlock; }

    SymbolInfo operator=(SymbolInfo& rhs) {
      this->codeBlock = rhs.codeBlock;
      return *this;
    }

    ~SymbolInfo() {}
};

#define YYSTYPE SymbolInfo*
#include "y.tab.h"


extern YYSTYPE yylval;
void yyerror(char *);

extern int line_count = 0;

%}

number	[-+]?[0-9]+
identifier	[_a-zA-Z][a-zA-Z_0-9]*
newline	\n
whitespace	[ \t\r\v\f]+

SINGLELINECOMMENT 	 (\/\/((.*\\\n.*)|(.*))*)
MULTILINECOMMENT 	 (\/\*(("*"[^/]|[^*]))*\*\/)

%option noyywrap
%option caseless

%%


{whitespace}	|
{SINGLELINECOMMENT}	|		
{MULTILINECOMMENT}	{ }

{newline}	{ line_count++; }

"," 	{ return COMMA; }

"("		{ return LPAREN; }

")"		{ return RPAREN; }

":"		{ return COLON; }

{number}	{
					yylval = (YYSTYPE) new  SymbolInfo(yytext);
					return NUMBER;
				}

"add"	{
				yylval = (YYSTYPE) new  SymbolInfo("0110");
				return ADD;
			}

"addi"	{
					yylval = (YYSTYPE) new  SymbolInfo("1010");
					return ADDI;
				}

"sub"	{
				yylval = (YYSTYPE) new  SymbolInfo("1110");
				return SUB;
			}

"subi"	{
				yylval = (YYSTYPE) new  SymbolInfo("1111");
				return SUBI;
			}

"and"	{
				yylval = (YYSTYPE) new  SymbolInfo("1000");
				return AND;
			}

"andi"	{
					yylval = (YYSTYPE) new  SymbolInfo("0001");
					return ANDI;
				}

"or"	{
				yylval = (YYSTYPE) new  SymbolInfo("1100");
				return OR;
			}

"ori"	{
				yylval = (YYSTYPE) new  SymbolInfo("1011");
				return ORI;
			}

"sll"	{
				yylval = (YYSTYPE) new  SymbolInfo("1001");
				return SLL;
			}

"srl"	{
				yylval = (YYSTYPE) new  SymbolInfo("0111");
				return SRL;
			}

"nor"	{
				yylval = (YYSTYPE) new  SymbolInfo("0011");
				return NOR;
			}

"sw"	{
				yylval = (YYSTYPE) new  SymbolInfo("0101");
				return SW;
			}

"lw"	{
				yylval = (YYSTYPE) new  SymbolInfo("1101");
				return LW;
			}

"beq"	{
				yylval = (YYSTYPE) new  SymbolInfo("0000");
				return BEQ;
			}

"bneq"	{
					yylval = (YYSTYPE) new  SymbolInfo("0100");
					return BNEQ;
				}

"j"	{
			yylval = (YYSTYPE) new  SymbolInfo("0010");
			return JMP;
		}

"$zero"	{
					yylval = (YYSTYPE) new  SymbolInfo("0000");
					return REG;
				}

"$sp"	{
				yylval = (YYSTYPE) new  SymbolInfo("0001");
				return REG;
			}

"$t0"	{
				yylval = (YYSTYPE) new  SymbolInfo("0010");
				return REG;
			}

"$t1"	{
				yylval = (YYSTYPE) new  SymbolInfo("0011");
				return REG;
			}

"$t2"	{
				yylval = (YYSTYPE) new  SymbolInfo("0100");
				return REG;
			}

"$t3"	{
				yylval = (YYSTYPE) new  SymbolInfo("0101");
				return REG;
			}

"$t4"	{
				yylval = (YYSTYPE) new  SymbolInfo("0110");
				return REG;
			}

"$s0"	{
				yylval = (YYSTYPE) new  SymbolInfo("1000");
				return REG;
			}

"$s1"	{
				yylval = (YYSTYPE) new  SymbolInfo("1001");
				return REG;
			}

"$s2"	{
				yylval = (YYSTYPE) new  SymbolInfo("1010");
				return REG;
			}

"$s3"	{
				yylval = (YYSTYPE) new  SymbolInfo("1011");
				return REG;
			}

"$s4"	{
				yylval = (YYSTYPE) new  SymbolInfo("1100");
				return REG;
			}

"$s5"	{
				yylval = (YYSTYPE) new  SymbolInfo("1101");
				return REG;
			}

"$s6"	{
				yylval = (YYSTYPE) new  SymbolInfo("1110");
				return REG;
			}

"$s7"	{
				yylval = (YYSTYPE) new  SymbolInfo("1111");
				return REG;
			}


{identifier} {
					yylval = (YYSTYPE) new  SymbolInfo(yytext);
					return ID;
				}

%%
