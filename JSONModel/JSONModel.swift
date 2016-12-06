//
//  JSONModel.swift
//  JSONModel
//
//  Created by UBT on 2016/12/5.
//  Copyright © 2016年 martin. All rights reserved.
//

import UIKit

//MARK: - add two dictionary
extension Dictionary {
    mutating func add(other:Dictionary?) {
        if other != nil {
            for (key,value) in other! {
                self.updateValue(value, forKey:key)
            }
        }
    }
}




//MARK: - JSON协议
//自定义一个JSON协议
protocol JSON {
    func toJSONModel() -> AnyObject?
    func toJSONString() -> String
}

//扩展协议方法
extension JSON {
    
    func getResultFromMirror(mir : Mirror) -> [String:AnyObject] {
        var result: [String:AnyObject] = [:]
        if let superMirror = mir.superclassMirror {
            result = getResultFromMirror(mir: superMirror)
        }
        if (mir.children.count) > 0  {
            for case let (label?, value) in (mir.children) {
                //print("属性：\(label)     值：\(value)")
                if let jsonValue = value as? JSON {
                    result[label] = jsonValue.toJSONModel()
                }
            }
        }
        return result
    }
    
    //将数据转成可用的JSON模型
    func toJSONModel() -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        if mirror.children.count > 0  {
            let result = getResultFromMirror(mir: mirror)
            return result as AnyObject?
        }
        return self as AnyObject?
    }
    
    //将数据转成JSON字符串
    func toJSONString() -> String {
        
        let jsonModel = self.toJSONModel()
        //利用OC的json库转换成OC的Data，
        let data : Data! = try? JSONSerialization.data(withJSONObject: jsonModel ?? [:] , options: .prettyPrinted)
        //data转换成String打印输出
        if let str = String(data: data, encoding: String.Encoding.utf8) {
            return str
        } else {
            return ""
        }
    }
}

//扩展可选类型，使其遵循JSON协议
extension Optional: JSON {
    //可选类型重写toJSONModel()方法
    func toJSONModel() -> AnyObject? {
        if let x = self {
            if let value = x as? JSON {
                return value.toJSONModel()
            }
        }
        return nil
    }
}



//扩展Swift的基本数据类型，使其遵循JSON协议
extension String: JSON { }
extension Int: JSON { }
extension Bool: JSON { }
extension Dictionary: JSON { }
extension Array: JSON {
    func toJSONModel() -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        if mirror.children.count > 0  {
            var arr:[Any] = []
            for childer in Mirror(reflecting: self).children {
                if let jsonValue = childer.value as? JSON {
                    if let jsonModel = jsonValue.toJSONModel() {
                        arr.append(jsonModel)
                    }
                }
            }
            return arr as AnyObject?
        }
        return self as AnyObject?
    }
}

//MARK: - JSONModel
class JSONModel: NSObject, JSON, NSCoding {
    
    override init() {
        
    }
    
    func getPropertieValuesWithMirror(mir : Mirror) -> [String:AnyObject] {
        var result: [String:AnyObject] = [:]
        if let superMirror = mir.superclassMirror {
            result = getPropertieValuesWithMirror(mir: superMirror)
        }
        for case let (label?, value) in (mir.children) {
            result[label] = unwrap(any: value) as AnyObject?
        }
        return result
    }
    
    
    func codablePropertieValues() -> [String:AnyObject] {
        var codableProperties = [String:AnyObject]()
        let mirror = Mirror(reflecting: self)
        codableProperties = getPropertieValuesWithMirror(mir: mirror)
        return codableProperties
    }
    
    func getPropertiesWithMirror(mir : Mirror) -> [String] {
        var result: [String] = []
        if let superMirror = mir.superclassMirror {
            result = getPropertiesWithMirror(mir: superMirror)
        }
        for case let (label?, _) in (mir.children) {
            result.append(label)
        }
        return result
    }
    
    
    func codableProperties() -> [String] {
        var codableProperties = [String]()
        let mirror = Mirror(reflecting: self)
        codableProperties = getPropertiesWithMirror(mir: mirror)
        return codableProperties
    }
    
    func unwrap(any: Any) -> Any? {
        let mirror = Mirror(reflecting: any)
        if mirror.displayStyle != .optional {
            return any
        }
        if mirror.children.count == 0 { return nil } // Optional.None
        for case let (_?, value) in (mirror.children) {
            return value
        }
        return nil
    }
    
    override public var description: String {
        return toJSONString()
    }
    
    public func encode(with aCoder: NSCoder) {
        let dic = codablePropertieValues()
        for (key, value) in dic {
            switch value {
            case let property as AnyObject:
                aCoder.encode(property, forKey: key)
            case let property as Int:
                aCoder.encodeCInt(Int32(property), forKey: key)
            case let property as Bool:
                aCoder.encode(property, forKey: key)
            default:
                print("Nil value for \(key)")
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        let arr = codableProperties()
        for key in arr {
            let object = aDecoder.decodeObject(forKey: key)
            self.setValue(object, forKey: key)
        }
    }

}
