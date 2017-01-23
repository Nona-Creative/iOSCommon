//
//  ValidatingTextField.swift
//
//  Created by David O'Reilly on 2015/08/23.
//  Copyright © 2015 David O'Reilly All rights reserved.
//

import UIKit
import ReactiveSwift

#if LIBPHONENUMBER
import libPhoneNumber_iOS
#endif

protocol ValidatingTextFieldValidator: class {

    /**
     Validate the supplied text field
     - returns: The validation status of the text field
     */
    func validateTextField(_ textField: ValidatingTextField) -> ValidatingTextField.ValidationStatus
}

protocol ValidatingTextFieldDelegate: UITextFieldDelegate {

    func keyboardDonePressed()
}

@IBDesignable
/**
 Text field subclass with a lot of validation options and appearance changes to reflect validation state
 */
class ValidatingTextField: UITextField, UITextFieldDelegate, ValidatingTextFieldValidator {

    struct Appearance {
        var defaultBorderColor: UIColor
        var validBorderColor: UIColor
        var invalidBorderColor: UIColor
        var defaultTextColor: UIColor
        var validTextColor: UIColor
        var invalidTextColor: UIColor
        var disabledTextColor: UIColor
        var showSecureTextTintColor: UIColor
        var rightImageShowSecureText: UIImage?
        var showSecureTextText: String?
        var hideSecureTextText: String?
        var cornerRadius: CGFloat
        var borderWidth: CGFloat
        var rightImageValid: UIImage?
        var rightViewInset: CGFloat
        var textInsetLeft: CGFloat
        var textInsetRight: CGFloat
        var textInsetRightEditing: CGFloat
        var textInsetRightPlaceholder: CGFloat
        var validationAnimationLength: Double
    }

    var appearance: Appearance {
        return Appearance(defaultBorderColor: UIColor.lightGray,
                          validBorderColor: UIColor.green,
                          invalidBorderColor: UIColor.red,
                          defaultTextColor: UIColor.lightGray,
                          validTextColor: UIColor.green,
                          invalidTextColor: UIColor.red,
                          disabledTextColor: UIColor.lightGray,
                          showSecureTextTintColor: UIColor.black,
                          rightImageShowSecureText: nil,
                          showSecureTextText: nil,
                          hideSecureTextText: nil,
                          cornerRadius: 2,
                          borderWidth: 0.5,
                          rightImageValid: nil,
                          rightViewInset: 13,
                          textInsetLeft: 10,
                          textInsetRight: 10,
                          textInsetRightEditing: 5,
                          textInsetRightPlaceholder: 15,
                          validationAnimationLength: 0.25)
    }

    enum ValidationState {
        case `default`
        case valid
        case invalid
    }

    enum ValidationStatus: Hashable {
        case notValidated
        case valid
        case empty
        case short(length: Int?, minimumLength: Int?)
        case long(length: Int?, maximumLength: Int?)
        case low(value: Int?, minimumValue: Int?)
        case high(value: Int?, maximumValue: Int?)
        case malformed
        case mismatch

        var hashValue: Int {

            switch self {
            case .notValidated:
                return 1
            case .valid:
                return 2
            case .empty:
                return 3
            case .short:
                return 4
            case .long:
                return 5
            case .low:
                return 6
            case .high:
                return 7
            case .malformed:
                return 8
            case .mismatch:
                return 9
            }
        }
    }

    enum ValidationOptions: Hashable {
        /** Validate whenever editing and the value changes
         - parameter automaticInvalid: Automatically show invalid status
         */
        case validateEditingChanged(automaticInvalid: Bool)
        /** Validate whenever editing ends
         - parameter automaticInvalid: Automatically show invalid status
         */
        case validateEditingDidEnd(automaticInvalid: Bool)
        /** Reset invalid status when editing begins */
        case clearEditingDidBegin
        /** Don't show a valid status on this field unless explicitly set */
        case dontShowValid

        var hashValue: Int {
            switch self {
            case .validateEditingChanged(let automaticInvalid):
                return 1 + (automaticInvalid ? 1 : 0)
            case .validateEditingDidEnd(let automaticInvalid):
                return 3 + (automaticInvalid ? 1 : 0)
            case .clearEditingDidBegin:
                return 5
            case .dontShowValid:
                return 6
            }
        }
    }

    enum ValidationChecks: Hashable {
        /** Check that the field is not empty */
        case notEmpty
        /** Check that the field is the same or longer than the minimum length specified in mnimumLength */
        case minimumLength(minimumLength: Int)
        /** Check that the field is the same or shorter than the maximum length specified in maximumLength */
        case maximumLength(maximumLength: Int)
        /** Check that the field is a valid email address */
        case email
        /** Check that the field contains a valid phone number */
        case phoneNumber
        /** Check that the field is a valid currency amount */
        case numeric
        /** Check that the field is a valid currency amount */
        case currency
        /** Check that the field is a number greater than or equal to the minimum value specified in minimumValue */
        case minimumValue(minimumValue: Int)
        /** Check that the field is a number greater than or equal to the maximum value specified in maximumValue */
        case maximumValue(maximumValue: Int)
        /** Check that the field is a potentially valid credit card number */
        case luhn
        /** Check if the contents of this field matches another field */
        case matchField(field: UITextField)

        var hashValue: Int {
            switch self {
            case .notEmpty:
                return 1
            case .minimumLength:
                return 2
            case .maximumLength:
                return 3
            case .email:
                return 4
            case .phoneNumber:
                return 5
            case .numeric:
                return 6
            case .currency:
                return 7
            case .minimumValue:
                return 8
            case .maximumValue:
                return 9
            case .luhn:
                return 10
            case .matchField:
                return 11
            }
        }
    }

    // MARK: - IBInspectable

    @IBInspectable var defaultBorderColor: UIColor!
    @IBInspectable var validBorderColor: UIColor!
    @IBInspectable var invalidBorderColor: UIColor!
    @IBInspectable var defaultTextColor: UIColor!
    @IBInspectable var validTextColor: UIColor!
    @IBInspectable var invalidTextColor: UIColor!
    @IBInspectable var disabledTextColor: UIColor!
    @IBInspectable var showSecureTextTintColor: UIColor!
    @IBInspectable var rightImageValid: UIImage? {
        didSet {
            setupRightView()
        }
    }

    @IBInspectable var rightViewInset: CGFloat!
    @IBInspectable var textInsetLeft: CGFloat!
    @IBInspectable var textInsetRight: CGFloat!
    @IBInspectable var textInsetRightEditing: CGFloat!
    @IBInspectable var textInsetRightPlaceholder: CGFloat!
    @IBInspectable var showSecureTextToggle: Bool = false

    @IBInspectable var rightImageShowSecureText: UIImage? {
        didSet {
            setupShowSecureTextView()
        }
    }

    @IBInspectable var showSecureTextText: String? {
        didSet {
            setupShowSecureTextView()
        }
    }

    @IBInspectable var hideSecureTextText: String? {
        didSet {
            setupShowSecureTextView()
        }
    }

    @IBInspectable var cornerRadius: CGFloat? {
        didSet {
            layer.cornerRadius = cornerRadius ?? 0
        }
    }

    @IBInspectable var borderWidth: CGFloat? {
        didSet {
            layer.borderWidth = borderWidth ?? 0
        }
    }

    // FIXME: what are we doing here
    // @IBInspectable var minimumFontSize: CGFloat
    // @IBInspectable var textColor

    // MARK: - IBOutlets

    /** The next field that will become first responder after this one - used for keyboard return navigation */
    @IBOutlet weak var nextField: UIView?

    // MARK: - Public properties

    override var delegate: UITextFieldDelegate? {
        didSet {
            // Make the actual delegate get called after our own internal delegate
            if self.delegate != nil && self.delegate !== self {
                self.chainDelegate = self.delegate
                self.delegate = self
            }
        }
    }

    /** The validation delegate for this text field */
    weak var validator: ValidatingTextFieldValidator!

    /** Options bitmask using OrderInTextFieldValidationOptions enum */
    var validationOptions: Set<ValidationOptions> = Set<ValidationOptions>() {
        didSet {
            if validationOptions.contains(.clearEditingDidBegin) {
                self.addTarget(self, action: #selector(ValidatingTextField.resetInvalid), for: .editingDidBegin)
            } else {
                self.removeTarget(self, action: #selector(ValidatingTextField.resetInvalid), for: .editingDidBegin)
            }
        }
    }

    /** The validation checks to perform if using the built in default validator */
    var validationChecks: Set<ValidationChecks> = Set<ValidationChecks>() {
        didSet {
            _validationStatus.value = .notValidated
        }
    }

    #if LIBPHONENUMBER
    /** Country code for phone number validation **/
    var phoneNumberCountryCode: String? {
        didSet {
            phoneNumberFormatter = NBAsYouTypeFormatter(regionCode: phoneNumberCountryCode)
            phoneNumberUtil = NBPhoneNumberUtil()
            do {
                let example = try phoneNumberUtil.getExampleNumber(forType: phoneNumberCountryCode, type: .MOBILE)

                let exampleFormat = try phoneNumberUtil.format(example, numberFormat: .NATIONAL)

                self.placeholder = "e.g. \(exampleFormat)"
                if phoneNumberCountryCode!.lowercased() == "za" {
                    self.validationChecks.insert(.minimumLength(minimumLength: 12))
                    self.limitMaximumLength = 12
                } else {
                    self.validationChecks.remove(.minimumLength(minimumLength: 12))
                    self.limitMaximumLength = 0
                }
            } catch {
            }
        }
    }
    #endif

    /** The maximum length for the field, enforced if not 0 */
    var limitMaximumLength: Int = 0

    /** Another text field that this one should match */
    weak var matchField: ValidatingTextField?

    /** Stop all input for this field */
    var ignoreInput = false

    /** The current validation status of the field after last validation check */
    fileprivate var _validationStatus: MutableProperty<ValidationStatus> = MutableProperty<ValidationStatus>(.notValidated)
    var validationStatus: MutableProperty<ValidationStatus> {
        validate(automatic: true, editingChanged: false, editingDidEnd: false)
        return _validationStatus
    }

    /** The current validation state of the field after last validation check */
    var validationState: ValidationState = .default {
        didSet {
            guard oldValue != validationState else {
                return
            }

            switch validationState {
            case .default:
                setTextColorAnimate(isEnabled ? defaultTextColor : disabledTextColor)
                setBorderColor(defaultBorderColor, withAnimation: true)
                setDisplayRightImageValid(false)
                break
            case .valid:
                setTextColorAnimate(validTextColor)
                setBorderColor(validBorderColor, withAnimation: true)
                setDisplayRightImageValid(true)
                break
            case .invalid:
                setTextColorAnimate(invalidTextColor)
                setBorderColor(invalidBorderColor, withAnimation: true)
                setDisplayRightImageValid(false)
                break
            }
        }
    }

    #if LIBPHONENUMBER
    /** Phone number in international format based on text and phoneNumberCountryCode */
    var internationalPhoneNumberText: String? {
        get {
            do {
                let myNumber = try phoneNumberUtil.parse(text!, defaultRegion: phoneNumberCountryCode)
                return try self.phoneNumberUtil.format(myNumber, numberFormat: .E164)
            } catch {
                return nil
            }
        }
        set(value) {
            phoneNumberUtil = NBPhoneNumberUtil()
            do {
                let myNumber = try phoneNumberUtil.parse(value, defaultRegion: "za")
                text = try phoneNumberUtil.format(myNumber, numberFormat: .NATIONAL)
                var countryCode = phoneNumberUtil.getRegionCode(forCountryCode: myNumber.countryCode)
                if countryCode == nil {
                    countryCode = "za"
                }
                phoneNumberCountryCode = countryCode
            } catch {
            }
        }
    }
    #endif

    var validationMinimumValue: Int? {
        for validationCheck in validationChecks {
            switch validationCheck {
            case .minimumValue(let minimumValue):
                return minimumValue
            default:
                break
            }
        }
        return nil
    }

    var validationMaximumValue: Int? {
        for validationCheck in validationChecks {
            switch validationCheck {
            case .maximumValue(let maximumValue):
                return maximumValue
            default:
                break
            }
        }
        return nil
    }

    // MARK: - Private properties

    fileprivate var chainDelegate: UITextFieldDelegate?
    fileprivate var lastValidated: String = ""

    fileprivate var displayButton: UIButton!

    fileprivate var rightViewValid: UIView?
    fileprivate var displayingRightViewValid = false

    #if LIBPHONENUMBER
    fileprivate var phoneNumberUtil: NBPhoneNumberUtil!
    fileprivate var phoneNumberFormatter: NBAsYouTypeFormatter!
    #endif

    fileprivate var leftViewWidth: CGFloat {
        if let leftView = leftView {
            return leftView.frame.size.width
        } else {
            return 0
        }
    }

    fileprivate var rightViewWidth: CGFloat {
        if let rightView = rightView {
            return rightView.frame.size.width
        } else {
            return 0
        }
    }

    fileprivate var isValidEmail: Bool {
        let filterString = ".+@.+\\.[A-Za-z]{2}[A-Za-z]*"
        // let filterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" //Stricter

        let emailTest = NSPredicate(format: "SELF MATCHES %@", filterString)
        return emailTest.evaluate(with: self.text!)
    }

    #if LIBPHONENUMBER
    fileprivate var isValidPhoneNumber: Bool {
        do {
            let myNumber = try phoneNumberUtil.parse(self.text!, defaultRegion: phoneNumberCountryCode)
            return self.phoneNumberUtil.isValidNumber(myNumber)
        } catch {
            return false
        }
    }
    #endif

    fileprivate var isValidLuhn: Bool {
        var isOdd = true
        var oddSum = 0
        var evenSum = 0

        let string = self.text!

        for i in (0 ..< string.characters.count).reversed() {

            guard let digit = Int(string[i]) else {
                return false
            }

            if isOdd {
                oddSum += digit
            } else {
                evenSum += digit / 5 + (2 * digit) % 10
            }

            isOdd = !isOdd
        }

        return ((oddSum + evenSum) % 10 == 0)
    }

    // MARK: - IBDesignable Overrides

    override func prepareForInterfaceBuilder() {
        visualSetup()
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaults()
    }

    override func awakeFromNib() {
        setup()
    }

    // MARK: - Public functions

    /**
     Perform validation on the textField with the configured delegate, changing its appearance depending on the outcome
     - returns: The result of the validation operation
     */
    @discardableResult
    func validate() -> ValidationStatus {

        return validate(automatic: false, editingChanged: false, editingDidEnd: false)
    }

    /**
     Reset the textField to a default validation state
     */
    func resetValidation() {
        validationState = .default
    }

    /**
     Reset the field to a default validation only if it was previously set to invalid
     */
    func resetInvalid() {
        if validationState == .invalid {
            validationState = .default
        }
    }

    // MARK: - Callbacks

    /**
     Callback function for text field changes
     */
    func validateAutomaticEditingChanged(_: UITextField) {
        validate(automatic: true, editingChanged: true, editingDidEnd: false)
    }

    /**
     Callback function for text field changes
     */
    func validateAutomaticEditingDidEnd(_: UITextField) {
        layoutIfNeeded() // Workaround for iOS bug where text jumps and animates down after editing ends
        validate(automatic: true, editingChanged: false, editingDidEnd: true)
    }

    /**
     Display password button clicked
     */
    func toggleSecureTextEntry() {
        // Workaround iOS bug  - font issues when changing from secure to insecure text entry
        if isFirstResponder && isSecureTextEntry {
            let selRange = selectedTextRange
            resignFirstResponder()
            isSecureTextEntry = !isSecureTextEntry
            becomeFirstResponder()
            selectedTextRange = textRange(from: selRange!.start, to: selRange!.end)
        } else {
            isSecureTextEntry = !isSecureTextEntry
        }

        if showSecureTextText != nil {
            if isSecureTextEntry {
                displayButton.setTitle(showSecureTextText, for: UIControlState())
            } else {
                displayButton.setTitle(hideSecureTextText, for: UIControlState())
            }
        }
    }

    // MARK: Private functions

    fileprivate func setupDefaults() {
        // Border
        if cornerRadius == nil {
            cornerRadius = appearance.cornerRadius
        }

        if borderWidth == nil {
            borderWidth = appearance.borderWidth
        }

        // Colors
        if defaultBorderColor == nil {
            defaultBorderColor = appearance.defaultBorderColor
        }
        if validBorderColor == nil {
            validBorderColor = appearance.validBorderColor
        }
        if invalidBorderColor == nil {
            invalidBorderColor = appearance.invalidBorderColor
        }
        if defaultTextColor == nil {
            defaultTextColor = appearance.defaultTextColor
        }
        if validTextColor == nil {
            validTextColor = appearance.validTextColor
        }
        if invalidTextColor == nil {
            invalidTextColor = appearance.invalidTextColor
        }
        if disabledTextColor == nil {
            disabledTextColor = appearance.disabledTextColor
        }

        if showSecureTextTintColor == nil {
            showSecureTextTintColor = appearance.showSecureTextTintColor
        }

        // Insets
        if rightViewInset == nil {
            rightViewInset = appearance.rightViewInset
        }
        if textInsetLeft == nil {
            textInsetLeft = appearance.textInsetLeft
        }
        if textInsetRight == nil {
            textInsetRight = appearance.textInsetRight
        }
        if textInsetRightEditing == nil {
            textInsetRightEditing = appearance.textInsetRightEditing
        }

        // Right image
        if rightImageValid == nil {
            rightImageValid = appearance.rightImageValid
        }

        if rightImageShowSecureText == nil {
            rightImageShowSecureText = appearance.rightImageShowSecureText
        }

        if showSecureTextText == nil {
            showSecureTextText = appearance.showSecureTextText
        }

        if hideSecureTextText == nil {
            hideSecureTextText = appearance.hideSecureTextText
        }
    }

    fileprivate func setup() {
        visualSetup()
        self.delegate = self
        self.validator = self

        // FIXME: right image / validation image

        addTarget(self, action: #selector(ValidatingTextField.validateAutomaticEditingChanged(_:)), for: .editingChanged)
        addTarget(self, action: #selector(ValidatingTextField.validateAutomaticEditingDidEnd(_:)), for: .editingDidEnd)
    }

    fileprivate func visualSetup() {

        // Border
        borderStyle = .none
        self.layer.cornerRadius = cornerRadius!
        self.layer.borderWidth = borderWidth!

        setBorderColor(defaultBorderColor, withAnimation: false)
        textColor = isEnabled ? defaultTextColor : disabledTextColor

        setupRightView()
        setupShowSecureTextView()
    }

    fileprivate func setupRightView() {
        if let rightImageValid = rightImageValid {
            let imageView: UIImageView = UIImageView(image: rightImageValid)
            rightViewValid = UIView(frame: CGRect(x: 0, y: 0, width: rightImageValid.size.width + rightViewInset, height: rightImageValid.size.height))
            rightViewValid!.addSubview(imageView)
            imageView.frame = CGRect(x: 0, y: 0, width: rightImageValid.size.width, height: rightImageValid.size.height)
        }
    }

    fileprivate func setupShowSecureTextView() {
        // Password
        if isSecureTextEntry && showSecureTextToggle {
            self.rightViewMode = .always

            displayButton = UIButton(type: .system)
            if let image = rightImageShowSecureText {
                displayButton.tintColor = showSecureTextTintColor
                displayButton.setImage(image, for: UIControlState())
                displayButton.frame = CGRect(x: 0, y: 0, width: image.size.width + rightViewInset, height: image.size.height)
            } else {
                displayButton.setTitle(showSecureTextText, for: UIControlState())
                displayButton.sizeToFit()
            }

            displayButton.addTarget(self, action: #selector(ValidatingTextField.toggleSecureTextEntry), for: .touchUpInside)
            self.rightView = displayButton
        }
    }

    fileprivate func setDisplayRightImageValid(_ display: Bool) {
        displayingRightViewValid = display
        if let view = rightViewValid {
            if display {
                if self.rightView == nil {
                    self.rightViewMode = .always
                    self.rightView = view
                    self.rightView!.alpha = 0
                }
                UIView.animate(withDuration: appearance.validationAnimationLength, animations: {
                    view.alpha = 1
                })
            } else { // not display
                if self.rightView != nil {
                    UIView.animate(withDuration: appearance.validationAnimationLength, animations: {
                        view.alpha = 0
                    }, completion: { _ in
                        if !self.displayingRightViewValid {
                            self.rightViewMode = .never
                            self.rightView = nil
                        }
                    })
                }
            }
        }
    }

    fileprivate func setTextColorAnimate(_ color: UIColor) {

        // This is a placeholder in case we decide to do this animated later
        textColor = color
    }

    fileprivate func setBorderColor(_ color: UIColor, withAnimation animate: Bool) {

        if animate {
            let animation = CABasicAnimation(keyPath: "borderColor")
            animation.fromValue = layer.borderColor
            animation.toValue = color.cgColor
            layer.borderColor = color.cgColor
            animation.duration = appearance.validationAnimationLength
            layer.add(animation, forKey: "borderColor")
        } else {
            layer.borderColor = color.cgColor
        }
    }

    @discardableResult
    fileprivate func validate(automatic: Bool, editingChanged changed: Bool, editingDidEnd didEnd: Bool) -> ValidationStatus {

        #if LIBPHONENUMBER
        if self.validationChecks.contains(.phoneNumber) {
            let numbersOnly = self.phoneNumberUtil.normalizePhoneNumber(self.text!)
            if numbersOnly != "" {
                let newText = self.phoneNumberFormatter.inputStringAndRememberPosition(numbersOnly)
                self.text = newText
            }
        }
        #endif

        if _validationStatus.value == .notValidated || !(lastValidated == text) {
            _validationStatus.value = validator.validateTextField(self)
            lastValidated = text!
        }

        if _validationStatus.value == .valid {

            if automatic { // OK and automatic
                if !changed && !didEnd {
                    // self.validationState = self.validationState //No change
                } else if (validationOptions.contains(.validateEditingChanged(automaticInvalid: true)) || validationOptions.contains(.validateEditingChanged(automaticInvalid: false))) && changed && !validationOptions.contains(.dontShowValid) {
                    self.validationState = .valid
                } else if (validationOptions.contains(.validateEditingDidEnd(automaticInvalid: true)) || validationOptions.contains(.validateEditingDidEnd(automaticInvalid: false))) && didEnd && !validationOptions.contains(.dontShowValid) {
                    self.validationState = .valid
                }
            } else { // OK and not automatic
                if !self.validationOptions.contains(.dontShowValid) {
                    self.validationState = .valid
                }
            }
        } else {
            if automatic { // Not OK and automatic
                if !changed && !didEnd {
                    // self.validationState = self.validationState //No change
                } else if self.validationOptions.contains(.validateEditingChanged(automaticInvalid: true)) && changed { // If automatic invalid then show, else just set default
                    self.validationState = .invalid
                } else if self.validationOptions.contains(.validateEditingDidEnd(automaticInvalid: true)) && didEnd {
                    self.validationState = .invalid
                } else {
                    self.validationState = .default
                }
            } else { // Not OK and not automatic
                self.validationState = .invalid
            }
        }

        return _validationStatus.value
    }

    fileprivate func currencyCheckTextField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        guard validationChecks.contains(.currency) else {
            return true
        }

        let numbers: String = "0123456789"
        let numbersPeriod: String = "01234567890."
        let numbersComma: String = "0123456789,"

        if range.length > 0 && string.characters.count == 0 {
            // enable delete
            return true
        }

        let symbol = (Locale.current as NSLocale).object(forKey: NSLocale.Key.decimalSeparator) as! String
        if range.location == 0 && (string.substring(to: string.characters.index(string.startIndex, offsetBy: 1)) == symbol) {
            // decimalseparator should not be first
            return false
        }
        if string.components(separatedBy: symbol).count > 2 {
            // Paste with multiple separators.
            return false
        }
        let characterSet: CharacterSet
        let separatorRange = textField.text!.range(of: symbol)
        if separatorRange == nil {
            let nSeparatorRange = string.range(of: symbol)
            if let nSeparatorRange = nSeparatorRange {
                if (string.characters.count - string.characters.distance(from: string.startIndex, to: nSeparatorRange.lowerBound)) + (self.text!.characters.count - range.location) > 3 {
                    // Check for pasting content with separator that would have too many digits after separator
                    return false
                }
            }
            if symbol == "." {
                characterSet = CharacterSet(charactersIn: numbersPeriod).inverted
            } else {
                characterSet = CharacterSet(charactersIn: numbersComma).inverted
            }
        } else if string.components(separatedBy: symbol).count == 1 {
            // No more separators if we already have one
            // allow 2 characters after the decimal separator
            if range.location > textField.text!.characters.distance(from: textField.text!.startIndex, to: separatorRange!.lowerBound) && self.text!.characters.count - textField.text!.characters.distance(from: textField.text!.startIndex, to: separatorRange!.lowerBound) + string.characters.count > 3 {
                return false
            }
            characterSet = CharacterSet(charactersIn: numbers).inverted
        } else {
            return false
        }

        return (string.trimmingCharacters(in: characterSet).characters.count == string.characters.count)
    }

    fileprivate func numericCheckTextField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        guard validationChecks.contains(.numeric) else {
            return true
        }

        let numbers = "0123456789"

        // Enable delete
        if range.length > 0 && string.characters.count == 0 {
            return true
        }

        return string.trimmingCharacters(in: CharacterSet(charactersIn: numbers).inverted).characters.count == string.characters.count
    }

    fileprivate func maximumLengthLimitTextField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        guard limitMaximumLength != 0 else {
            return true
        }

        let newLength = text!.characters.count + string.characters.count - range.length
        return newLength <= limitMaximumLength
    }

    fileprivate func keyboardDonePressed() {
        if let delegate = chainDelegate as? ValidatingTextFieldDelegate {
            delegate.keyboardDonePressed()
        }
    }

    // MARK: - UITextField Overrides

    override var isEnabled: Bool {
        didSet {
            if !isEnabled {
                textColor = disabledTextColor
            }
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textInsetLeft = self.textInsetLeft ?? appearance.textInsetLeft
        let textInsetRight = self.textInsetRight ?? appearance.textInsetRight
        return CGRect(x: bounds.origin.x + textInsetLeft + leftViewWidth,
                      y: bounds.origin.y,
                      width: bounds.size.width - (textInsetRight + rightViewWidth + leftViewWidth),
                      height: bounds.size.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let textInsetLeft = self.textInsetLeft ?? appearance.textInsetLeft
        let textInsetRightEditing = self.textInsetRightEditing ?? appearance.textInsetRightEditing
        return CGRect(x: bounds.origin.x + textInsetLeft + leftViewWidth,
                      y: bounds.origin.y,
                      width: bounds.size.width - (textInsetRightEditing + rightViewWidth + leftViewWidth),
                      height: bounds.size.height)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let textInsetLeft = self.textInsetLeft ?? appearance.textInsetLeft
        let textInsetRight = self.textInsetRightPlaceholder ?? self.textInsetRightPlaceholder ?? appearance.textInsetRightPlaceholder
        return CGRect(x: bounds.origin.x + textInsetLeft + leftViewWidth,
                      y: bounds.origin.y,
                      width: bounds.size.width - (textInsetRight + rightViewWidth + leftViewWidth),
                      height: bounds.size.height)
    }

    override func deleteBackward() {
        if self.validationChecks.contains(.phoneNumber) {
            if self.text!.hasSuffix(" ") {
                if self.text!.characters.count > 1 {
                    self.text = self.text!.substring(to: self.text!.characters.index(self.text!.endIndex, offsetBy: -1))
                }
                return
            }
        }
        super.deleteBackward()
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let retFunc = self.chainDelegate?.textFieldShouldReturn {
            return retFunc(textField)
        } else { // Default nextfield
            if let field = textField as? ValidatingTextField {
                if field.nextField != nil {
                    DispatchQueue.main.async(execute: {
                        field.nextField?.becomeFirstResponder()
                    })
                } else {
                    keyboardDonePressed()
                }
            }
        }

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let retFunc = self.chainDelegate?.textFieldShouldClear {
            return retFunc(textField)
        }

        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if ignoreInput {
            return false
        }

        // Prevent crashing undo bug
        if range.length + range.location > textField.text!.characters.count {
            return false
        }

        let returnValue = currencyCheckTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
            && numericCheckTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)
            && maximumLengthLimitTextField(textField, shouldChangeCharactersInRange: range, replacementString: string)

        return returnValue
    }

    // MARK: - Protocol TextFieldValidator

    /**
     Implementation of TextFieldValidator protocol
     */
    func validateTextField(_ textField: ValidatingTextField) -> ValidationStatus {

        if validationChecks.contains(.notEmpty) && text!.characters.count < 1 {
            return .empty
        }

        for check in validationChecks {

            switch check {
            case .notEmpty:
                if text!.characters.count < 1 {
                    return .empty
                }
                break
            case .minimumLength(let minimumLength):
                if text!.characters.count < minimumLength {
                    return .short(length: text!.characters.count, minimumLength: minimumLength)
                }
                break
            case .maximumLength(let maximumLength):
                if text!.characters.count > maximumLength {
                    return .long(length: text!.characters.count, maximumLength: maximumLength)
                }
                break
            case .email:
                if !isValidEmail {
                    return .malformed
                }
                break
            case .phoneNumber:
                #if LIBPHONENUMBER
                if !isValidPhoneNumber {
                    return .malformed
                }
                #endif
            case .luhn:
                if !isValidLuhn {
                    return .malformed
                }
                break
            case .minimumValue(let minimumValue):
                let value = Int(self.text!)
                if value == nil || value! < minimumValue {
                    return .low(value: value ?? 0, minimumValue: minimumValue)
                }
                break
            case .maximumValue(let maximumValue):
                let value = Int(self.text!)
                if value == nil || value! > maximumValue {
                    return .high(value: value ?? 0, maximumValue: maximumValue)
                }
                break
            case .matchField(let field):
                if field.text != text {
                    return .mismatch
                }
                break
            case .numeric:
                break
            case .currency:
                break
            }
        }

        return .valid
    }
}

// MARK: - Enum equatability operators

func == (lhs: ValidatingTextField.ValidationOptions, rhs: ValidatingTextField.ValidationOptions) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func == (lhs: ValidatingTextField.ValidationChecks, rhs: ValidatingTextField.ValidationChecks) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

func == (lhs: ValidatingTextField.ValidationStatus, rhs: ValidatingTextField.ValidationStatus) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
