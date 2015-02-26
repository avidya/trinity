#!/bin/bash

projects='(aris-web,chis-web,crm-web,crm-task,hbo-web,his-web,his-task,his-dubbo,his-customization,his-admin,min-web,scm-web,sso-web)'
dev_account='(dev,alpha)'
test_account='(qa,beta)'
all_around=
dev=(huangfan jiaomingyang tianzhonghong luoweiping yangyang zhaoweifeng chenzhaoyue huangwei jinzhaokang jinxiangdong)
tst=(anxiao wuyajun hualiqing zhangzhiyan wangsujing)

for i in ${dev[@]}; do 
    echo $i 7c4a8d09ca3762af61e59520943dc26494f8941b $dev_account $projects
done

for i in ${tst[@]}; do 
    echo $i 7c4a8d09ca3762af61e59520943dc26494f8941b $test_account $projects
done

sed -i -r "s/(.*)(\([^\)]*\))/\1$projects/" users
