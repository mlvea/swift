// RUN: %empty-directory(%t)
// RUN: %target-swift-frontend -enable-experimental-feature Embedded -wmo -emit-ir %s | %FileCheck %s --check-prefix=IR
// RUN: %target-swift-frontend -enable-experimental-feature Embedded -wmo -c %s -o %t/main.o
// RUN: %target-embedded-link %target-clang-resource-dir-opt %t/main.o -o %t/a.out -dead_strip
// RUN: %target-run %t/a.out | %FileCheck %s

// REQUIRES: executable_test
// REQUIRES: optimized_stdlib
// REQUIRES: OS=macosx || OS=linux-gnu || OS=none-eabi || OS=none-elf || OS=wasip1
// REQUIRES: swift_feature_Embedded
// XFAIL: swift_test_mode_optimize_none_with_opaque_values

// Issue #89581: constructing a concrete finite pack as a stored tuple must
// compile and run in Embedded Swift at -Onone. IRGen used to project the
// destination tuple from TupleTypeMetadata.Elements, but embedded tuple
// metadata is only a value-witness table plus a kind.

struct Values<each Value> {
  var values: (repeat each Value)
}

print("Before Values is constructed")
let values = Values(values: (true, "Hello!", 0))
print("After Values is constructed")
print(values.values.0)
print(values.values.1)
print(values.values.2)

// IR: @tuple_element_offsets
// IR-NOT: %swift.tuple_type

// CHECK: Before Values is constructed
// CHECK-NEXT: After Values is constructed
// CHECK-NEXT: true
// CHECK-NEXT: Hello!
// CHECK-NEXT: 0
