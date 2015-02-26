<!DOCTYPE HTML>
<html>
<head>
    <meta charset="UTF-8">
    <title>配置服务中心</title>
    <link rel="stylesheet" type="text/css" href="/css/core.css" />
    <link rel="stylesheet" type="text/css" href="/css/datepicker.css" />
    <link rel="stylesheet" type="text/css" href="/css/ta.css" />
    <link rel="stylesheet" href="/js/skins/default.css" />
</head>
<body>
<div id="page2" class="flightChange">
    <!-- header begin -->
    <div id="header">
    <div class="titler clearfix">
        <div class="loginbar">
            当前用户<a href="/user">{{user}}</a>用户身份<a href="###">\\
                  %if 'dev' in roles:
                    开发 \\
                  %end
                  %if 'qa' in roles:
                    测试 \\
                  %end
                  %if 'product' in roles:
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
                    <h1>{{current}}</h1>
                    %if 'dev' in hosts:
                        <a href="/manager/{{current}}/dev">DEV({{hosts['dev']}})</a>
                    %end
                    %if 'alpha' in hosts:
                        <a href="/manager/{{current}}/alpha">ALPHA({{hosts['alpha']}})</a>
                    %end
                    %if 'qa' in hosts:
                        <a href="/manager/{{current}}/qa">QA({{hosts['qa']}})</a>
                    %end
                    %if 'beta' in hosts:
                        <a href="/manager/{{current}}/beta">BETA({{hosts['beta']}})</a>
                    %end
                    %if 'product' in hosts:
                        <a href="/manager/{{current}}/product">PRODUCT({{hosts['product']}})</a>
                    %end
                % if 'warn' in globals():
                    <h2>{{warn}}</h2>
                % else:
                    <div class="ticketOrdersList">
                        <table class="tableborder">
                            <colgroup>
                                <col width="25%">
                                <col width="35%">
                                <col width="30%">
                                <col width="10%">
                            </colgroup>
                            <thead>
                                <tr class="tableborder">
                                    <th>配置项</th>
                                    <th>配置值</th>
                                    <th>配置项含义</th>
                                    <th>操作</th>
                                </tr>
                            </thead>
                            <tbody class="J_CheckWrap">
                                % for key,configvalue in config:
                                    <tr class="tb-odd tableborder">
                                        <td class="tableborder" id="configkey-{{config.index((key, configvalue))}}">{{key}}</td>
                                        <td class="tableborder"><input id="configvalue-{{config.index((key, configvalue))}}" type="text" value="
% if configvalue:
{{configvalue.split("_=|=_")[0]}}
% end
"/></td>
                                        <td class="tableborder"><input id="configcomment-{{config.index((key, configvalue))}}" type="text" value="
                                        % if configvalue and len(configvalue.split('_=|=_')) > 1:
{{configvalue.split('_=|=_')[1]}}
                                        % end
"  /></td>
                                        <td class="tableborder"><a href="javascript:;" class="modify" data-id="{{config.index((key, configvalue))}}">修改</a><a href="javascript:;" class="delete" data-id="{{config.index((key, configvalue))}}">删除</a></td>
                                    </tr>
                                % end
                                    <tr class="trAdd tb-odd tableborder" style="display:none;">
                                        <td class="tableborder"><input id="configkey-{{len(config) + 1}}" type="text" value=""/></td>
                                        <td class="tableborder"><input id="configvalue-{{len(config) + 1}}" type="text" value=""/></td>
                                        <td class="tableborder"><input id="configcomment-{{len(config) + 1}}" type="text" value=""/></td>
                                        <td class="tableborder"><a href="javascript:;" class="add" data-id="{{len(config) + 1}}">添加</a><a href="javascript:;" class="cancel">取消</a></td>
                                    </tr>
                                    <tr class="opera"><td colspan="4"><input id="btnAdd" type="button" value="添加" style="border:solid 1px gray;" /></tr>
                            </tbody>
                             <tfoot><tr><td colspan="4" style="text-align:center;">Powered by Bottle</td></tr></tfoot>
                        </table>
                    </div>
                % end
                </div>
            </div>
        </div>
        <div class="col-sub">
            <!-- sider begin -->
            <div class="nav-wrap">
    <div class="nav">
        <h3>项目列表：</h3>
        <ul>
            % for p in projects:
                <li><a href="/manager/{{p}}/{{env}}">{{p}}</a></li>
            % end
        </ul>
    </div>
</div>

            <!-- sider end -->
        </div>
    </div>
    <a href="javascript:;" class="J_sbControler"></a>
</div>
<form id='modifyConfig' method="POST" action="/manager/{{current}}/{{env}}">
    <input type="hidden" name="configkey" />
    <input type="hidden" name="configvalue" />
    <input type="hidden" name="configcomment" />
    <input type="hidden" name="action" />
</form>
<script src="/js/jquery.js"></script>
<script type="text/javascript" src="/js/jquery.artDialog.js"></script>
<script type="text/javascript" src="/js/plugins/iframeTools.js"></script>
<script type="text/javascript">
    $("#btnAdd").live("click",function(){
        $(".trAdd").show();
        $(this).hide();
    });
    $(".cancel").live("click",function(){
        $(this).closest('tr').hide();
        $("#btnAdd").show();
    });
    $(".modify,.delete,.add").live("click",function(){
        var id=$(this).attr("data-id");
        $("input[name='configkey']").val($(this).hasClass("add") ? $("#configkey-"+id).val() : $("#configkey-"+id).text());
        $("input[name='configvalue']").val($("#configvalue-"+id).val());
        $("input[name='configcomment']").val($("#configcomment-"+id).val());
        $("input[name='action']").val($(this).attr("class"));
        if($(this).hasClass("add")){
            $("#modifyConfig").submit(); 
        }else if($(this).hasClass("delete")){
            if(!confirm('are you delete?')){
                return;
            }
            $("#modifyConfig").submit(); 
        }else{
                $.ajax({
                    type: "POST",
                    url: $("#modifyConfig").attr('action'),
                    data: $("#modifyConfig").serialize(),
                    cache: false,
                    success: function(msg){
                    $.dialog({
                        time: 0.5,
                        title: "",
                        content:'修改成功！'
                    });
                    },
                    error: function(msg){
                    $.dialog({
                        time: 0.5,
                        title: "",
                        content:'修改失败！'
                    });
                    }
                });
        }
    });
</script>
</body>
</html> 
