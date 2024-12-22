#include "loloof64-react-native-stockfish.h"
#include "fixes/fixes.h"

#include <iostream>
#include <string>

#define BUFFER_SIZE 1024

int main(int, char **);

std::string data;
std::string err_data;
char buffer[BUFFER_SIZE + 1];
char err_buffer[BUFFER_SIZE + 1];

namespace loloof64_reactnativestockfish {
	const char *QUITOK = "quit\n";

	int stockfish_main() {
		int argc = 1;
		char *argv[] = {(char *)""};
		int exitCode = main(argc, argv);

		fakeout << QUITOK << "\n";

#if _WIN32
    	Sleep(100);
#else
    	usleep(100);
#endif

		fakeout.close();
		fakein.close();

		return exitCode;
	}

	ssize_t stockfish_stdin_write(const char * data) {
		std::string val(data);
		fakein << val << fakeendl;
		return val.length();
	}

	char * stockfish_stdout_read() {
		if (getline(fakeout, data)) {
			size_t len = data.length();
			size_t i;
			for (i = 0; i < len && i < BUFFER_SIZE; i++) {
				buffer[i] = data[i];
			}
			buffer[i] = 0;
			return buffer;
		}
		return nullptr;
	}

	char * stockfish_stderr_read() {
		if (getline(fakeerr, err_data)) {
			size_t len = err_data.length();
			size_t i;
			for (i = 0; i < len && i < BUFFER_SIZE; i++) {
				err_buffer[i] = err_data[i];
			}
			err_buffer[i] = 0;
			return err_buffer;
		}
		return nullptr;
	}
}
