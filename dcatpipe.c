// $ ./dcatpipe file1 file2
// - reads stdin and write it in file1
// - reads file2 and write it in stdout

// In a first terminal:
// $  tmux new-session -s sessionid bash
//
// In a second terminal:
// $ gcc dcatpipe.c -o dcatpipe
// $ rm -f /tmp/fifo1 /tmp/fifo2 ; mkfifo /tmp/fifo1 ; mkfifo /tmp/fifo2
// $ tmux pipe-pane -t sessionid:0.0 -I -O -o './dcatpipe /tmp/fifo1 /tmp/fifo2'
//
// In a third terminal:
// $ ./dcatpipe /tmp/fifo2 /tmp/fifo1


#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <termios.h>

int main(int argc, char* argv[]) {  

  struct termios termios;
  tcgetattr(0, &termios); cfmakeraw(&termios); tcsetattr(0, TCSANOW, &termios);
  tcgetattr(1, &termios); cfmakeraw(&termios); tcsetattr(1, TCSANOW, &termios);
  
  /* child 1: read stdin and redirect it to file argv[1] */
  if(fork() == 0) {
    int fifo1 = open(argv[1], O_WRONLY); // blocks until other end of fifo is opened!!!
    if(fifo1 < 0) { perror("open fifo1"); return -1; }
    struct termios termios; tcgetattr(fifo1, &termios); cfmakeraw(&termios); tcsetattr(fifo1, TCSANOW, &termios);
    // printf("open fifo1!\n");
    char buf[1];
    while(read(0, buf, 1) > 0) write(fifo1, buf, 1);
    close(fifo1);
    return 0;
  }

  /* fils 2:  read file argv[2] and redirect it to stdout */
  if(fork() == 0) {
    int fifo2 = open(argv[2], O_RDONLY);
    if(fifo2 < 0) { perror("open fifo2"); return -1; }
    struct termios termios; tcgetattr(fifo2, &termios); cfmakeraw(&termios); tcsetattr(fifo2, TCSANOW, &termios);
    // printf("open fifo2!\n");
    char buf[1];
    while(read(fifo2, buf, 1) > 0) write(1, buf, 1);
    close(fifo2);
    return 0;
  }

  wait(NULL);
  wait(NULL);
  
  return 0;
}
