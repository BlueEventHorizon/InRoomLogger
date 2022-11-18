//
//  LogOutput.swift
//  
//
//  Created by Katsuhiko Terada on 2022/11/18.
//

import Foundation

// ------------------------------------------------------------------------------------------
// MARK: - LogOutput
// ------------------------------------------------------------------------------------------

public protocol LogOutput {
    func log(_ information: LogInformation)
}
