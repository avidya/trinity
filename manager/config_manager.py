#!/usr/bin/env python
# -*- coding: UTF-8 -*-
#
# Author: kozz.gaof
# Date: 2014/06/18
#
from kazoo.client import KazooClient
import logging as log
import sys
from getopt import getopt
from pipe import *

hosts='10.1.10.215:2181'
base_path='/trinity/config/'
log_file='/tmp/zk_opt.log'
#log_level=log.DEBUG
log_level=log.INFO
#log_level=log.WARN
log_format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s'

log.basicConfig(filename=log_file, level=log_level, format=log_format, datefmt='%m/%d/%Y %I:%M:%S %p')
console = log.StreamHandler()
console.setLevel(log_level)
console.setFormatter(log.Formatter(log_format))
log.getLogger('').addHandler(console)

log.debug('start running...')

def usage():
    print 
    print 'Usage:'
    print '\tconfig_manager.py -p project {-r -i input}  [-e dev|alpha|qa|beta|product] [-v version] [-z ZK_ADDRESS] [-x] [-h]'
    print '\tconfig_manager.py -p project {-s -o output} [-e dev|alpha|qa|beta|product] [-v version] [-z ZK_ADDRESS] [-h]'
    print

def param_validate(param_dict):
    if not param_dict:
        return False
    p=param_dict.keys()
    if '-h' in p:
        usage()
        sys.exit(0)
    if '-p' not in p or not param_dict['-p']:
        return False
    elif ('-r' in p and '-s' in p) or ('-r' not in p and '-s' not in p):
        return False
    elif ('-r' in p and '-i' not in p) or ('-s' in p and '-o' not in p):
        return False
    elif param_dict.has_key('-i') and not param_dict['-i']:
        return False
    elif param_dict.has_key('-o') and not param_dict['-o']:
        return False
    elif param_dict.has_key('-v') and not param_dict['-v']:
        return False
    elif param_dict.has_key('-e') and param_dict['-e'] not in ('dev', 'alpha', 'qa', 'beta', 'product'):
        return False
    elif param_dict.has_key('-z') and not param_dict['-z']:
        return False
    return True

def get_processor(zk, mode='restore', expand=False):

    var_prefix='${'
    var_suffix='}'

    def resolveKey(value):
        if var_prefix in value and var_suffix in value:
            return value[value.index(var_prefix)+2:value.index(var_suffix)]
        else:
            return None

    def save(prop_file, path):
        for key in zk.get_children(path):
            prop_file.write(key+'='+zk.get(path+'/'+key)[0].decode('utf8') + '\n')

    def restore(prop_file, path):
        lines=prop_file.readlines()
        # CANNOT use '=' to split config entry, since '=' is also a valid charater in value
        config=map(lambda (k,v):(k.strip(), v.strip()), map(lambda line:(line[:line.index('=')], line[line.index('=')+1:]), lines))
        config_map=dict(config)
        for (key,value) in config:
            if zk.exists(path+key):
                log.warn(path+key+ " already exists!")
                continue
            if expand and resolveKey(value):
                nkey=resolveKey(value)
                if nkey and config_map.has_key(nkey):
                    v=value[:value.index(var_prefix)]+config_map[nkey]+value[value.index(var_suffix)+1:]
                    log.info("value: "+value+" contains variable: "+nkey+". already being resolved as: "+v)
                    value=v
                else:
                    log.warn("failed to resolve nesting variable. entry> " + key+ ":" + value)
            log.info("restore " + path+key+ " into config server")
            zk.create(path+key, value.encode('utf8'))

    return restore if mode == 'restore' else save

def main():
    try:
        optlst=getopt(sys.argv[1:], 'p:z:xhrsi:o:e:v:')[0]
    except getopt.GetoptError as err:
        log.error(err)
        usage()
        sys.exit(1)

    params=dict(optlst)
    if not param_validate(params):
        log.error('parameters are not valid, please follow the usage() guide.')
        usage()
        sys.exit(1)
    
    if params.has_key('-z'):
        hst=params['-z']
    else:
        hst=hosts

    zk = KazooClient(hst)
    try:
        zk.start()
        mode='save' if params.has_key('-s') else 'restore'
        expand=params.has_key('-x')
        processor=get_processor(zk, mode, expand)
        filename=params['-i'] if mode == 'restore' else params['-o'] 
        path = base_path + params['-p'] + '/'
        path += (params['-e'] if params.has_key('-e') else 'product') + '/'
        if params.has_key('-v'):
            path += params['-v'] + '/'
        import codecs
        with codecs.open(filename, 'a+', encoding='utf8') as prop_file:
            processor(prop_file, path)
        prop_file.close()
    finally:
        zk.stop()

if __name__=="__main__":
    main()
