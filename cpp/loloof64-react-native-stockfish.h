#ifndef LOLOOF64_REACTNATIVESTOCKFISH_H
#define LOLOOF64_REACTNATIVESTOCKFISH_H

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#ifdef _WIN64
#define ssize_t __int64
#else
#define ssize_t long
#endif
#else
#include <unistd.h>
#endif

namespace loloof64_reactnativestockfish {
  // Runs the main stockfish loop
  int stockfish_main();

  // Send command to stockfish
  ssize_t stockfish_stdin_write(const char * data);

  // Reads stockfish output
  char * stockfish_stdout_read();
}

#endif /* LOLOOF64_REACTNATIVESTOCKFISH_H */
