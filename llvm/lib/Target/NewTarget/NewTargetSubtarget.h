/*
 * NewTargetSubtarget.h
 *
 *  Created on: Mar 7, 2013
 *      Author: andreu
 */

#ifndef NEWTARGETSUBTARGET_H_
#define NEWTARGETSUBTARGET_H_

#include "llvm/Target/TargetSubtargetInfo.h"
#include "llvm/MC/MCInstrItineraries.h"
#include <string>

#define GET_SUBTARGETINFO_HEADER
#include "NewTargetGenSubtargetInfo.inc"


namespace llvm {
class StringRef;

class NewTargetSubtarget : public NewTargetGenSubtargetInfo {
  virtual void anchor();
  InstrItineraryData InstrItins;
  
protected:
    
  // IsLittle - The target is Little Endian
  bool IsLittle;
  
public:
  /// This constructor initializes the data members to match that
  /// of the specified triple.
  ///
  NewTargetSubtarget(const std::string &TT, const std::string &CPU,
                  const std::string &FS);

  /// ParseSubtargetFeatures - Parses features string setting specified
  /// subtarget options.  Definition of function is auto generated by tblgen.
  void ParseSubtargetFeatures(StringRef CPU, StringRef FS);
  
  const InstrItineraryData &getInstrItineraryData() const { return InstrItins; }
};
} // End llvm namespace


#endif /* NEWTARGETSUBTARGET_H_ */
