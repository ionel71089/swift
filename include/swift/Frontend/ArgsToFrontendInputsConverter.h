//===--- ArgsToFrontendInputsConverter.h ------------------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_FRONTEND_ARGSTOFRONTENDINPUTSCONVERTER_H
#define SWIFT_FRONTEND_ARGSTOFRONTENDINPUTSCONVERTER_H

#include "swift/AST/DiagnosticConsumer.h"
#include "swift/AST/DiagnosticEngine.h"
#include "swift/Frontend/FrontendOptions.h"
#include "llvm/Option/ArgList.h"

namespace swift {

/// Implement argument semantics in a way that will make it easier to have
/// >1 primary file (or even a primary file list) in the future without
/// breaking anything today.
///
/// Semantics today:
/// If input files are on command line, primary files on command line are also
/// input files; they are not repeated without -primary-file. If input files are
/// in a file list, the primary files on the command line are repeated in the
/// file list. Thus, if there are any primary files, it is illegal to have both
/// (non-primary) input files and a file list. Finally, the order of input files
/// must match the order given on the command line or the file list.
///
/// Side note:
/// since each input file will cause a lot of work for the compiler, this code
/// is biased towards clarity and not optimized.
/// In the near future, it will be possible to put primary files in the
/// filelist, or to have a separate filelist for primaries. The organization
/// here anticipates that evolution.

class ArgsToFrontendInputsConverter {
  DiagnosticEngine &Diags;
  const llvm::opt::ArgList &Args;
  FrontendInputsAndOutputs &InputsAndOutputs;

  llvm::opt::Arg const *const FilelistPathArg;
  llvm::opt::Arg const *const PrimaryFilelistPathArg;

  SmallVector<std::unique_ptr<llvm::MemoryBuffer>, 4> BuffersToKeepAlive;

  llvm::SetVector<StringRef> Files;

public:
  ArgsToFrontendInputsConverter(DiagnosticEngine &diags,
                                const llvm::opt::ArgList &args,
                                FrontendInputsAndOutputs &inputsAndOutputs);

  bool convert();

private:
  bool enforceFilelistExclusion();
  bool readInputFilesFromCommandLine();
  bool readInputFilesFromFilelist();
  bool forAllFilesInFilelist(llvm::opt::Arg const *const pathArg,
                             llvm::function_ref<void(StringRef)> fn);
  bool addFile(StringRef file);
  Optional<std::set<StringRef>> readPrimaryFiles();
  std::set<StringRef>
  createInputFilesConsumingPrimaries(std::set<StringRef> primaryFiles);
  bool checkForMissingPrimaryFiles(std::set<StringRef> primaryFiles);

  bool isSingleThreadedWMO() const;
};

} // namespace swift

#endif /* SWIFT_FRONTEND_ARGSTOFRONTENDINPUTSCONVERTER_H */
