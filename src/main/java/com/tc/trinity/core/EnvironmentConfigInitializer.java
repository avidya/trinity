
package com.tc.trinity.core;

import java.io.File;
import java.io.FileInputStream;
import java.util.Properties;

import com.tc.trinity.configclient.zk.ZookeeperClient;
import com.tc.trinity.core.spi.RemoteConfigClient;

/**
 * 此处处理一些环境信息
 *
 * @author kozz.gaof
 * @date Aug 7, 2014 8:18:31 PM
 * @id $Id$
 */
public abstract class EnvironmentConfigInitializer extends ConfigInitializer {
    
    private static final String OS_NAME = System.getProperty("os.name").toLowerCase();
    
    private static final String ENVIRON_CONFIG = "/eetop/conf/global.properties";
    
    @Override
    public Properties mergeProperties() {
    
        Properties properties = super.mergeProperties();
        if (OS_NAME.contains("win")) {
            return properties;
        }
        File f = new File(ENVIRON_CONFIG);
        if (!f.exists()) {
            return properties;
        }
        Properties p = new Properties();
        try {
            p.load(new LineTrimInputStream(new FileInputStream(f)));
        } catch (Exception e) {
            System.err.println("Cannot load file: " + ENVIRON_CONFIG);
        }
        if (p.containsKey(ZookeeperClient.SERVERS_PROP_KEY)) {
            properties.put(ZookeeperClient.SERVERS_PROP_KEY, p.get(ZookeeperClient.SERVERS_PROP_KEY));
        }
        if (p.containsKey(RemoteConfigClient.ENVIRONMENT)) {
            properties.put(RemoteConfigClient.ENVIRONMENT, p.get(RemoteConfigClient.ENVIRONMENT));
        }
        return properties;
    }
}
