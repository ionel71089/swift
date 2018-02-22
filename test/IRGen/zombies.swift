// RUN: %target-swift-frontend -assume-parsing-unqualified-ownership-sil -primary-file %s -O -emit-ir | %FileCheck %s

// rdar://24121475
//   Ideally, these wouldn't be in the v-table at all; but as long as they
//   are, we need to emit symbols for them.
class C {
  private var i: Int
  init(i: Int) { self.i = i }
}

// CHECK: @"$S7zombies1CC1i33_{{.*}}vg" = hidden alias void (), void ()* @_swift_dead_method_stub
// CHECK: define internal void @_swift_dead_method_stub()
