HardChoice
==========

有时候作抉择真的很痛苦  
生活中会遇到很多抉择，比如今天中午吃啥？今天谁去买饭？面对着种种疑问，我们可以先把备选答案以及期望的权值写下来，然后就交给摇摇乐来告诉最终的结果吧！摇一摇手机就能知道答案！  

**支持不同设备之间用iCloud同步应用数据**

![](http://wal8.com/64224622)
![](http://wal8.com/64224623)

HardChoice代码教程地址：  

- CoreData:http://yulingtianxia.com/blog/2014/07/03/chu-shi-core-data-3/  
- TableView self-sizing Cell:http://yulingtianxia.com/blog/2014/08/17/New-in-Table-and-Collection-Views/  
- UIAlertController in iOS8:http://yulingtianxia.com/blog/2014/09/29/uialertcontroller-in-ios8/  

如果遇到了类型转换编译报错，可以手动加代码强制转换或者用64位模拟器（如iPhone5s）运行

建议在Xcode6beta5下运行，beta4会出现问题，这是由于beta4的IB取消了Resizeable Controller和增加了module设置（在storyboard源文件中有体现，多了customModule、customModuleProvider）导致的，可以先用Resizeable iPhone运行下，然后再用iPhone5s运行，并在Controller的module处设置成HardChoice，这样就能修复IB文件的错误

语法更新至beta7（2014.9.5），出现连接错误时可以clean build folder（点product->clean之前按住option）试试。
