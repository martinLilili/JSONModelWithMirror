//
//  JSONModel.swift
//  JSONModel
//
//  Created by UBT on 2016/12/5.
//  Copyright © 2016年 martin. All rights reserved.
//

import UIKit

//MARK: - MirrorResult，使用mirror遍历所有的属性和值，通过action传出做相应的处理
protocol MirrorResult {
    
    /// 使用mirror遍历所有的属性和值
    ///
    /// - Parameters:
    ///   - mir: mirror
    ///   - action: 要对属性和值做什么处理
    func getResultFromMirror(mir : Mirror, action: (_ label: String?, _ value : Any) -> Void)
}

extension MirrorResult {
    
    func getResultFromMirror(mir : Mirror, action: (_ label: String?, _ value : Any) -> Void) {
        if let superMirror = mir.superclassMirror { //便利父类所有属性
            getResultFromMirror(mir: superMirror, action: action)
        }
        if (mir.children.count) > 0  {
            for case let (label?, value) in (mir.children) {
                action(label, value)
            }
        }
    }
}


//MARK: - JSON协议
//自定义一个JSON协议
protocol JSON: MirrorResult {
    
    /// 如果是对象实现了JSON协议，这个方法返回对象属性及其value的dic，注意如果某个value不是基础数据类型，会一直向下解析直到基础数据类型为止，另外可选类型和数组需要单独处理
    /// 如果是基础数据类型实现了JSON协议，只返回他们自己
    /// - Returns: 对于对象返回dic，对于基础数据类型，返回他们自己
    func toJSONModel() -> AnyObject?
    
    /// 生成JSON字符串
    ///
    /// - Returns: 字符串
    func toJSONString() -> String
}

//扩展协议方法
extension JSON {
    
    
    /// 使用mirror遍历所有的属性，并保存与dic中，如果属性的value不是基础类型，则一直向下解析直到基础类型，另外可选类型和数组需要单独处理
    ///
    /// - Parameter mir: mirror
    /// - Returns: dic
//    func getResultFromMirror(mir : Mirror) -> [String:AnyObject] {
//        var result: [String:AnyObject] = [:]
//        if let superMirror = mir.superclassMirror { //便利父类所有属性
//            result = getResultFromMirror(mir: superMirror)
//        }
//        if (mir.children.count) > 0  {
//            for case let (label?, value) in (mir.children) {
//                //属性：label   值：value
//                if let jsonValue = value as? JSON { //如果value实现了JSON，继续向下解析
//                    result[label] = jsonValue.toJSONModel()
//                }
//            }
//        }
//        return result
//    }
    
    /// 将数据转成可用的JSON模型
    func toJSONModel() -> AnyObject? {
        let mirror = Mirror(reflecting: self)
        if mirror.children.count > 0  {
//            let result = getResultFromMirror(mir: mirror)
            var result: [String:AnyObject] = [:]
            getResultFromMirror(mir: mirror, action: { (label, value) in
                //属性：label   值：value
                if let jsonValue = value as? JSON , label != nil { //如果value实现了JSON，继续向下解析
                    result[label!] = jsonValue.toJSONModel()
                }
            })
            return result as AnyObject?  //有属性的对象，返回result是一个dic
        }
        return self as AnyObject?  //基础数据类型，返回自己
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


//得到所有的属性即value
protocol PropertieValues: MirrorResult {
    /// 得到所有的属性及其对应的value组成dic，注意value不一定全是基础数据类型，可能是其他自定义对象。同时，dic中存储的都是有值的属性，那些没有赋值的属性不会出现在dic中
    ///
    /// - Returns: dic
    func codablePropertieValues() -> [String:AnyObject]
    
    //遍历所有的属性列表，将所有的属性存储到数组中
    func allProperties() -> [String]
}

//MARK: - PropertieValues协议
extension PropertieValues {
//    func getPropertieValuesWithMirror(mir : Mirror) -> [String:AnyObject] {
//        var result: [String:AnyObject] = [:]
//        if let superMirror = mir.superclassMirror {
//            result = getPropertieValuesWithMirror(mir: superMirror)
//        }
//        for case let (label?, value) in (mir.children) {
//            result[label] = unwrap(any: value) as AnyObject?
//        }
//        return result
//    }
//    
    
    /// 得到所有的属性及其对应的value组成dic，注意value不一定全是基础数据类型，可能是其他自定义对象。同时，dic中存储的都是有值的属性，那些没有赋值的属性不会出现在dic中
    ///
    /// - Returns: dic
    func codablePropertieValues() -> [String:AnyObject] {
        var codableProperties = [String:AnyObject]()
        let mirror = Mirror(reflecting: self)
//        codableProperties = getPropertieValuesWithMirror(mir: mirror)
        getResultFromMirror(mir: mirror, action: { (label, value) in
            if label != nil {
                codableProperties[label!] = unwrap(any: value) as AnyObject?
            }
        })
        return codableProperties
    }
    
//    //遍历所有的属性列表，将所有的属性存储到数组中
//    func getPropertiesWithMirror(mir : Mirror) -> [String] {
//        var result: [String] = []
//        if let superMirror = mir.superclassMirror {
//            result = getPropertiesWithMirror(mir: superMirror)
//        }
//        for case let (label?, _) in (mir.children) {
//            result.append(label)
//        }
//        return result
//    }
    
    //遍历所有的属性列表，将所有的属性存储到数组中
    func allProperties() -> [String] {
        var allProperties = [String]()
        let mirror = Mirror(reflecting: self)
//        codableProperties = getPropertiesWithMirror(mir: mirror)
        getResultFromMirror(mir: mirror, action: { (label, value) in
            if label != nil {
                allProperties.append(label!)
            }
        })
        return allProperties
    }
    
    
    /// 将一个any类型的对象转化为可选类型
    ///
    /// - Parameter any: any 类型对象
    /// - Returns: 可选值
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
}

//MARK: - JSONModel
class JSONModel: NSObject, JSON, NSCoding, PropertieValues {
    
    override init() {
        
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
        let arr = allProperties()
        for key in arr {
            let object = aDecoder.decodeObject(forKey: key)
            self.setValue(object, forKey: key)
        }
    }

}
