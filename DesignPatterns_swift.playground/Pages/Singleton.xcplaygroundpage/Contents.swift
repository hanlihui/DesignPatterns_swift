/*:
 ## 概述：
 单例模式能确保某个类型的对象在应用中只存在一个实例。
 单例能保证一个对象存在,我们可以对某些操作进行统一管理,比如,app开发中用户信息的保存和读取,如后台开发中服务器配置信息的管理操作.这样可以有效的避免不必要的对象的创建和销毁,提高开发效率.
 
 ## Code Example
 */

import UIKit
import Foundation

// MARK: - Singleton
let app = UIApplication.shared

/*
  1. 添加final关键字，防止子类创建。
  2. 在init方法上加private，防止在文件之外的地方创建实例。
 */

final public class MySingleton {
    static let shared = MySingleton()
    private var data = [String]()
    
    private init() {}
    
    func backup(item:String)  {
        data.append(item)
        print("count:\(data.count)")
    }
    
    func getData() -> [String] {
        return data
    }
}

let mySingleton = MySingleton.shared
//let mySingleton2 = MySingleton() 报错

/*:
 ## 处理并发
    如果在多线程应用中使用单例，就需要考虑一个问题，即当有不同的组件同时操作单例的对象时，会产生什么后果？
    并发的问题非常常见，swift的数组并不是线程安全的。就是说当多个线程可以同时调用数组的append方法，对同一个数组进行操作，这会破坏数据的结果。
 */

let queue = DispatchQueue(label: "singleton", qos: .utility, attributes: .concurrent)
let group = DispatchGroup()

//for count in 0 ..< 100 {
//    queue.async(group: group){
//        mySingleton.backup(item: "\(count)")
//    }
//}

//group.wait()

/*:
 使用GCD模拟并发，只有两个或更多线程同时执行存在冲突的时候才会发生，并不会100%出错，报错截图如下：
 ![并发错误](singleton1.png)
 为了解决这个问题，我们需要保证在同一时刻只允许一个Block处理数组的append方法。
 */

final public class MySingleton2 {
    static let shared = MySingleton2()
    private var data = [String]()
    private let arrayQ = DispatchQueue(label: "arrayQ")
    
    private init() {}
    
    func backup(item:String)  {
        arrayQ.sync {
            data.append(item)
            print("count:\(data.count)")
        }
    }
    
    func getData() -> [String] {
        return data
    }
}

let mySingleton2 = MySingleton2.shared
for count in 0 ..< 100 {
    queue.async(group: group){
        mySingleton.backup(item: "\(count)")
    }
}

group.wait()
