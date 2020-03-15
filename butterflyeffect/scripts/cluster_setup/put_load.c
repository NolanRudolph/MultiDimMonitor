#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

FILE *fp;

void my_function(int signum){
	fclose(fp);
	exit(0);
}

int main() {
	printf("My PID: %d\n", getpid()); 
	fp = fopen((const char *)"load.txt", (const char * )"w+");	
	long total = 0;
	signal(SIGINT, my_function);
	//printf("I m here\n");
	while (1) {
		char buffer[2 * 1024 * 1024 + 1];
		for (int i = 0; i < 1024*1024; i++)
			buffer[i] = 'a';
		buffer[2 * 1024*1024] = '\0';
		//printf("I am here 2 \n");
		fputs(buffer, fp);
		fflush(fp);
		total += 1024*1024;
		if (total >= (long)4*1024*1024*1024)
			fseek(fp, 0, SEEK_SET);
		
	}
	return 0;
}
