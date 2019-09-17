//
//  Extensions.swift
//  NyamNyam
//
//  Created by Avazbek Kodiraliev on 4/2/19.
//  Copyright © 2019 Atay Sultangaziev. All rights reserved.
//

import UIKit


let imageCache = NSCache<NSString, AnyObject>()

private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
}

extension String
{
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint) 
    
    enum GradientOrientation {
        case topRightBottomLeft
        case topLeftBottomRight
        case horizontal
        case vertical
        
        var startPoint : CGPoint {
            return points.startPoint
        }
        
        var endPoint : CGPoint {
            return points.endPoint
        }
        
        var points : GradientPoints {
            switch self {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            }
        }
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]? = nil, orientation: GradientOrientation) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        
        //    layerMaxXMaxYCorner - bottom right corner
        //    layerMaxXMinYCorner - top right corner
        //    layerMinXMaxYCorner - bottom left corner
        //    layerMinXMinYCorner - top left corner
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case original  = 0.8
        case preview   = 0.4
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}

//MARK: - dataValidetion
extension Date{
    
    static func calculateDate(day:Int,month:Int,year:Int,hour:Int,minute:Int,second:Int) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let calculateData = formatter.date(from: "\(year)/\(month)/\(day)/\(hour):/\(minute)")
        return calculateData!
    }
    
    func getDayMonthYearHourMinuteSecond() -> (day:Int,month:Int,year:Int,hour:Int,minute:Int,second:Int) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        let month = calendar.component(.month, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        
        return (day,month,year,hour,minute,second)
    }
}


//MARK: - errors
extension NSError {
    
    convenience init(message:String?, code: Int = 200) {
        
        let errorMessage = message != nil ? message : NSLocalizedString("Ошибка", comment: "")
        
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey as String : errorMessage as Any
        ]
        
        self.init(domain: "",code: code, userInfo: userInfo)
    }
}


// MARK - textFieldEffects
//MARK: - button efects
extension UITextField{
    func pulsate(sender:UITextField) {
        
        let pulsate = CASpringAnimation(keyPath: "transform.scale")
        pulsate.duration = 0.0
        pulsate.repeatCount = 0
        pulsate.autoreverses = false
        pulsate.fromValue = 0.96
        pulsate.toValue = 0.99
        pulsate.autoreverses = false
        pulsate.initialVelocity = 0
        pulsate.damping = 0
        layer.add(pulsate, forKey: nil)
        
    }
    
    func pulsate(sender:UITextField,duration:Double) {
        
        let pulsate = CASpringAnimation(keyPath: "transform.scale")
        pulsate.duration = duration
        pulsate.repeatCount = 0
        pulsate.autoreverses = false
        pulsate.fromValue = 0.96
        pulsate.toValue = 0.99
        pulsate.autoreverses = false
        pulsate.initialVelocity = 0
        pulsate.damping = 1
        layer.add(pulsate, forKey: nil)
        
    }
    
    func shake(sender:UITextField) {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
        
    }
    
    func flash(sender:UITextField) {
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 1
            sender.backgroundColor = UIColor.orange
        }, completion: { completed in
            if completed {
                UIView.animate(withDuration: 0.3, animations: {
                    sender.backgroundColor = UIColor.clear
                }, completion: { completed in
                    if completed {
                    }
                })
            }
        })
        
    }
    
    
}

//MARK: - button efects
extension UIButton{
    func pulsate(sender:UIButton) {
        
        let pulsate = CASpringAnimation(keyPath: "transform.scale")
        pulsate.duration = 0.0
        pulsate.repeatCount = 0
        pulsate.autoreverses = false
        pulsate.fromValue = 0.96
        pulsate.toValue = 0.99
        pulsate.autoreverses = false
        pulsate.initialVelocity = 0
        pulsate.damping = 0
        layer.add(pulsate, forKey: nil)
        
    }
    
    
    func shake(sender:UIButton) {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
        
    }
    
    func flash(sender:UIButton) {
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 1
            sender.backgroundColor = UIColor.orange
        }, completion: { completed in
            if completed {
                UIView.animate(withDuration: 0.3, animations: {
                    sender.backgroundColor = UIColor.clear
                }, completion: { completed in
                    if completed {
                    }
                })
            }
        })
        
    }
    
    
}


//MARK: - image efects
extension UIImageView{
    func pulsate(sender:UIImageView) {
        
        let pulsate = CASpringAnimation(keyPath: "transform.scale")
        pulsate.duration = 1.0
        pulsate.repeatCount = 0
        pulsate.autoreverses = false
        pulsate.fromValue = 0.96
        pulsate.toValue = 0.99
        pulsate.autoreverses = false
        pulsate.initialVelocity = 1
        pulsate.damping = 0
        layer.add(pulsate, forKey: nil)
        
    }
    
    
    func shake(sender:UIImageView) {
        
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
        
    }
    
    func flash(sender:UIImageView) {
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 1
            sender.backgroundColor = UIColor.orange
        }, completion: { completed in
            if completed {
                UIView.animate(withDuration: 0.3, animations: {
                    sender.backgroundColor = UIColor.clear
                }, completion: { completed in
                    if completed {
                    }
                })
            }
        })
        
    }
    
    
}

//MARK: - custom frame border
extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: thickness)
            
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.bounds.height - thickness,  width: UIScreen.main.bounds.width, height: thickness)
            
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0,  width: thickness, height: self.bounds.height)
            
        case UIRectEdge.right:
            border.frame = CGRect(x: self.bounds.width - thickness, y: 0,  width: thickness, height: self.bounds.height)
        default:
            break
        }
        border.backgroundColor = color.cgColor;
        self.addSublayer(border)
    }
}

//MARK: - emailAndPassword validation
extension String{
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^[a-z]+[0-9a-z._%+-]+@[a-za-z0-9.-]+\\.[a-za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(testStr:String) -> Bool {
        let passwordRegEx = "(?:(?:(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_])|(?:(?=.*?[0-9])|(?=.*?[A-Z])|(?=.*?[-!@#$%&*ˆ+=_])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%&*ˆ+=_]))[A-Za-z0-9-!@#$%&*ˆ+=_]{6,64}"
        
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: testStr)
    }
    
    func isValidUsername(testStr:String) -> Bool {
        let usernameRegEx = "\\w{3,18}"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: testStr)
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{4}-\\d{3}-\\d{3}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    func isValidFullName(testStr:String) -> Bool {
        let fullnameRegEx = "^[А-Я][а-яА-Я]{2,}(?: [А-Я][а-яА-Я]*){0,2}$"
        let fullnameTest = NSPredicate(format:"SELF MATCHES %@", fullnameRegEx)
        return fullnameTest.evaluate(with: testStr)
    }
    
    func isValidMenuName(testStr:String) -> Bool {
        let fullnameRegEx = "^[а-яА-Я]+$"
        let fullnameTest = NSPredicate(format:"SELF MATCHES %@", fullnameRegEx)
        return fullnameTest.evaluate(with: testStr)
    }

    func isValidNumber(testStr:String) -> Bool {
        let fullnameRegEx = "^[0-9]*$"
        let fullnameTest = NSPredicate(format:"SELF MATCHES %@", fullnameRegEx)
        return fullnameTest.evaluate(with: testStr)
    }
    
    
}

//MARK: - callNumberValidation
extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}

extension CGSize{
    func sizeWith(width: CGFloat) -> CGSize {
        let ratio = self.width / width
        return CGSize(width: self.width * ratio, height: self.height * ratio)
    }
}
extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
