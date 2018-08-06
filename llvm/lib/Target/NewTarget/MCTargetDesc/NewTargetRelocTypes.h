/*
 * NewTargetRelocTypes.h
 *
 *  Created on: Apr 24, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETRELOCTYPES_H_
#define NEWTARGETRELOCTYPES_H_


namespace llvm{

namespace NewTarget {

	enum NewTargetRelocs{
		R_NONE = 0,
                R_PC23GOTO,  
                R_PC23CALL,  
                R_IMM9,
                R_IMM23,
                R_32,
                R_PC23PRELOAD,  
	};
}

}


#endif /* NEWTARGETRELOCTYPES_H_ */
