//
//  Error.swift
//

import UIKit

class Error: ErrorType {
    
    // MARK: - Properties
    
    var errorType: ApplicationErrorType = .Unknow
    
    var localizedDescription: String?
    
    // MARK: - Lifecycle
    
    init(description: String) {
        self.localizedDescription = NSLocalizedString(description, comment: "")
    }
    
    init(errorType: ApplicationErrorType) {
        self.errorType = errorType
        self.localizedDescription = NSLocalizedString(errorType.rawValue, comment: "")
    }
    
    init(error: NSError) {
        self.localizedDescription = error.localizedDescription
    }

}
