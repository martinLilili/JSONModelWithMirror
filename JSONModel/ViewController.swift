//
//  ViewController.swift
//  JSONModel
//
//  Created by UBT on 2016/12/5.
//  Copyright © 2016年 martin. All rights reserved.
//

import UIKit

//电话结构体
struct Telephone {
    var title:String  //电话标题
    var number:String  //电话号码
}

extension Telephone: JSON { }
//用户类
class User : JSONModel {
    var name:String = ""  //姓名
    var nickname:String?  //昵称
    var age:Int = 0   //年龄
    var emails:[String]?  //邮件地址
//    var tels:[Telephone]? //电话
}

class Student: User {
    var accountID : Int = 0
}

class SchoolStudent: Student {
    var schoolName : String?
    var schoolmates : [Student]?
    var principal : User?
}



class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        testUser()
//        
//        testStudent()
        
        var any: Any
//        any = nil
        
        var op : String?
        op = nil
        
        any = op
        
        print(any)
        print(any == nil)
        
        
        testSchoolStudent()
    }
    
    func testUser() {
        //创建一个User实例对象
        let user = User()
        user.name = "hangge"
        user.age = 100
        user.emails = ["hangge@hangge.com","system@hangge.com"]
        //添加动画
//        let tel1 = Telephone(title: "手机", number: "123456")
//        let tel2 = Telephone(title: "公司座机", number: "001-0358")
//        user.tels = [tel1, tel2]
        
        //输出json字符串
        print("user = \(user)")
        
        
    }

    func testStudent() {
        //创建一个student实例对象
        let student = Student()
        student.accountID = 2009
        student.name = "hangge"
        student.age = 100
        student.emails = ["hangge@hangge.com","system@hangge.com"]
        //添加动画
//        let tel1 = Telephone(title: "手机", number: "123456")
//        let tel2 = Telephone(title: "公司座机", number: "001-0358")
//        student.tels = [tel1, tel2]
        
        //输出json字符串
        print("student = \(student)")
        
        
    }
    
    func testSchoolStudent() {
        //创建一个schoolstudent实例对象
        let schoolstudent = SchoolStudent()
        schoolstudent.schoolName = "清华大学"
        
        let principal = User()
        principal.name = "校长"
        principal.age = 60
        principal.emails = ["zhang@hangge.com","xiao@hangge.com"]
        schoolstudent.principal = principal
        
        let student1 = Student()
        student1.accountID = 2009
        student1.name = "martin"
        student1.age = 25
        student1.emails = ["martin1@hangge.com","martin2@hangge.com"]
//        //添加手机
//        let tel1 = Telephone(title: "手机", number: "123456")
//        let tel2 = Telephone(title: "公司座机", number: "001-0358")
//        student1.tels = [tel1, tel2]
        
        let student2 = Student()
        student2.accountID = 2008
        student2.name = "james"
        student2.age = 26
        student2.emails = ["james1@hangge.com","james2@hangge.com"]
//        //添加手机
//        let tel3 = Telephone(title: "手机", number: "123456")
//        let tel4 = Telephone(title: "公司座机", number: "001-0358")
//        student2.tels = [tel3, tel4]
        
        schoolstudent.schoolmates = [student1, student2]
        
        //输出json字符串
        print("school student = \(schoolstudent)")
        
        let a = NSKeyedArchiver.archivedData(withRootObject: schoolstudent)
        let b = NSKeyedUnarchiver.unarchiveObject(with: a)
        print("unarchiveObject = \(b)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

