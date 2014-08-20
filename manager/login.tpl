<!DOCTYPE HTML>
<html class="whole">
<head>
    <meta charset="UTF-8">
    <title>配置服务中心</title>

    <link rel="stylesheet" type="text/css" href="/css/core.css" />
    <link rel="stylesheet" type="text/css" href="/css/datepicker.css" />
    <link rel="stylesheet" type="text/css" href="/css/ta.css" />
</head>
<body>
    <div id="page2" class="login">
        <div class="logoBox">
            <img class="logoImg" alt="配置服务中心" src="images/login_logo.png" />
        </div>
        <div class="loginBox">
            <form action="/login" method="post" id="J_Login">
                <ul class="text">
                    <li>用户名：</li>
                    <li>密&nbsp;&nbsp;&nbsp;码：</li>
                </ul>
                <ul class="inputs">
                    <li><input type="text" class="commInput" name="username" datatype="*" nullmsg="用户名不能为空" errormsg="用户名不能为空" /></li>
                    <li><input type="password" class="commInput" name="password" datatype="*" nullmsg="密码不能为空" errormsg="密码不能为空" /></li>
                    <li class="red" style="display:none;" id="J_Error">xxxx</li>
                    <li><button type="submit" class="buttonLogin">登  录</button></li>
                </ul>
            </form>
        </div>
    </div>
</body>
</html>
