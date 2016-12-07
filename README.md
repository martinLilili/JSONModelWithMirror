# JSONModelWithMirror
使用Mirror创建基类，详细文档：[使用Mirror实现自定义对象转JSON及对象序列化](http://moonlspace.com/2016/12/%E4%BD%BF%E7%94%A8Mirror%E5%AE%9E%E7%8E%B0%E8%87%AA%E5%AE%9A%E4%B9%89%E5%AF%B9%E8%B1%A1%E8%BD%ACJSON%E5%8F%8A%E5%AF%B9%E8%B1%A1%E5%BA%8F%E5%88%97%E5%8C%96/)

只需要继承基类即可实现对象转JSON的方法，实现对象可打印，
实现NSCoding协议，支持序列化

注意要实现对象序列化，类中基础类型不要用可选类型，否则会crash，如Int？，自定义的结构等

注：根据喵神的观点，不建议使用Mirror来做很多事情，读者可自行选择


### 需求
实现一个基类Model，继承它的类不需要再写代码即可实现对象转json即对象序列化

### 实现效果如下
基类为JSONModel，为了测试其健壮性，下面的例子写了一些嵌套关系

创建一些类，继承JSONModel：

     //用户类
     class User : JSONModel {
         var name:String = ""  //姓名
         var nickname:String?  //昵称
         var age:Int = 0   //年龄
         var emails:[String]?  //邮件地址
     }

     class Student: User {
         var accountID : Int = 0 //学号
     }

     class SchoolStudent: Student {
         var schoolName : String? //学校名
         var schoolmates : [Student]? //校友
         var principal : User? //校长
     }
     
初始化：
    
        //创建一个schoolstudent实例对象
        let schoolstudent = SchoolStudent()
        schoolstudent.schoolName = "清华大学"
        schoolstudent.accountID = 1024
        schoolstudent.name = "martin"
        schoolstudent.age = 20
        
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
        
        let student2 = Student()
        student2.accountID = 2008
        student2.name = "james"
        student2.age = 26
        student2.emails = ["james1@hangge.com","james2@hangge.com"]
        
        schoolstudent.schoolmates = [student1, student2]
        
测试打印JSON：这里实现了对象可打印，打印出来的即为对象转化后的JSON字符串，也可以调用 toJSONString() 方法

     //输出json字符串
        print("school student = \(schoolstudent)")
输出结果：

     school student = {
     "name" : "martin",
     "age" : 20,
     "accountID" : 1024,
     "schoolName" : "清华大学",
     "schoolmates" : [
       {
         "name" : "martin",
         "age" : 25,
         "accountID" : 2009,
         "emails" : [
           "martin1@hangge.com",
           "martin2@hangge.com"
         ]
       },
       {
         "name" : "james",
         "age" : 26,
         "accountID" : 2008,
         "emails" : [
           "james1@hangge.com",
           "james2@hangge.com"
         ]
       }
     ],
     "principal" : {
       "name" : "校长",
       "age" : 60,
       "emails" : [
         "zhang@hangge.com",
         "xiao@hangge.com"
       ]
     }
   }
     
测试对象序列化：     
        
        let a = NSKeyedArchiver.archivedData(withRootObject: schoolstudent)
        let b = NSKeyedUnarchiver.unarchiveObject(with: a)
        print("unarchiveObject = \(b)")
输出结果：
     
     unarchiveObject = Optional({
     "name" : "martin",
     "age" : 20,
     "accountID" : 1024,
     "schoolName" : "清华大学",
     "schoolmates" : [
       {
         "name" : "martin",
         "age" : 25,
         "accountID" : 2009,
         "emails" : [
           "martin1@hangge.com",
           "martin2@hangge.com"
         ]
       },
       {
         "name" : "james",
         "age" : 26,
         "accountID" : 2008,
         "emails" : [
           "james1@hangge.com",
           "james2@hangge.com"
         ]
       }
     ],
     "principal" : {
       "name" : "校长",
       "age" : 60,
       "emails" : [
         "zhang@hangge.com",
         "xiao@hangge.com"
       ]
     }
     })
