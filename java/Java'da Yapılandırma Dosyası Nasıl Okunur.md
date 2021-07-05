## https://www.opencodez.com/java/read-config-file-in-java.htm


### The Config File Class

```
import java.util.*;
import java.util.Properties;
 
public class Config
{
   Properties configFile;
   public Config()
   {
 configFile = new java.util.Properties();
 try {
   configFile.load(this.getClass().getClassLoader().
   getResourceAsStream("myapp/config.cfg"));
 }catch(Exception eta){
     eta.printStackTrace();
 }
   }
 
   public String getProperty(String key)
   {
 String value = this.configFile.getProperty(key);
 return value;
   }
}
```


### ‘GetProperty’yöntemi ile yapılandırmadan herhangi bir özellik/ayar alabilirsiniz
#### İşte benim yapılandırma örnek dosyam
```
#This is comment
mDbUser = myuser
mDbHost = myserver
mDbPwds = mypwd
mDbName = mydb
```


### Kullanımı
```
Java
cfg = new Config();
dbname   = cfg.getProperty("mDbUser");
1
2
cfg = new Config();
dbname   = cfg.getProperty("mDbUser");
```


