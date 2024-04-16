#include <stdio.h>
#include <string.h>

int main() {
	char *c = "'\\\\'";
	printf("c[0] = %c, c[1] = %c\n", c[0], c[1]);
	char ch;
	int n = strlen(c);
	if(n == 3) {
		ch = c[1];
	} else if (n == 4) {
		int result = sscanf(c,  "\'\\%s\'", &ch);
		switch(ch) { 
			case 'n':
				ch = '\n';
				break;
			case 't':
                ch = '\t';
				break;
			case 'r':
                ch = '\r';
				break;
			case '0':
                ch = '\0';
                break;
			case '\\':
                ch = '\\';
                break;
			case '\'':
                ch = '\'';
                break;
			case '\"':
                ch = '\"';
                break;
		}
	} else if (n == 6) {
		int result = sscanf(c,  "'\\x%hhx'", &ch);
	}
	return 0;
}
