// RUN: %target-swift-frontend %s -emit-ir | %FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-%target-runtime

// REQUIRES: CPU=x86_64

// CHECK: [[A:%T13generic_types1AC]] = type <{ [[REF:%swift.refcounted]], [[INT:%TSi]] }>
// CHECK: [[INT]] = type <{ i64 }>
// CHECK: [[B:%T13generic_types1BC]] = type <{ [[REF:%swift.refcounted]], [[UNSAFE:%TSp]] }>
// CHECK: [[C:%T13generic_types1CC]] = type
// CHECK: [[D:%T13generic_types1DC]] = type

// CHECK-LABEL: @"$S13generic_types1ACMI" = internal global [16 x i8*] zeroinitializer, align 8

// CHECK-LABEL: @"$S13generic_types1ACMn" = hidden constant
// CHECK-SAME:   i32 -2147221296,
// CHECK-SAME:   @"$S13generic_typesMXM"
//               <name>
// CHECK-SAME:   @"$S13generic_types1ACMa"
// -- superclass
// CHECK-SAME:   i32 0,
// -- negative size in words
// CHECK-SAME:   i32 2,
// -- positive size in words
// CHECK-SAME:   i32 17,
// -- num immediate members
// CHECK-SAME:   i32 7,
// -- num fields
// CHECK-SAME:   i32 1,
// -- field offset vector offset
// CHECK-SAME:   i32 16,
// -- instantiation function
// CHECK-SAME:   @"$S13generic_types1ACMi"
// -- instantiation cache
// CHECK-SAME:   @"$S13generic_types1ACMI"
// -- num generic params
// CHECK-SAME:   i32 1,
// -- num generic requirement
// CHECK-SAME:   i32 0,
// -- num key arguments
// CHECK-SAME:   i32 1,
// -- num extra arguments
// CHECK-SAME:   i32 0,
// -- parameter descriptor 1
// CHECK-SAME:   i8 -128,

// CHECK-LABEL: @"$S13generic_types1ACMP" = internal constant
// CHECK-SAME:   void ([[A]]*)* @"$S13generic_types1ACfD",
// -- ivar destroyer
// CHECK-SAME:   i8* null,
// -- flags
// CHECK-SAME:   i32 {{3|2}},
// CHECK-SAME: }

// CHECK-LABEL: @"$S13generic_types1BCMI" = internal global [16 x i8*] zeroinitializer, align 8

// CHECK-LABEL: @"$S13generic_types1BCMn" = hidden constant
// CHECK-SAME:   @"$S13generic_types1BCMa"
// CHECK-SAME:   @"$S13generic_types1BCMi"
// CHECK-SAME:   @"$S13generic_types1BCMI"

// CHECK-LABEL: @"$S13generic_types1BCMP" = internal constant
// CHECK-SAME:   void ([[B]]*)* @"$S13generic_types1BCfD",
// -- ivar destroyer
// CHECK-SAME:   i8* null
// CHECK-SAME:   i32 {{3|2}},
// CHECK-SAME: }

// CHECK-LABEL: @"$S13generic_types1CCMP" = internal constant
// CHECK-SAME:   void ([[C]]*)* @"$S13generic_types1CCfD",
// -- ivar destroyer
// CHECK-SAME:   i8* null
// CHECK-SAME:   i32 {{3|2}},
// CHECK-SAME: }

// CHECK-LABEL: @"$S13generic_types1DCMP" = internal constant
// CHECK-SAME:   void ([[D]]*)* @"$S13generic_types1DCfD",
// -- ivar destroyer
// CHECK-SAME:   i8* null
// CHECK-SAME:   i32 {{3|2}},
// CHECK-SAME: }

// CHECK-LABEL: define{{( protected)?}} internal %swift.type* @"$S13generic_types1ACMi"(%swift.type_descriptor*, i8**) {{.*}} {
// CHECK:   [[T0:%.*]] = bitcast i8** %1 to %swift.type**
// CHECK:   %T = load %swift.type*, %swift.type** [[T0]],
// CHECK:   [[METADATA:%.*]] = call %swift.type* @swift_allocateGenericClassMetadata(%swift.type_descriptor* %0, i8** %1, i8** bitcast ({{.*}}* @"$S13generic_types1ACMP" to i8**))
// CHECK:   [[SELF_ARRAY:%.*]] = bitcast %swift.type* [[METADATA]] to i8**
// CHECK:   [[T1:%.*]] = getelementptr inbounds i8*, i8** [[SELF_ARRAY]], i64 10
// CHECK:   [[T0:%.*]] = bitcast %swift.type* %T to i8*
// CHECK:   store i8* [[T0]], i8** [[T1]], align 8
// CHECK:   ret %swift.type* [[METADATA]]
// CHECK: }

// CHECK-LABEL: define{{( protected)?}} internal %swift.type* @"$S13generic_types1BCMi"(%swift.type_descriptor*, i8**) {{.*}} {
// CHECK:   [[T0:%.*]] = bitcast i8** %1 to %swift.type**
// CHECK:   %T = load %swift.type*, %swift.type** [[T0]],
// CHECK:   [[METADATA:%.*]] = call %swift.type* @swift_allocateGenericClassMetadata(%swift.type_descriptor* %0, i8** %1, i8** bitcast ({{.*}}* @"$S13generic_types1BCMP" to i8**))
// CHECK:   [[SELF_ARRAY:%.*]] = bitcast %swift.type* [[METADATA]] to i8**
// CHECK:   [[T1:%.*]] = getelementptr inbounds i8*, i8** [[SELF_ARRAY]], i64 10
// CHECK:   [[T0:%.*]] = bitcast %swift.type* %T to i8*
// CHECK:   store i8* [[T0]], i8** [[T1]], align 8
// CHECK:   ret %swift.type* [[METADATA]]
// CHECK: }

class A<T> {
  var x = 0

  func run(_ t: T) {}
  init(y : Int) {}
}

class B<T> {
  var ptr : UnsafeMutablePointer<T>
  init(ptr: UnsafeMutablePointer<T>) {
    self.ptr = ptr
  }
  deinit {
    ptr.deinitialize(count: 1)
  }
}

class C<T> : A<Int> {}

class D<T> : A<Int> {
  override func run(_ t: Int) {}
}

struct E<T> {
  var x : Int
  func foo() { bar() }
  func bar() {}
}

class ClassA {}
class ClassB {}

// This type is fixed-size across specializations, but it needs to use
// a different implementation in IR-gen so that types match up.
// It just asserts if we get it wrong.
struct F<T: AnyObject> {
  var value: T
}
func testFixed() {
  var a = F(value: ClassA()).value
  var b = F(value: ClassB()).value
}
