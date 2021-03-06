var unitTesting=false;
var curlevel=0;
var curlevelTarget=null;
var levelEditorOpened=false;


var compiling = false;
var errorStrings = [];
var errorCount=0;

var gameScript=null;
function getScript(){
  return gameScript;
}

document.oncontextmenu = function (e) {
    if (e.target.tagName=="CANVAS"){
        e.preventDefault();
    }
};

function isIDE(){
    return IDE;
}

function bodyIsTargetted(){
    return document.activeElement.nodeName=="BODY";
}
function saveKey_terryhasntupgraded(key,val){
    localStorage.setItem(window.document.URL.toString()+key,val);
}

function loadKey_terryhasntupgraded(key){
    return localStorage.getItem(window.document.URL.toString()+key);
}

//on backspace down + optional callback
function onBackspace(e, callback){
    var key;
    if(typeof e.keyIdentifier !== "undefined"){
        key = e.keyIdentifier;

    }else if(typeof e.keyCode !== "undefined"){
        key = e.keyCode;
    }
    if (key === 'U+0008' || 
        key === 'Backspace' || 
        key === 8) 
    {
        if (e.target.className.toLowerCase()=="codemirror-search-field"){
            return false;
        }
        if(typeof callback === "function"){
            callback();
        }
        return true;
    }
    return false;
}

document.onkeydown = function (e) {
    switch (e.target.tagName.toLowerCase()){
        case "canvas":
            e.preventDefault();
            break;
    }        
    if (!IDE){
        return;
    }
    onBackspace(e,function(){
        e.preventDefault();
    });
    
    //ctrl/cmd+s to save
  if (e.keyCode == 83 && (navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
    saveClick();
    e.preventDefault();        
    return false;
    // Process event...
  }
    
    //ctrl/cmd+enter
  if (e.keyCode == 13 && (navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
    runClick(e);
    e.preventDefault();        
    return false;
    // Process event...
  }

    //ctrl/cmd+f
  if (e.keyCode == 70 && (navigator.platform.match("Mac") ? e.metaKey : e.ctrlKey)) {
    if (e.target.nodeName==="INPUT"){
        e.target.blur();
        editor.execCommand("find");   
        e.preventDefault();                  
        return false;        
    }
    if (e.target.nodeName==="BODY"){
        editor.execCommand("find");   
        e.preventDefault();          
        return false;
        // Process event...
    }
  }
};

try {
 	if (!!window.localStorage) { 
		if (localStorage[document.URL]!==undefined) {
            if (localStorage[document.URL+'_checkpoint']!==undefined){
                curlevelTarget = JSON.parse(localStorage[document.URL+'_checkpoint']);
                
                var arr = [];
                for(var p in Object.getOwnPropertyNames(curlevelTarget.dat)) {
                    arr[p] = curlevelTarget.dat[p];
                }
                curlevelTarget.dat = new Int32Array(arr);

            }
	        curlevel = localStorage[document.URL];            
		}
	}		 
} catch(ex) {
}



var verbose_logging=false;
var throttle_movement=false;
var cache_console_messages=false;
var quittingTitleScreen=false;
var quittingMessageScreen=false;
var deltatime=17;
var timer=0;
var repeatinterval=150;
var autotick=0;
var autotickinterval=0;
var winning=false;
var againing=false;
var againinterval=150;
var norepeat_action=false;
var oldflickscreendat=[];//used for buffering old flickscreen/scrollscreen positions, in case player vanishes
var keybuffer = [];


var messageselected=false;

var textImages={};
var initLevel = {
    width: 5,
    height: 5,
    layerCount: 2,
    dat: [
    1, 3, 3, 1, 1, 2, 2, 3, 3, 1,
    2, 1, 2, 2, 3, 3, 1, 1, 2, 2,
    3, 2, 1, 3, 2, 1, 3, 2, 1, 3,
    1, 3, 3, 1, 1, 2, 2, 3, 3, 1,
    2, 1, 2, 2, 3, 3, 1, 1, 2, 2
    ],
    movementMask:[
    1, 3, 3, 1, 1, 2, 2, 3, 3, 1,
    2, 1, 2, 2, 3, 3, 1, 1, 2, 2,
    3, 2, 1, 3, 2, 1, 3, 2, 1, 3,
    1, 3, 3, 1, 1, 2, 2, 3, 3, 1,
    2, 1, 2, 2, 3, 3, 1, 1, 2, 2
    ],
    rigidGroupIndexMask:[],//[indexgroupNumber, masked by layer arrays]
    rigidMovementAppliedMask:[],//[indexgroupNumber, masked by layer arrays]
    bannedGroup:[],
    colCellContents:[],
    rowCellContents:[]
};

var level = initLevel;



function getTitle(){
    if (metaData.title==""){
        metaData.title="Zeedonk game";
    }   
    return metaData.title;
}

var metaData = {
    title:"Zeedonk game",
    homepage:"",
    bgCol:"#000000"
}
function settitle(t){
    window.console.log("setting title to "+t)
    metaData.title=t;

    document.title = t;
}

function strip_http(url) {
   url = url.replace(/^https?:\/\//,'');
   url = url.replace(/\/*$/,'');
   return url;
}

function qualifyURL(url) {
    var a = document.createElement('a');
    a.href = url;
    return a.href;
}

function qualifyURL2(url) {
   if (!/^(f|ht)tps?:\/\//i.test(url)) {
      url = "http://" + url;
   }
   return url;
}

function sethomepage(t){    
    metaData.homepage=t;
    if (canSetHTMLColors){       
        var link = document.getElementById ("homepagelink");

        var separator = document.getElementById ("separator");
        if (t==""){
            separator.style.display="none";

            if (link.textContent){
                link.textContent="";
            } else if (line.innerText){
                link.innerText="";       
            }
            return;
        }

        separator.style.display="default";
        link.href=qualifyURL2(metaData.homepage);
        if (link.textContent){
            link.textContent=strip_http(link.href);
        } else if (line.innerText){
            link.innerText=strip_http(link.href);       
        }
    }
}

function decimalToHex(d) {
  var hex = Number(d).toString(16);
  hex = "000000".substr(0, 6 - hex.length) + hex; 
  return hex;
}


function setbackgroundcolor(t){
    metaData.bgCol="#"+decimalToHex(t);
    if (canSetHTMLColors){
        var meta = document.getElementById ("openfl-content");
        meta.style.backgroundColor=metaData.bgCol;
        document.body.style.backgroundColor=metaData.bgCol;
    } else {
        var meta = document.getElementById ("openfl-content");
        meta.style.backgroundColor=metaData.bgCol;   
    }
}

function setforegroundcolor(t){
    metaData.fgCol="#"+decimalToHex(t);
    if (canSetHTMLColors){
        var meta;
        meta = document.getElementById ("hacklink");
        meta.style.color = metaData.fgCol;
        meta = document.getElementById ("separator");
        meta.style.color = metaData.fgCol;
        meta = document.getElementById ("homepagelink");
        meta.style.color = metaData.fgCol;
    } else {  
    }
}
