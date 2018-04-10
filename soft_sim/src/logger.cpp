/* 
 * File:   logger.cpp
 * Author: xtarke
 * 
 * Created on July 19, 2013, 3:14 PM
 */

#include "logger.h"

logger* logger::instance = NULL;

logger& logger::get_instance() {
    if (!instance)
        instance = new logger;

    return *instance;
}