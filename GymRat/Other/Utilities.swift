//
//  Utilities.swift
//  GymRat
//
//  Created by Jeffery Trotz on 4/21/19.
//  Copyright © 2019 Jeffery Trotz. All rights reserved.
//
// This class contains tools used by multiple other
// classes in my app
//

import Foundation

// Waits for the given delay, then runs the closure that it was passed
func afterDelay(_ seconds: Double, run: @escaping () -> Void)
{
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
