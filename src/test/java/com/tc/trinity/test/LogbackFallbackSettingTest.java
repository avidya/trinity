
package com.tc.trinity.test;

import junit.framework.TestCase;

import com.tc.trinity.core.ExtensionLoader;
import com.tc.trinity.core.spi.Configurable;

/**
 * TODO 类的功能描述。
 *
 * @author kozz.gaof
 * @date Jul 8, 2014 1:37:14 PM
 * @id $Id$
 */
public class LogbackFallbackSettingTest extends TestCase {
    public void testLogbackFallbackSetting() {
    
        assertTrue(System.getProperty("logback.appender.sqllog.file_dynamic") == null);
        assertTrue(System.getProperty("logback.appender.sqllog.rolling_file_pattern_dynamic") == null);
        assertTrue(System.getProperty("logback.appender.stdout.pattern_dynamic") == null);
        assertTrue(System.getProperty("logback.logger.com.ibatis.common.jdbc.SimpleDataSource.level_dynamic") == null);
        assertTrue(System.getProperty("logback.logger.root.level_dynamic") == null);
        
        try {
            for (Configurable configurable : ExtensionLoader.loadConfigurable()) {
                if ("logback".equals(configurable.getName())) {
                    configurable.fallbackSetting();
                }
                
            }
            assertTrue(System.getProperty("logback.appender.sqllog.file_dynamic") != null);
            assertTrue(System.getProperty("logback.appender.sqllog.rolling_file_pattern_dynamic") != null);
            assertTrue(System.getProperty("logback.appender.stdout.pattern_dynamic") != null);
            assertTrue(System.getProperty("logback.appender.logfile.file_dynamic").equalsIgnoreCase("app.log"));
            assertTrue(System.getProperty("logback.logger.com.ibatis.common.jdbc.SimpleDataSource.level_dynamic").equalsIgnoreCase("debug"));
            assertTrue(System.getProperty("logback.logger.root.level_dynamic").equalsIgnoreCase("debug"));
        } catch (Exception e) {
            e.printStackTrace();
            assertTrue(false);
        }
        
    }
    
}
