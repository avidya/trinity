<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <title>配置服务中心</title>

    <link rel="stylesheet" type="text/css" href="/css/core.css" />
    <link rel="stylesheet" type="text/css" href="/css/datepicker.css" />
    <link rel="stylesheet" type="text/css" href="/css/ta.css" />
    <script type="text/javascript" src="/js/seed.js" main="ta.js" corelib=""></script>
</head>
<body>
<div id="page2" class="flightChange">
    <!-- header begin -->
    <div id="header">
    <div class="titler clearfix">
        <div class="loginbar">
             当前用户<a href="/user">{{user}}</a>用户身份<a href="###">\\
                  %if 'dev' in my_roles:
                    开发 \\
                  %end
                  %if 'qa' in my_roles:
                    测试 \\
                  %end
                  %if 'product' in my_roles:
                    运维\\
                  %end
                </a><a href='/logout' target="_parent" class="logout">退出</a>
        </div>
        <div class="logo">
            <a href="/manager"><img alt="配置服务中心" src="/images/logo.png" /></a><span>|</span><em>配置服务中心</em>
        </div>
    </div>
</div>
    <!-- header end -->
    <div class="grid c2-s4">
        <div class="col-main">
            <div class="main-wrap">
                <div class="mainCon">
                    <div class="ticketOrdersList">
                        <table>
                            <colgroup>
                                <col width="50%">
                                <col width="50%">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>环境</th>
                                    <th>项目</th>
                                </tr>
                            </thead>
                            <tbody class="J_CheckWrap">
                              <tr class="tb-odd">
                                  <td style="padding:20px;">
                                      <label for="checkbox-dev" style="display:block;"><input id="checkbox-dev" type="checkbox" style="width:auto;" name="roles1" value="dev" 
		                              %if 'dev' in roles:
                                          checked="checked"
                                       %end
                                       %if user!='admin':
                                           disabled="disabled"
                                       %end
                                       /> dev</label>
                                      <label for="checkbox-alpha" style="display:block;"><input id="checkbox-alpha" type="checkbox" style="width:auto;" name="roles1" value="alpha"
		                              %if 'alpha' in roles:
                                          checked="checked"
                                      %end
                                      %if user!='admin':
                                           disabled="disabled"
                                      %end
                                       /> alpha</label>
                                      <label for="checkbox-qa" style="display:block;"><input id="checkbox-qa" type="checkbox" style="width:auto;" name="roles1" value="qa"
		                              %if 'qa' in roles:
                                          checked="checked"
                                      %end
                                      %if user!='admin':
                                           disabled="disabled"
                                      %end
                                       /> qa</label>
                                      <label for="checkbox-beta" style="display:block;"><input id="checkbox-beta" type="checkbox" style="width:auto;" name="roles1" value="beta"
                                      %if 'beta' in roles: 
                                        checked="checked" 
                                      %end
                                      %if user!='admin':
                                           disabled="disabled"
                                       %end
                                      /> beta</label>
                                      <label for="checkbox-product" style="display:block;"><input id="checkbox-product" type="checkbox" style="width:auto;" name="roles1" value="product"
                                      %if 'product' in roles: 
                                        checked="checked" 
                                      %end
                                      %if user!='admin':
                                           disabled="disabled"
                                       %end
                                      /> product</label></td>
                                      <td style="padding:20px;">
                                             % for p in projects:
		                               <label for="Checkbox3" style="display:block;"><input id="{{p}}" type="checkbox" style="width:auto;" name="projects1" value="{{p}}"
		                               %if (','+ p+',') in projs:
                                                  checked="checked"
                                               %end
                                               %if user!='admin':
                                                  disabled="disabled"
                                               %end
                                               /> {{p}}</label>
                                            % end
                                        </td>
                                    </tr>
                                    <tr></tr>
                                    %if user=='admin':
                                      <form id='modifyAuthority' method="POST" action="/user/modifyAuthority">
                                         <input type="hidden" name="opereduser" value="{{opereduser}}"/>
                                         <input type="hidden" id="rolelist" name="rolelist"/>
                                         <input type="hidden" id="projectlist" name="projectlist"/>
                                      <tr><td colspan="4" style="text-align:center;">
                                         <input type="submit" value="确定" class="hw-button1" onclick="return confirmSubmit();"/>
                                      </td></tr>
                                      </form>
                                    %end
                            </tbody>
                            <tfoot><tr><td colspan="4" style="text-align:center;">Powered by bottle &amp; Mako</td></tr></tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sub">
            <!-- sider begin -->
            <div class="nav-wrap">
    <div class="nav">
        <h3>用户列表：</h3>
        <ul>    
           %if user=='admin':
              %for username in userlist:  
                <li><a href="/user?opereduser={{username}}">{{username}}</a></li>
              %end
           %else:
               <li><a href="/user?opereduser={{user}}">{{user}}</a></li>
           %end
           %if 'warn' in globals():
               <li><a href="#">{{warn}}</a></li>
           %end 
        </ul>
   %if user=='admin':
          <a href="javascript:;" style="border:solid 1px green;padding:2px 6px;margin-left:35px;margin-top:15px;display:inline-block; text-decoration:none;color:Green;" id="addUser">新建用户</a>
          <form  method="POST" action="/user/addUser">
          <div style="margin:10px;border:solid 1px green;padding:5px;display:none;" id="addUserBlock">
               <label style="display:block;">用户:<input type="text" style="width:120px;" name='userName'/></label>
               <label style="display:block;">密码:<input type="password" style="width:120px;" name='password'/></label>
               <label style="display:block;text-align:center;margin-top:3px;"><input type="submit" value="确定" style="background-color:White;border:solid 1px green;"/>&nbsp;&nbsp;<input id="exitUser" type="reset" value="关闭"
                style="background-color:White;border:solid 1px green;" /></label>
          </div>
          </form>
   %end
        <a href="javascript:;" style="border:solid 1px green;padding:2px 6px;margin-left:35px;margin-top:15px;display:inline-block; text-decoration:none;color:Green;" id="modifyPassword">修改密码</a>
        <form method="POST" action="/user/modifyPassword">
        <div style="margin:10px;border:solid 1px green;padding:5px;display:none;" id="modifyPasswordBlock">
               <input type="hidden" name="opereduser" value="{{opereduser}}"/>
            %if user=='admin' and opereduser!='admin':
               <label style="display:block;">新密码:<input type="password" style="width:120px;" name="newpassword"/></label>
            %else:
               <label style="display:block;">旧密码:<input type="password" style="width:120px;" name="oldpassword"/></label>
               <label style="display:block;">新密码:<input type="password" style="width:120px;" name="newpassword"/></label>
            %end
            <label style="display:block;text-align:center;margin-top:3px;"><input type="submit" value="确定" style="background-color:White;border:solid 1px green;"/>&nbsp;&nbsp;<input id="exitModifyPassword" type="reset" value="关闭"
            style="background-color:White;border:solid 1px green;" /></label>
        </div>
        </form>
</div>
</div>
            <!-- sider end -->
        </div>
    </div>
    <a href="javascript:;" class="J_sbControler"></a>
</div>
<script src="http://www.okyayi.com/include/js/jquery.js"></script>
<script type="text/javascript">
    $("#modifyPassword,#exitModifyPassword").live("click",function(){
        if($(this).attr("id")=="modifyPassword"){
            $("#modifyPasswordBlock").show();
            $(this).hide(); 
        }else{
            $("#modifyPasswordBlock").hide();
            $("#modifyPassword").show();   
        }
    });
    $("#addUser,#exitUser").live("click",function(){
        if($(this).attr("id")=="addUser"){
            $("#addUserBlock").show();
            $(this).hide();
        }else{
            $("#addUserBlock").hide();
            $("#addUser").show();
        }
    });
    function confirmSubmit() {
	var rolelist = "";
	$("input[name='roles1']:checked").each(function() {
			rolelist += $(this).val()+",";
	});
	if (rolelist.length > 0) {
		rolelist = rolelist.substring(0, rolelist.length - 1);
		$("#rolelist").val(rolelist);
	}
	var projectlist = "";
	$("input[name='projects1']:checked").each(function() {
		projectlist += $(this).val()+",";
	});
	if (projectlist.length > 0) {
		projectlist = projectlist.substring(0, projectlist.length - 1);
		$("#projectlist").val(projectlist);
	}
		return true;
   }

   $(".nav").css("height",$(document).height()-44);
</script>
</body>
</html>
