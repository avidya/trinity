
package com.tc.trinity.core.config;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Collection;
import java.util.Map;
import java.util.Properties;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider;
import org.springframework.core.type.filter.AnnotationTypeFilter;
import org.springframework.stereotype.Controller;

import com.tc.trinity.core.AbstractConfigurable;
import com.tc.trinity.core.ConfigContext;
import com.tc.trinity.core.config.EnhancedPropertyPlaceholderConfigurer.BeanData;
import com.tc.trinity.core.config.EnhancedPropertyPlaceholderConfigurer.SpringInfo;

/**
 * Spring容器配置
 * 
 * @author gaofeng
 * @date Jun 10, 2014 7:36:00 PM
 * @id $Id$
 */
public class SpringContextConfiguration extends AbstractConfigurable {
    
    private Logger logger;
    
    private final String name = "spring";
    
    @Override
    public String getName() {
    
        return this.name;
    }
    
    @Override
    public boolean doInit(ConfigContext context, Properties properties) {
    
        logger = LoggerFactory.getLogger(SpringContextConfiguration.class);
        // 因为Spring作为容器的特殊性，这个方位的逻辑委托给EnhancedPropertiesPlaceholderConfigurer类了
        return true;
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public synchronized boolean doOnChange(String key, String originalValue, String value) {
    
        Collection<SpringInfo> infos = (Collection<SpringInfo>) this.configContext.getAttribute("spring.info");
        if (infos == null || infos.size() == 0) {
            return true;
        }
        for (SpringInfo info : infos) {
            processEvalTag(info, key, originalValue, value);
            processValueAnnotation(info, key, originalValue, value);
            processBean(info, key, originalValue, value);
        }
        return true;
    }
    
    protected void processEvalTag(SpringInfo info, String key, String originalValue, String value) {
    
        ApplicationContext ac = info.getContext();
        String beanName = info.getBeanName();
        if (ac != null && StringUtils.isNotBlank(beanName)) {
            Properties p = (Properties) ac.getBean(beanName);
            p.put(key, value);
        }
    }
    
    protected void processValueAnnotation(SpringInfo info, String key, String originalValue, String value) {
    
        ApplicationContext ac = info.getContext();
        if (ac == null) {
            return;
        }
        ClassPathScanningCandidateComponentProvider scanner = new ClassPathScanningCandidateComponentProvider(false);
        scanner.addIncludeFilter(new AnnotationTypeFilter(Controller.class));
        for (BeanDefinition beanDefinition : scanner.findCandidateComponents("*")) {
            
            try {
                Object bean = ac.getBean(this.getClass().getClassLoader().loadClass(beanDefinition.getBeanClassName()));
                @SuppressWarnings("rawtypes")
                Class clazz = bean.getClass();
                for (Field field : clazz.getDeclaredFields()) {
                    if (!field.isAnnotationPresent(Value.class))
                        continue;
                    Value v = field.getAnnotation(Value.class);
                    if (StringUtils.isNotEmpty(v.value()) && v.value().contains(key)) {
                        field.setAccessible(true);
                        field.set(bean, value);
                    }
                }
            } catch (BeansException | ClassNotFoundException | IllegalArgumentException | IllegalAccessException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }
    
    protected void processBean(SpringInfo info, String key, String originalValue, String value) {
    
        ApplicationContext ac = info.getContext();
        String beanName = info.getBeanName();
        Map<String, BeanData> propertyMap = info.getPropertyMap();
        if (ac == null || StringUtils.isBlank(beanName) || propertyMap == null || propertyMap.size() == 0) {
            return;
        }
        BeanData bd = propertyMap.get(key);
        if (bd != null) {
            Object bean = ac.getBean(bd.getBeanName());
            if (bean != null) {
                String fieldName = bd.getFieldName();
                String methodName = "set" + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1, fieldName.length());
                Method method = null;
                try {
                    method = bean.getClass().getDeclaredMethod(methodName, new Class[] { String.class });
                } catch (Exception e) {
                    logger.error(e.getMessage(), e);
                }
                if (method == null) {
                    Field field = null;
                    try {
                        field = bean.getClass().getField(fieldName);
                    } catch (Exception e) {
                        logger.error(e.getMessage(), e);
                    }
                    if (field == null) {
                        logger.error("no field to set property:" + fieldName);
                    } else {
                        field.setAccessible(true);
                        try {
                            field.set(bean, value);
                        } catch (Exception e) {
                            logger.error(e.getMessage(), e);
                        }
                    }
                } else {
                    method.setAccessible(true);
                    try {
                        method.invoke(bean, value);
                    } catch (Exception e) {
                        logger.error(e.getMessage(), e);
                    }
                }
            }
        }
        
    }
    
    @Override
    public String getExtensionName() {
    
        return this.getClass().getName();
    }
    
}
