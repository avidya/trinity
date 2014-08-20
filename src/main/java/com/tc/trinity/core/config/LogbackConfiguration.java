
package com.tc.trinity.core.config;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javassist.ClassPool;
import javassist.CtClass;
import javassist.CtMethod;
import javassist.Loader;
import javassist.LoaderClassPath;

import org.slf4j.LoggerFactory;
import org.xml.sax.InputSource;

import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.joran.JoranConfigurator;
import ch.qos.logback.core.joran.spi.JoranException;
import ch.qos.logback.core.joran.util.ConfigurationWatchListUtil;

import com.tc.trinity.core.AbstractConfigurable;
import com.tc.trinity.core.ConfigContext;
import com.tc.trinity.core.config.LogbackConfigPreloader.BodyEvent;
import com.tc.trinity.core.config.LogbackConfigPreloader.SaxEvent;
import com.tc.trinity.core.config.LogbackConfigPreloader.StartEvent;

/**
 * Logback配置器
 * 
 * @author gaofeng
 * @date Jun 13, 2014 9:39:32 AM
 * @id $Id$
 */
public class LogbackConfiguration extends AbstractConfigurable {
    
    private LoggerContext loggerContext;
    
    private volatile boolean initialStatus = false;
    
    private volatile boolean validity = false;
    
    private final String name = "logback";
    
    @Override
    public String getName() {
    
        return name;
    }
    
    @Override
    public boolean doInit(ConfigContext context, Properties properties) {
    
        if (_checkValidity()) {
            loggerContext = (LoggerContext) LoggerFactory.getILoggerFactory();
            System.getProperties().putAll(properties);
            initialStatus = performXMLConfiguration();
            return true;
        } else {
            return false;
        }
    }
    
    private boolean _checkValidity() {
    
        return initialStatus ? validity : checkValidity();
    }
    
    @Override
    public boolean checkValidity() {
    
        try {
            Class.forName("ch.qos.logback.classic.LoggerContext");
        } catch (ClassNotFoundException e) {
            // maybe no logger was configed correctly at present, so error message being sent to stderr will be helpful
            // for debug sake.
            System.err.println("No logback environment be found. Please make sure configing logback correctly.");
            this.validity = false;
        }
        this.validity = true;
        return this.validity;
    }
    
    @Override
    public boolean doOnChange(String key, String originalValue, String value) {
    
        if (_checkValidity()) {
            performXMLConfiguration();
            return true;
        } else {
            return false;
        }
    }
    
    private boolean performXMLConfiguration() {
    
        JoranConfigurator jc = new JoranConfigurator();
        jc.setContext(loggerContext);
        
        URL mainURL = ConfigurationWatchListUtil.getMainWatchURL(loggerContext);
        loggerContext.reset();
        
        try {
            jc.doConfigure(mainURL);
            System.out.println("Reconfigure logback context successfully.");
        } catch (JoranException e) {
            System.err.println(">>>>>>>>>>>>>>>>>>>>> Error occurs when reconfiguring Logback Context");
            return false;
        }
        return true;
    }
    
    @Override
    public String getExtensionName() {
    
        return this.getClass().getName();
    }
    
    @Override
    public Properties fallbackSetting() {
    
        if (!_checkValidity()) {
            return null;
        }
        try {
            
            ClassPool pool = ClassPool.getDefault();
            pool.importPackage("java.io");
            pool.appendClassPath(new LoaderClassPath(this.getClass().getClassLoader()));
            Loader cl = new Loader(pool); // ensure we are in a new seperate Classloader.
            
            CtClass clazz = pool.get("ch.qos.logback.core.subst.NodeToStringTransformer");
            CtMethod method = clazz.getDeclaredMethod("lookupKey");
            method.insertBefore("{"
                    + "     PrintWriter fw = new PrintWriter(new FileWriter(new File(\".tmpVar\"), true));"
                    + "     fw.println($1);"
                    + "     fw.flush();"
                    + "     fw.close();"
                    + "     return $1;"
                    + "}");
            
            Class<?> c1 = cl.loadClass("ch.qos.logback.core.subst.NodeToStringTransformer");
            Class<?> c2 = cl.loadClass("ch.qos.logback.core.spi.PropertyContainer");
            Method m = c1.getDeclaredMethod("substituteVariable", String.class, c2, c2);
            
            LogbackConfigPreloader saxGen = new LogbackConfigPreloader();
            InputStream is = this.getClass().getClassLoader().getResourceAsStream("logback.xml");
            List<SaxEvent> events = saxGen.recordEvents(new InputSource(is));
            SaxEvent preEvent = null;
            Properties props = new Properties();
            for (SaxEvent event : events) {
                if (event instanceof BodyEvent) {
                    m.invoke(null, ((BodyEvent) event).getText(), null, null);
                    List<String> propLine = loadProperties();
                    // 需要确认环境变量中不存在此配置项的设定。否则的话，就不需要额外预设了。
                    if (preEvent != null && propLine.size() > 0 && System.getProperties().get(propLine.get(propLine.size() - 1)) == null) {
                        String key = propLine.get(propLine.size() - 1);
                        switch (preEvent.getLocalName().toLowerCase()) {
                        case "file":
                            props.put(key, "app.log");
                            break;
                        case "filenamepattern":
                            props.put(key, "app.%d{yyyyMMdd}.log");
                            break;
                        case "pattern":
                            props.put(key, "%d %p [%c] - %m%n");
                            break;
                        }
                    }
                } else if (event instanceof StartEvent) {
                    if (event.getLocalName().equalsIgnoreCase("logger") || event.getLocalName().equalsIgnoreCase("root")) {
                        m.invoke(null, ((StartEvent) event).getAttributes().getValue("level"), null, null);
                        List<String> propLine = loadProperties();
                        String k = ((StartEvent) event).getAttributes().getValue("level");
                        if (k.startsWith("${") && propLine.size() > 0 && System.getProperties().get(propLine.get(propLine.size() - 1)) == null) {
                            props.put(propLine.get(propLine.size() - 1), "DEBUG");
                        }
                    }
                }
                cleanTempFile();
                preEvent = event;
            }
            System.getProperties().putAll(props);
            return props;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            cleanTempFile();
        }
        
    }
    
    private List<String> loadProperties() {
    
        ArrayList<String> propertyLine = new ArrayList<String>();
        File propFile = new File(".tmpVar");
        if (!propFile.exists()) {
            return propertyLine;
        }
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(propFile));
            for (String line = reader.readLine(); line != null; line = reader.readLine()) {
                propertyLine.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (propFile.exists()) {
                propFile.delete();
            }
        }
        return propertyLine;
    }
    
    private void cleanTempFile() {
    
        File f = new File(".tmpVar");
        if (f.exists()) {
            f.delete();
        }
    }
}
