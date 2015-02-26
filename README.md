## 环境要求
* 支持Servet 3.0规范及以上的应用服务器。例如Tomcat 7及以后版本; Jetty 8及以后版本
* JDK 7.0及以上 

## 配置项目的Maven依赖
```xml   
        <dependency>
            <groupId>com.tc.mw</groupId>
            <artifactId>trinity</artifactId>
            <version>${trinity_version}</version>
        </dependency>
```

当前本系统仅支持logback作为可配值日志组件。所以，如果想通过本系统配置logback的话，还需要进行对应依赖设置。

先去掉对log4j等日志组件的显式依赖，然后配置slf4j桥接适配组件。
（阅读​这里[这里](http://www.slf4j.org/legacy.html)，了解slf4j的桥接系统） 
```xml
      <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>jcl-over-slf4j</artifactId>
        <version>${slf4j.version}</version>
      </dependency>
      <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>log4j-over-slf4j</artifactId>
        <version>${slf4j.version}</version>
      </dependency>
```
配置全局对于jcl和log4j的exclusion。这个trick的介绍见[这里](http://stackoverflow.com/questions/4716310/is-there-a-way-to-exclude-a-maven-dependency-globally)
```xml
      <dependency>
        <groupId>commons-logging</groupId>
        <artifactId>commons-logging</artifactId>
        <version>[0.0.1,)</version>
        <scope>provided</scope>
      </dependency>
      <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>[0.0.1,)</version>
        <scope>provided</scope>
      </dependency>
```
 最后配置logback自己的依赖： 
```xml
      <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.1.2</version>
      </dependency>
      <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-core</artifactId>
        <version>1.1.2</version>
      </dependency>
```
## 配置文件
需要在classpath根目录下面放置一个config.properties文件。对于按​[maven标准目录结构](http://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html)组织的项目，classpath根目录即src/main/resources。 

config.properties 需要/可以 包含两部分信息： 

* trinity初始化自身所需要的配置信息
* 应用本身的配置信息 

配置文件示例： 
```properties
##### 这部分给配置组件使用，必须添加 #####
trinity.config.project_name=aris-web
trinity.config.environment=dev
#trinity.config.project_version=2.0.9
trinity.remote.zookeeper.servers=10.1.10.215:2181,10.1.10.216:2181,10.1.10.217:2181
trinity.remote.zookeeper.session_timeout=5000

##### 这部分是应用自身的配置，可以用来在开发环境覆盖配置中心设置 #####
logback.appender.logfile.file_dynamic=/data/outputs/logs/app.log
spring.respath=http://10.1.18.41:9000/public_static/
```

目前trinity系统支持Spring和logback两个配置组件。
* trinity.config.project_name 
* trinity.config.environment 
* trinity.config.project_version 

这三项定义项目信息。**trinity.config.project_name**配置的是当前应用的名称。这个和svn上项目的代码组织没有关系，每个Java虚拟机运行的应用都应该有不同的名称。换言之，his-web, his-dubbo-provider, his-task应该有不同的应用名称。**trinity.config.environment**配置当前运行环境值，目前的环境包括：开发环境dev，开发测试环境：alpha，测试环境：qa，模测环境：beta和生产环境：product。**trinity.config.project_version**是个可选项，配置版本信息可以用来更灵活地支持发布回滚。开发、测试环境应该忽略此配置项。 

* trinity.remote.zookeeper.servers 
* trinity.remote.zookeeper.session_timeout 

这两项在当选择ZookeeperClient作为RemoteConfigClient的扩展点实现时，用以初始化连接。

* logback.appender.logfile.file_dynamic 
* spring.respath 

这两项是应用系统的配置项，跟trinity配置组件没有关系。 

对于大多数共用配置项，例如数据库连接信息，字符集编码等，不需要进行本地设置。和开发个人相关的配置项，例如日志打印位置，可以通过本地设置（在config.properties里面设定相应配置键值对）的方式，覆盖配置服务器上的公用设置。**注意： 在生产环境(product)下，本地配置是无效的！**

当一个配置项名称以**logback**或**spring**作为前缀，以**_dynamic**作为后缀时，可以在配置服务器上的对应配置项发生变化时，产生对应的更新动作。 

## Spring组件的配置说明

 Spring作为一个应用服务器容器，需要额外的配置信息。必须在Spring容器环境中配置以下bean： 

```xml
    <bean id="trinityconfig"
        class="com.tc.trinity.core.config.WebPropertyPlaceholderConfigurer">
        <property name="locations">
            <list>
                <value>classpath:/config.properties</value>
            </list>
        </property>
    </bean>
```

**注意：**当使用在SpringMVC中，可能存在多个Spring ApplicationContext容器，如DispatchServlet参数中appName-servlet.xml开启的容器环境，以及ContextLoaderListener开启的容器环境。在这种配置下，需要在每个xml中，分别配置以上的bean信
息。

 这个Bean的作用是替代Spring旧有系统中如下两个标签： 

```xml
    <bean id="jdbcConfiguration" class="org.springframework.beans.factory.config.PropertiesFactoryBean">
      <property name="location" value="classpath:config.properties"/>
    </bean>
或
    <util:properties id="config" location="classpath:config.properties" />

    <bean id="resourceConfigure" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
      <property name="locations">
        <list>
          classpath:/config.properties
        </list>
      </property>
    </bean>
或
    <context:property-placeholder />     
```

 这个Spring bean目前可以同时支持Spring三种配置方式： 
* JSP上的EvalTag 
```
    <spring:eval var="configJsp" expression="@myconf['spring.config.for.jsp_dynamic']" />
    Property from EvalTag: ${configJsp}
```
* 通过@Value的EL方式注入 
```Java
    public class SampleAction {
      
        @Value("#{myconf['spring.config.for.action_dynamic']}")
        private String configProperty;
        ....
    }
```
* 容器xml中，bean里面的占位符 
```xml
    <bean id="sampleBean" class="info.kozz.spring.SimpleBean" >
        <property name="foo" value="${spring.config.for.xml_dynamic}" />
    </bean>
```

**注意：** 只有当配置项名称以spring开头，以_dynamic结尾时，才会在配置值发生变化时动态更新。 

## Logback组件的配置说明

 Logback并不需要额外的配置

当初始化日志组件所需要的配置项只存在于服务器时，为了保证日志系统初始化的顺利执行，本系统会执行一个预配置动作，此环节会配置所有的Appender保存文件，为当前工作目录下的app.log，日志级别统一设置为DEBUG，打印模式为：“%d %p [%c] - %m%n”。

## 独立Java进程（非Web容器环境）的启动方式
### 虚拟机参数
 需要在启动的虚拟机参数里，指定-javagent如下： 
```
-javaagent:PATH/TO/LIB/trinity.jar
``` 
### Spring组件配置
 不同于Web容器下的配置，需要在容器上下文配置的xml中注入以下bean定义： 
```xml
    <bean id="trinityconfig"
        class="com.tc.trinity.core.config.StandalonePropertyPlaceholderConfigurer">
        <property name="locations">
            <list>
                <value>classpath:/config.properties</value>
            </list>
        </property>
    </bean>
```

## 常见问题
### zookeeper连接超时问题
 目前的配置保存在Zookeeper服务器。但Apache的zk客户端在连接过程中，会进行反向域名解析。可能会引起超时，连接不上等问题 
* 解决方法1：在本地操作系统进行域名绑定 
* 解决方法2：使用中宏打包的zookeeper客户端版本 
```xml
      <dependency>
        <groupId>org.apache.zookeeper</groupId>
        <artifactId>zookeeper</artifactId>
        <version>3.3.3-tc</version>
      </dependency>
```

