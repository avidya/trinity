/*
 * Copyright 2011, ICAT seed
 * MIT Licensed
 * @Author jndream221@gmail.com
 * @Time 2012-05-17 08:30:00
 */
(function(e,f){if(f[e]===undefined){f[e]={}}e=f[e];e.loadContainer={};var b=window.location.href,h=document,a=h.head||h.getElementsByTagName("head")[0]||h.documentElement,j=(function(){var s,n=/\w*(\.source)?\.(js|css)/g,o=h.getElementsByTagName("script"),k,r=function(y,t){var z=a.childNodes,x;for(var w=0,v=z.length;w<v;w++){var u=z[w];if(u.nodeType===1&&u.nodeName.toLowerCase()===t&&/sys\/core(\.source)?\.css/i.test(u.href)){x=u}}return x};for(var q=0,m;m=o[q++];){k=!!h.querySelector?m.src:m.getAttribute("src",4);if(k&&/seed(\.source)?\.js/i.test(k)){e.refFile=m;e.appRef=k.substring(0,k.lastIndexOf("/assets"));var l=r(m,"link"),p=l.href;if(l&&p){s=e.sysRef=p.substr(0,p.lastIndexOf("/core"))}break}}return s})();var c=e.refFile.getAttribute("corelib"),d=j+"/icat/tccat"+(/debug/i.test(b)?".source":"")+".js";if(c!=undefined){c=c==""?j+"/jquery.js":c;c=/\w+:\/\/.*/i.test(c)?c:j+c;h.write('<script src="'+c+'"><\/script>');e.loadContainer[c]=true}h.write('<script src="'+d+'"><\/script>');e.loadContainer[d]=true;var i=e.refFile,g=i.getAttribute("main");if(g){g=/\.js$/i.test(g)?g.replace(/\.js$/i,""):g;g=/debug/i.test(b)?g+".source":g;g=e.appRef+"/assets/js/"+g+".js";h.write('<script src="'+g+'"><\/script>');e.loadContainer[g]=true}})("ICAT",this);
