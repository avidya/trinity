#!/usr/bin/env python
# -*- coding: UTF-8 -*-
# 配置服务器后台管理页面
#
# Author: kozz.gaof
# Date: 2014/07/11
#

from kazoo.client import KazooClient
import logging as log
from hashlib import sha1
from bottle import Bottle,route,run,template,request,redirect,static_file,view,get,post
from beaker.middleware import SessionMiddleware
import bottle

hosts={'dev':'10.1.10.215:2181','alpha':'10.1.10.215:2181','qa':'10.1.25.147:2181','beta':'10.1.25.5:2181','product':'172.25.12.117:2181'}
base_path='/trinity/config/'

log_file='trinity.log'
#log_level=log.DEBUG
log_level=log.INFO
#log_level=log.WARN
log_format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s'

log.basicConfig(filename=log_file, level=log_level, format=log_format, datefmt='%m/%d/%Y %I:%M:%S %p')
console = log.StreamHandler()
console.setLevel(log_level)
console.setFormatter(log.Formatter(log_format))
log.getLogger('').addHandler(console)
log.getLogger('kazoo.client').setLevel(log.WARN)

log.debug('start running...')
log.info('>>>>>> loading users: ')
with open('users') as users_file:
    lines=users_file.readlines()
    user_map=dict(map(lambda x:(x.strip().split()[0], x.strip().split()[1:]), lines))
    log.info(user_map)
users_file.close()

session_opts = {
    'session.type': 'file',
    'session.cookie_expires': 31536000,
    'session.timeout': 18000,
    'session.data_dir': './data',
    'session.auto': True
}
app = SessionMiddleware(bottle.app(), session_opts)

delimiter='_=|=_'

@route('/')
def index():
    return template('login')

@route('/js/<filename:path>')
def server_js(filename):
    return static_file(filename, root='./js');

@route('/css/<filename:path>')
def server_css(filename):
    return static_file(filename, root='./css');

@route('/images/<filename:path>')
def server_images(filename):
    return static_file(filename, root='./images');

@route('/logout')
def logout():
    session=request.environ.get('beaker.session')
    if session and session.has_key('trinity_user'):
        session.pop('trinity_user', None) 
        session.delete()
    redirect('/', code=302)

@route('/login', method='POST')
def login():
    username=request.forms.get('username')
    password=request.forms.get('password')
    if user_map.has_key(username) and user_map[username][0] == sha1(password).hexdigest():
        session=request.environ.get('beaker.session')
        session['trinity_user']=username
        session.save()
        redirect('/manager', code=302)
    log.warn('invalid username: '+username+' or password')
    return '用户名/密码错误！'

@route('/user')
@get('/user/<proj>')
@post('/user/<proj>')
@view('user')
def user(proj=None):
    session=request.environ.get('beaker.session')
    if not session or not session.has_key('trinity_user'):
        redirect('/', code=302)
    result={}
    result['user']=session['trinity_user']
    user=request.query.opereduser
    user=user if user else result['user']
    result['opereduser']=user
    result['my_roles']=user_map[result['user']][1]
    result['roles']=','+user_map[user][1].lstrip('(').rstrip(')')+','
    result['projs']=','+user_map[user][2].lstrip('(').rstrip(')')+','
    zk=KazooClient(hosts['dev'])
    projects=[]
    userName=request.forms.get('userName')
    password=request.forms.get('password')
    oldpassword=request.forms.get('oldpassword')
    newpassword=request.forms.get('newpassword')
    opereduser=request.forms.get('opereduser')
    rolelist=request.forms.get('rolelist')
    projectlist=request.forms.get('projectlist')
    try:
        zk.start()
        projects=getProjects(zk)
        result['projects']=projects
        if proj=='modifyPassword'and opereduser:
           if result['user']=='admin'and opereduser!='admin':
              modifyPassword(opereduser,newpassword)
              user_map[opereduser][0]=sha1(newpassword).hexdigest()
              redirect('/user', code=302)
           else:
              if user_map[user][0]==sha1(oldpassword).hexdigest():
                 modifyPassword(user,newpassword)
                 user_map[user][0]=sha1(newpassword).hexdigest()
                 redirect('/user', code=302)
              else: 
                 result['warn']='旧密码不正确！'
        if proj=='addUser': 
              if result['user']=='admin' and userName:
                 addUser(userName,password)
                 user_info=[sha1(password).hexdigest(), '()', '()']
                 user_map[userName]=user_info
                 redirect('/user', code=302)
              else:
                 result['warn']='没有权限添加用户！'
        if proj=='modifyAuthority':
              if result['user']=='admin'and opereduser:
                 modifyAuthority(opereduser,rolelist,projectlist)
                 user_map[opereduser][1]='('+rolelist+')'
                 user_map[opereduser][2]='('+projectlist+')'
                 redirect('/user?opereduser='+opereduser, code=302)                    
              else:
                 result['warn']='没有权限修改项目！'
    finally:
        zk.stop()
        zk.close()
    if result['user']=='admin':
       result['userlist']=user_map.keys()
    return result

def modifyPassword(userName,newpassword):  
       input   = open("users")  
       lines   = input.readlines()  
       input.close()  
       output  = open("users",'w');  
       for line in lines:  
           if not line:  
               break  
           if userName.strip()== line.split()[0].strip() :  
               temp = line.strip().split()
               temp1=temp[0]+' '+sha1(newpassword).hexdigest()+' '+temp[2]+' '+temp[3]+"\n"
               output.write(temp1)  
           else:    
               output.write(line)  
       output.close()

def addUser(userName,password):
	f = open('users','a')
	f.write(userName+' '+sha1(password).hexdigest()+' '+'()'+' '+'()'+"\n")
	f.close()

def modifyAuthority(userName,roles,projects):
       input=open("users")
       lines=input.readlines()
       input.close()
       output=open("users",'w');
       for line in lines:
           if not line:
               break
           if userName.strip()== line.split()[0].strip() :
               temp= line.strip().split()
	       temp1=temp[0]+' '+temp[1]+' '+'('+roles+')'+' '+'('+projects+')'+"\n"
               output.write(temp1)
           else:
               output.write(line)
       output.close()
  
@route('/manager')
@route('/manager/<proj>')
@get('/manager/<proj>/<env>')
@post('/manager/<proj>/<env>')
@view('manager')
def manager(proj=None, env='dev'):
    session=request.environ.get('beaker.session')
    if not session or not session.has_key('trinity_user'):
        redirect('/', code=302)

    result={}
    result['user']=session['trinity_user']
    result['roles']=user_map[result['user']][1]
    result['user_projects']=user_map[result['user']][2]
    zk=KazooClient(hosts[env])
    projects=[]

    key=request.forms.get('configkey')
    value=request.forms.get('configvalue')
    comment=request.forms.get('configcomment')
    action=request.forms.get('action')

    try:
        zk.start()
        projects=getProjects(zk)
        result['projects']=projects
        result['current']=proj if proj else projects[0]
        result['env']=env
        if action:
            zkOp=zkOperator(zk, result['current'], env, action)
            zkOp(key, value, comment)
            
        if env not in result['roles'] or result['current'] not in result['user_projects']:
            result['warn']='对不起，您没有'+env+'环境的操作权限！'
            return result
        zkOp=zkOperator(zk, result['current'], env, 'get')
        result['config']=zkOp()
        if action == 'delete' or action == 'add':
            redirect('/manager/'+result['current']+'/'+result['env'], code=302)
    finally:
        zk.stop()
        zk.close()

    return result

def zkOperator(zk, proj, env, op_mode='get'):
    path=base_path+proj+'/'+env+'/'

    def addData(key, value, comment):
        log.info('add new config: %s => %s, comment: %s' % (key, value, comment))
        zk.create(path+key, value+delimiter+comment)

    def setData(key, value, comment):
        if comment:
            comment=comment.strip()
        log.info('set config: %s => %s, comment: %s' % (key, value, comment))
        zk.set(path+key, value+delimiter+comment)

    def deleteData(key, value, comment):
        log.info('delete config: %s => %s, comment: %s' % (key, value, comment))
        zk.delete(path+key)
    
    def getData():
        config={}
        if not zk.exists(path):
            return config
        for key in zk.get_children(path):
            config[key]=zk.get(path+key)[0]
        return sorted(config.iteritems())

    ops={'add':addData, 'delete': deleteData, 'get': getData, 'modify': setData}
    return ops[op_mode]

def getProjects(zk):
    return zk.get_children(base_path)

run(app=app, host='0.0.0.0', port=8080)
