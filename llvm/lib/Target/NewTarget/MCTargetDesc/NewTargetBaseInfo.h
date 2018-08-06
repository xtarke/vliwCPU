/*
 * NewTargetBaseInfo.h
 *
 *  Created on: Mar 28, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETBASEINFO_H_
#define NEWTARGETBASEINFO_H_

namespace llvm{

namespace NewTargetII {
  /// Target Operand Flag enum.
  enum TOF {
    //===------------------------------------------------------------------===//
    // Mips Specific MachineOperand flags.

    MO_NO_FLAG,
    
    MO_GOT,

    /// MO_ABS_HI/LO - Represents the hi or low part of an absolute symbol
    /// address.
    MO_ABS_HI,
    MO_ABS_LO,
    MO_ABS
  };

  const unsigned int BASE_ADDRESS = 0x00000000;
}
}

#endif /* NEWTARGETBASEINFO_H_ */
