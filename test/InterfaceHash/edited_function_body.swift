// RUN: mkdir -p %t
// RUN: %utils/split_file.py -o %t %s
// RUN: %target-swift-frontend -dump-interface-hash %t/a.swift 2> %t/a.hash
// RUN: %target-swift-frontend -dump-interface-hash %t/b.swift 2> %t/b.hash
// RUN: cmp %t/a.hash %t/b.hash

// BEGIN a.swift
func f() -> Int {
    return 0
}

// BEGIN b.swift
func f() -> Int {
    return 1
}
