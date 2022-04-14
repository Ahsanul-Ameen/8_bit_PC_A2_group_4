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

int yyparse(void);
int yylex(void);

FILE *fp;
ofstream codeout("MachineCode.out"), hexout("Logisim.txt");
extern FILE *yyin;
extern int line_count;
extern char* yytext;
int pc = 0;

map<string, SymbolInfo*> labels;
map<string , int > lineMap;


void yyerror(char *symfo) {
		printf(" error: %s : at line no %d\n ", symfo, line_count);
}


%}

%token ADD ADDI SUB SUBI AND ANDI OR ORI SLL SRL NOR SW LW BEQ BNEQ JMP COLON COMMA LPAREN RPAREN REG NUMBER ID


%%

start:  	statements
			{
				hexout << "v2.0 raw"<<endl;
				int insNo = 0;
				for(int i=0; i<$1->blocks.size(); i++)
				{
					string str = $1->blocks[i]->getMCode();
					//if str has opcode beq or bneq change lower 8 bits of str to (lower 8 bits - (insNo + 1))
					if(str.substr(0, 4) == "0000" || str.substr(0, 4) == "0100") {
						int low8 = stoi(str.substr(12, 8), 0, 2) - insNo -1;
						//cout<<low8<< "  "<< str.substr(12, 8)<<endl;
						string num = str.substr(0, 12) +  bitset<8>(low8).to_string();
						str = num;
						//string num = bitset<8>(immediate).to_string();
					}
					//codeout << "hj" << endl;
					if(str != "") {
						codeout << str << endl;

						bitset<20> bits(str);
        				hexout << hex << bits.to_ulong() << " ";
						insNo++;
					}
				}
			}
;

statements:	statement
			{
				SymbolInfo* symfo = new SymbolInfo();
				symfo->blocks.push_back($1);
				$$ = symfo;
			}
			| statements statement
			{
				$1->blocks.push_back($2);
				$$ = $1;
			}
;

statement: 	rtype
			{
				pc++;
				$$ = $1;
			}
			| itype
			{
				pc++;
				$$ = $1;
			}
			| jtype
			{
				pc++;
				$$ = $1;
			}
			| label
;

label: ID COLON
		{
			string symfo = bitset<8>(pc).to_string();
			map<string, SymbolInfo*>::iterator it;
			it = labels.find($1->codeBlock);
			if(it != labels.end())
			{
				it->second->codeBlock = symfo;
			}
			else
			{
				labels.insert(make_pair($1->codeBlock, new SymbolInfo(symfo)));
			}
		}
;

rtype: 	ADD REG COMMA REG COMMA REG
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			$$ = symfo;
		}
		| SUB REG COMMA REG COMMA REG
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			$$ = symfo;
		}
		| AND REG COMMA REG COMMA REG
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			$$ = symfo;
		}
		| OR REG COMMA REG COMMA REG
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			$$ = symfo;
		}
		| NOR REG COMMA REG COMMA REG
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			$$ = symfo;
		}
		| SLL REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);
			int shiftAmount = atoi($6->codeBlock.c_str());
			string num = bitset<4>(shiftAmount).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| SRL REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back(new SymbolInfo("0000"));
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);
			int shiftAmount = atoi($6->codeBlock.c_str());
			string num = bitset<4>(shiftAmount).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
;

itype: 	ADDI REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);

			int immediate = atoi($6->codeBlock.c_str());

			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| SUBI REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);
			int immediate = atoi($6->codeBlock.c_str());
			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| ANDI REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);
			int immediate = atoi($6->codeBlock.c_str());
			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| ORI REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($4);
			symfo->blocks.push_back($2);
			int immediate = atoi($6->codeBlock.c_str());
			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| LW REG COMMA NUMBER LPAREN REG RPAREN
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);
			int immediate = atoi($4->codeBlock.c_str());
			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| SW REG COMMA NUMBER LPAREN REG RPAREN
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($6);
			symfo->blocks.push_back($2);

			int immediate = atoi($4->codeBlock.c_str());

			string num = bitset<8>(immediate).to_string();
			symfo->blocks.push_back(new SymbolInfo(num));
			$$ = symfo;
		}
		| BEQ REG COMMA REG COMMA ID
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back($4);
			SymbolInfo* temp = new SymbolInfo("00000000");
			map<string, SymbolInfo*>::iterator it;
			it = labels.find($6->codeBlock);
			if(it != labels.end())
			{
				temp = it->second;
			}
			else
			{
				labels.insert(make_pair($6->codeBlock, temp));
			}
			symfo->blocks.push_back(temp);
			$$ = symfo;
		}
		| BNEQ REG COMMA REG COMMA ID
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back($4);
			SymbolInfo* temp = new SymbolInfo("00000000");
			map<string, SymbolInfo*>::iterator it;
			it = labels.find($6->codeBlock);
			if(it != labels.end())
			{
				temp = it->second;
			}
			else
			{
				labels.insert(make_pair($6->codeBlock, temp));
			}
			symfo->blocks.push_back(temp);
			$$ = symfo;
		}
		| BEQ REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back($4);

			int immediate = atoi($6->codeBlock.c_str());
			string num = bitset<8>(immediate+(pc+1)).to_string();
			SymbolInfo* temp = new SymbolInfo(num);

			symfo->blocks.push_back(temp);
			$$ = symfo;
		}
		| BNEQ REG COMMA REG COMMA NUMBER
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			symfo->blocks.push_back($2);
			symfo->blocks.push_back($4);

			int immediate = atoi($6->codeBlock.c_str());
			string num = bitset<8>(immediate+(pc+1)).to_string();
			SymbolInfo* temp = new SymbolInfo(num);

			symfo->blocks.push_back(temp);
			$$ = symfo;
		}
;

jtype: JMP ID
		{
			SymbolInfo* symfo = new SymbolInfo();
			symfo->blocks.push_back($1);
			SymbolInfo* temp = new SymbolInfo("00000000");
			map<string, SymbolInfo*>::iterator it;
			it = labels.find($2->codeBlock);
			if(it != labels.end())
			{
				temp = it->second;
			}
			else
			{
				labels.insert(make_pair($2->codeBlock, temp));
			}
			symfo->blocks.push_back(temp);
			symfo->blocks.push_back(new SymbolInfo("00000000"));
			$$ = symfo;

		}
;




%%

int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	yyin=fp;
	yyparse();
	codeout.close();

	return 0;
}
