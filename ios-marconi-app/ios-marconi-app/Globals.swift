//
//  Globals.swift
//  ios-marconi-app
//
//  Created by Roman Vovk on 24.03.2021.
//  Copyright © 2021 Roman Vovk. All rights reserved.
//

func combine<A, B>(_ value: A, with closure: @escaping (A) -> B) -> () -> B {
    return { closure(value) }
}

func combine<A, B, C>(_ value1: A, _ value2: B, with closure: @escaping (A, B) -> C) -> () -> C {
    return { closure(value1, value2) }
}

func combine<A, B, C, D>(_ value1: A, _ value2: B, _ value3: C, with closure: @escaping (A, B, C) -> D) -> () -> D {
    return { closure(value1, value2, value3) }
}
