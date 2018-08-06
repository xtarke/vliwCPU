/*
 * NewTargetMCAsmInfo.h
 *
 *  Created on: Mar 7, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETMCASMINFO_H_
#define NEWTARGETMCASMINFO_H_

#include "llvm/MC/MCAsmInfo.h"

namespace llvm {
  class Target;

  class NewTargetMCAsmInfo : public MCAsmInfo {
    virtual void anchor();
  public:
    explicit NewTargetMCAsmInfo();
  };

} // namespace llvm


#endif /* NEWTARGETMCASMINFO_H_ */
