/* 
 * File:   logger.h
 * Author: xtarke
 *
 * Created on July 19, 2013, 3:14 PM
 */

#ifndef LOGGER_H
#define	LOGGER_H

#include <stddef.h>
#include <iostream>
#include <fstream>
#include <assert.h>
#include <iostream>
#include <fstream>
#include <cerrno>
#include <cstring>
#include <cstdlib>

#include <string>
#include <streambuf>
#include <unistd.h>

#include <string>
#include <cstring>

#include <string>       // std::string
#include <iostream>     // std::cout
#include <sstream> 

#include <unistd.h>
#include <fcntl.h>
#include <execinfo.h>

#include <cxxabi.h>

#define LOG_NL logger::get_instance()
#define LOG logger::get_instance() <<  __PRETTY_FUNCTION__  << ": "  //__FILE__ "," << __LINE__ << ": "
#define LOG_L logger::get_instance() << __FILE__ "," << __LINE__ << "," <<__PRETTY_FUNCTION__ << ": "

using namespace std;

// This is the streambuffer; its function is to store formatted data and send
// it to a character output when solicited (sync/overflow methods) . You do not
// instantiate it by yourself on your application; it will be automatically used
// by an actual output stream (like the TimestampLoggerStream class defined ahead)

class loggerstreambuf : public streambuf {
protected:
    static const int bufferSize = 10; // size of data buffer
    char buffer[bufferSize]; // data buffer
    int file_log;

public:
    
    loggerstreambuf() {
        setp(buffer, buffer + (bufferSize - 1));

        file_log = open("soft-sim.log", O_WRONLY | O_CREAT | O_TRUNC | O_APPEND, S_IRUSR | S_IWUSR);

        assert(file_log >= 0 && "Error opening soft-sim.log file");
    }

    virtual ~loggerstreambuf() {
        sync();
    }

protected:

    char* LineHeader() {
//        time_t secondsSinceEpoch = time(NULL);
//        tm* brokenTime = localtime(&secondsSinceEpoch);
//        char buf[80];
//        strftime(buf, sizeof (buf), "[%d/%m/%y,%T] ", brokenTime);      
    }
    // flush the characters in the buffer

    int flushBuffer() {
        int num = pptr() - pbase();
        if (write(file_log, buffer, num) != num) {
            return EOF;
        }
        pbump(-num); // reset put pointer accordingly
        return num;
    }

    virtual int overflow(int c = EOF) {
        if (c != EOF) {
            *pptr() = c; // insert character into the buffer
            pbump(1);
        }
        if (flushBuffer() == EOF)
            return EOF;
        return c;
    }

    virtual int sync() {
        
        //cout << LineHeader() << flush;
        if (flushBuffer() == EOF)
            return -1; // ERROR
        return 0;
    }
};

//// This is the output stream; its function is to format data (using mainly the <<
//// operator) and send it to a streambuf to be stored and written to the output.
class logger : public ostream {
public:
    static logger &get_instance();

    ~logger() {
        delete rdbuf();
    }
private:
    static logger* instance;
    
    logger() : ostream(new loggerstreambuf()), ios(0) {
    }

    
};

#endif	/* LOGGER_H */

