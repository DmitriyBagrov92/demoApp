//
//  String.swift
//

import UIKit

extension String {
    
    var URLEncode: String {
        let originalString = self
        let escapedString = originalString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        return escapedString!
    }
    
    var length: Int {
        return characters.count
    }
    
    var isEmail: Bool {
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regEx)
        return predicate.evaluateWithObject(self)
    }

    var trim: String {
        let charSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return String(format: "%@", self.stringByTrimmingCharactersInSet(charSet))
    }
    
    var onlyNumbers: String {
        let set = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let numbers = self.componentsSeparatedByCharactersInSet(set)
        return numbers.joinWithSeparator("")
    }

}

/**
 *  Calculating String Size
 */
extension String {
    
    func sizeWithFont(font: AnyObject) -> CGSize {
        let originalString = self as NSString
        return originalString.sizeWithAttributes([NSFontAttributeName: font])
    }
    
    func widthWithFont(font: AnyObject) -> CGFloat {
        return sizeWithFont(font).width
    }
    
    func heightForWidth(width: CGFloat, withFont font: AnyObject) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(boundingBox.height)
        
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(startIndex.advancedBy(r.startIndex)..<startIndex.advancedBy(r.endIndex))
    }
    
}

