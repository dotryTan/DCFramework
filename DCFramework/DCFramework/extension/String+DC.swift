//
//  AppDelegate.swift
//  DCFramework
//
//  Created by fighter on 2019/4/29.
//  Copyright © 2019 Dotry. All rights reserved.
//

import Foundation

extension String {
    subscript(offset: Int) -> Character {
        get {
            return self[index(startIndex, offsetBy: offset)]
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: offset)..<index(startIndex, offsetBy: offset + 1), with: [newValue])
        }
    }
    
    subscript(range: CountableRange<Int>) -> String {
        get {
            return String(self[index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: range.lowerBound)..<index(startIndex, offsetBy: range.upperBound), with: newValue)
        }
    }
    
    subscript(location: Int, length: Int) -> String {
        get {
            return String(self[index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length)])
        }
        set {
            replaceSubrange(index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + length), with: newValue)
        }
    }
    
    var pinyin: String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    var firstLetter: String {
        return String(pinyin[0])
    }
    
    var isPhoneNumber: Bool {
        return ~/"^1\\d{10}$" ~= self
    }
    
    var isLettersOrNumbers: Bool {
        return ~/"^[0-9A-Za-z]+$" ~= self
    }
    
    var isLetterAndNumbers: Bool {
        return ~/"^(?=.*\\d)(?=.*[a-zA-Z])[a-zA-Z0-9]{2,}$" ~= self
    }
    
    var isEmail: Bool {
        return ~/"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$" ~= self
    }
    
    var isURL: Bool {
        return ~/"^[a-zA-z]+://[^\\s]*$" ~= self
    }
    
    var isSpecialCharacters: Bool {
        let specialCharacters = "[~`!@#$%^&*()_+-=[]|{};':\",./<>?]{,} /"
        for ch in self {
            if !specialCharacters.contains(ch) {
                return false
            }
        }
        return true
    }
    
    var isChineseStrict: Bool {
        return ~/"^[\\u4e00-\\u9fbf\\278b-\\2792]+$" ~= self
    }
        
    var isChinese: Bool {
        //0x0000-0x007f为ASCII码
        //0x2000-0x206f常用标点
        //0x20A0-0x20CF：货币符号
        //0x3000-0x303f中文符号和标点
        //0x4e00-0x9fbf中文汉字
        //0xff00-0xffef半角和全角
        //0x278b-0x2792苹果手机中文9键输入时对应的2-9，1则为标点。
        return ~/"^[\\u0000-\\u007f\\u2000-\\u206f\\u20a0-\\u20cf\\u278b-\\u2792\\u3000-\\u303f\\u4e00-\\u9fbf\\uff00-\\uffef]+$" ~= self
    }
    
    var isContainsEmoji: Bool {
        //2600-26FF：杂项符号 (Miscellaneous Symbols)
        //2700-27BF：印刷符号 (Dingbats)
        //27C0-27EF：杂项数学符号-A (Miscellaneous Mathematical Symbols-A)
        //2980-29FF：杂项数学符号-B (Miscellaneous Mathematical Symbols-B)
        //2A00-2AFF：追加数学运算符 (Supplemental Mathematical Operator)
        //2B00-2BFF：杂项符号和箭头 (Miscellaneous Symbols and Arrows)
        //e000-f8ff：自行使用区域 (Private Use Zone)
        //0001f000-0001ffff：表情符号
        return ~/"^([\u{2600}-\u{27ef}\u{2980}-\u{2bff}\u{e000}-\u{f8ff}\u{0001f000}-\u{0001ffff}]+)([\u{0000}-\u{0001ffff}]*)$" ~= self
    }
    
    var isIdCard: Bool {
        return ~/"^(\\d{14}|\\d{17})(\\d|[xX])$" ~= self
    }
    
    var isIdCardStrict: Bool {
        if count != 18 {
            return false
        }
        // 正则表达式判断基本 身份证号是否满足格式
        guard ~/"^(\\d{6})(\\d{4})(\\d{2})(\\d{2})(\\d{3})([0-9]|X|x)$" ~= self else { return false }
        //如果通过该验证，说明身份证格式正确，但准确性还需计算
        //** 开始进行校验 *//
        //将前17位加权因子保存在数组里
        let idCardWiArray = ["7", "9", "10", "5", "8", "4", "2", "1", "6", "3", "7", "9", "10", "5", "8", "4", "2"]
        //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        let idCardYArray = ["1", "0", "10", "9", "8", "7", "6", "5", "4", "3", "2"]
        //用来保存前17位各自乖以加权因子后的总和
        var idCardWiSum = 0
        for i in 0..<17 {
            let subStrIndex = Int(self[i, 1]) ?? 0
            let idCardWiIndex = Int(idCardWiArray[i]) ?? 0
            idCardWiSum += subStrIndex * idCardWiIndex
        }
        //计算出校验码所在数组的位置
        let idCardMod = idCardWiSum % 11
        //得到最后一位身份证号码
        let idCardLast = self[17, 1]
        //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
        if idCardMod == 2 {
            if idCardLast != "x" && idCardLast != "X" {
                return false
            }
        } else {
            //用计算出的验证码与最后一位身份证号码匹配。
            //如果一致，说明通过，否则是无效的身份证号码
            if idCardLast != idCardYArray[idCardMod] {
                return false
            }
        }
        return true
    }
}
