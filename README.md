# JSONModelWithMirror
使用Mirror创建基类

只需要继承基类即可实现对象转JSON的方法，实现对象可打印，
实现NSCoding协议，支持序列化

注意类中基础类型不要用可选类型，否则会crash

注：根据喵神的观点，不建议使用Mirror来做很多事情，读者可自行选择
