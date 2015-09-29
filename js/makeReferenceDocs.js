/*
	node.js script for generating documentation. 

	To run, execute this from the command line:
	node makeReferenceDocs	
*/

var fs = require('fs');
eval(fs.readFileSync('autocompleteArrays.js')+'');


CodeMirror = require('./addon/runmode/runmode.node.js');
haxe = require('./codemirror/haxe.js');

var modules = [];
var enums = [];
haxeHintArray = haxeHintArray.concat(haxeMethodArray);

for (var i=0;i<haxeHintArray.length;i++){
	var r = haxeHintArray[i];
	if (r.length<3){
		continue;
	}
	var fn = r[0]+r[1];	
	var dotIndex=fn.indexOf(".");
	if (dotIndex>0){
		moduleName = fn.substring(0,dotIndex);
		if (modules.indexOf(moduleName)===-1){
			modules.push(moduleName);
			if (r[2]==="E"||r[2]==="Col"){
				enums.push(moduleName);
			}
		}
	}
}
/*
enums.sort();
modules.sort();
for (var i = 0;i<modules.length;i++){
	if (enums.indexOf(modules[i])>=0){
		modules.splice(i,1);
		i--;
	}
}
for(var i=0;i<enums.length;i++){
	modules.push(enums[i]);
}*/


function highlight(text){
	var result="<div class='Codemirror cm-s-default'>";
	function f(token,style,c,d,e){
	        if (token=="\n"){
	                result+="<br>";
	        } else if (token.trim().length==0){
	                for (var i=0;i<token.length;i++){
	                        //replace whitespace with explicit spaces
	                        result+="&nbsp;";
	                }
	        } else {
	                result+="<span class='cm-"+style+"'>"+token+"</span>";
	        }
	}
 	//text='function update(){\n  trace("Hello, sailor!");\n}';
	CodeMirror.runMode(text, "haxe",f);
	result+="</div>";
	return result;
}

function genReferencePage(moduleName){
	var pageHeader = "<!DOCTYPE html>"+
	"<html>"+
	"<head>"+
	' <meta charset="utf-8">'+
	"	<title>Zeedonk Reference " +"Getting Started"+"</title>"+
	'<link rel="shortcut icon" href="../images/icon256.png" />'+
	"<link href='https://fonts.googleapis.com/css?family=Lora:400,700' rel='stylesheet' type='text/css'>"+
	'<link rel="stylesheet" type="text/css" href="style.css">'+
	'<link rel="stylesheet" type="text/css" href="../css/codemirror.css">'+
	'<script src="../js/codemirror/codemirror.js"></script>'+
	'<script src="../js/codemirror/haxe.js"></script>'+
	"</head>"+
	"<body>"+
	'<div class="navBar">'+
	'<a href="/editor.html"><h2>Zeedonk</h2></a> <p><a class="moduleButton" href="Tutorial.html">Getting Started</a> <span class="moduleSelected">Library Reference</span> <a class="moduleButton" href="Shortcuts.html">Keyboard Shortcuts</a> <a class="moduleButton" href="Questions.html">Questions</a>'+
	"</div><p>"+
	"<h1>Library Reference</h1>";

	var tableStart = "<table>	"+
	//"<thead><tr class='header'><td  >Name</td><td  >Description</td></tr></thead>"+
	"	<tbody>";

	var tableEnd = 	"</tbody>"+
	"</table>";

	var pageFooter = '<br><br><br><center><img class="bottomDonk" src="../images/bigzeedonk.png"><br><br><br></center></body>'+
	"</html>";

	var pageContents = "";
	var oldPreface="";

	var moduleHeader="<div class='navBar'>";
	for (var i=0;i<modules.length;i++){
		var m = modules[i];
		if (moduleHeader.length>0){
			//moduleHeader+=" - ";
		}
		if (m===moduleName){
			moduleHeader+='<span class="moduleSelected">'+m+"</span>";			
		} else {
			moduleHeader+='<a class="moduleButton" href="'+m+'.html">'+m+'</a>';
		}
	}
	moduleHeader+="</div><p>";

	var enumContents ="<div id='enumFrame'>";

	if (moduleName==="Col"){
		enumContents ="<div id='colorFrame'>";		
	} else if (moduleName==="Font"){		
		enumContents="<table>"
	}
	var enumAdded=false;
	var counter=0;
	for (var i=0;i<haxeHintArray.length;i++){
		var r = haxeHintArray[i];
		if (r.length<3){
			continue;
		}
		var tag = r[2];
		var fn = r[0]+r[1];

		var doc =(r.length>3)?r[3]:"";
		var dotIndex=fn.indexOf(".");
		var preface=dotIndex>=0?fn.substring(0,dotIndex):tag;
		var postface=dotIndex>=0?fn.substring(dotIndex+1):tag;
		if (fn.indexOf(moduleName)!==0){
			continue;
		}

		if (tag.substr(0,2)==="M_"){
			if (moduleName==="String"){
				fn = '"abc"'+"."+postface;
			} else if (moduleName==="Array"){
				fn = '[1,2,3]'+"."+postface;
			}
		}

		counter++;
		var row = '<tr class="' +  ((counter%2==0)?"even":"odd")+'">';
		if (preface!=oldPreface&&pageContents.length>0){
			//console.log(preface+"-"+oldPreface);
			row = "<tr style='border-top:5px solid black;'>";
		}
		var docString="";
		var cs = "";
		if (enums.indexOf(preface)===-1){
			var suffixes=["",".2",".3",".4",".5",".6"];
			for (var j=0;j<suffixes.length;j++){
				var suffix=suffixes[j];
				var samplePath = "../demo/doc/"+r[0]+suffix+".hx";
				if (!fs.existsSync(samplePath)){
					if (suffix.length==0){
						fs.writeFileSync(samplePath,"");		
					} else {
						continue;
					}
				}
				cs = fs.readFileSync(samplePath);
				if (cs.length>0){
					var formatted = highlight(cs+"");
					docString+="<div class=\"codeInsert\">"+formatted+"<a class=\"editLink\" href=\"../editor.html?demo=doc/"+r[0]+suffix+"\">✎</a></div>";
				}
			}
		}
		//row+=<td>"+tag+"</td>;
		row+="<td><div class=\"funcdec\">"+highlight(fn+"")+"</div>";
		if (doc.length>0){
			row+="<div class='docLine'>"+doc+"</div>";
		}
		row+="<div>"+docString+"</div></td></tr>";
		pageContents+=row;
		oldPreface=preface;
		if (moduleName==="Col"){

			if (enumAdded){
				enumContents+=" <wbr>";
			}
			enumContents+="<span class='Col_"+postface+" colbubble'>"+postface+"</span>";
		} else if (moduleName==="Font"){

			var row = '<tr class="' +  ((counter%2==0)?"even":"odd")+'">';
			doc = doc.replace("images/fonts/","../images/fonts/black_")
			doc = doc.replace("<img","<img style='padding-top:20px; padding-bottom:20px;padding-left:5px;padding-right:10px;'");
			doc = "<div style='text-align:center;padding:5px;background:white;border-radius:5px;border:1px solid gray;'>"+doc+"</div>"
			enumContents+=row+"<td >"+postface+"<p>"+doc+"</td></tr>";

		}else {
			if (enumAdded){
				enumContents+=", <wbr>";
			}
			enumContents+=postface;
		}
		enumAdded=true;
	}
	 if (moduleName==="Font"){
	 	enumContents+="</table>"
	 } else {
		enumContents+="</div>";
	}
	var tableHeader = "<h3 class='moduleHeader'>"+ moduleName+"</h3><p>";
	pageContents = pageContents;

	var moduleDescription="";
	if (moduleDescriptions.hasOwnProperty(moduleName) && moduleDescriptions[moduleName].length>0){
		moduleDescription = '<div class="moduleDescription">'+moduleDescriptions[moduleName]+'</div>'
	}
	
	if (moduleName.length>0){		
		var wholePage = pageHeader+moduleHeader+tableHeader+moduleDescription+tableStart+pageContents+tableEnd+pageFooter;
		if (enums.indexOf(moduleName)>=0){
			wholePage = pageHeader+moduleHeader+tableHeader+moduleDescription+enumContents+pageFooter;
		} 
		fs.writeFileSync("../Documentation/"+moduleName+".html",wholePage);
	} else {
		var wholePage = pageHeader+moduleHeader+pageFooter;
		fs.writeFileSync("../Documentation/index.html",wholePage);		
	}
}


function splitTutorialTxt(s){
	var lines = s.split("\n");
	var result=[""];
	var state=0;//0=text,1=code
	for (var i=0;i<lines.length;i++){
		var l = lines[i];
		if (l.length>0&&l[0]=="-"){
			result.push("");
			state=1-state;
			continue;
		}
		if (result[result.length-1].length>0){
			if (state==0){
				result[result.length-1]+="<br>";			
			} else {
				result[result.length-1]+="\n";			
			}
		}
		result[result.length-1]+=l;
	}
	return result;
}

function genTutorialPage(){


	var pageHeader = "<!DOCTYPE html>"+
	"<html>"+
	"<head>"+
	' <meta charset="utf-8">'+
	"	<title>Zeedonk Reference " +moduleName+"</title>"+
	'<link rel="shortcut icon" href="../images/icon256.png" />'+
	"<link href='https://fonts.googleapis.com/css?family=Lora:400,700' rel='stylesheet' type='text/css'>"+
	'<link rel="stylesheet" type="text/css" href="style.css">'+
	'<link rel="stylesheet" type="text/css" href="../css/codemirror.css">'+
	'<script src="../js/codemirror/codemirror.js"></script>'+
	'<script src="../js/codemirror/haxe.js"></script>'+
	"</head>"+
	"<body>"+
	'<div class="navBar">'+
	'<a href="/editor.html"><h2>Zeedonk</h2></a> <p><span class="moduleSelected" href="Tutorial.html">Getting Started</span> <a href="index.html" class="moduleButton">Library Reference</a> <a class="moduleButton" href="Shortcuts.html">Keyboard Shortcuts</a> <a class="moduleButton" href="Questions.html">Questions</a>'+
	"</div><p>"+
	'<div class="tutorialBody">'+
	"<h1>Getting Started</h1>";

	var pageFooter = '<br><br><br><center><img class="bottomDonk" src="../images/bigzeedonk.png"><br><br><br></center></div></body>'+
	"</html>";


	var contents="";

	tutorialtemplate = fs.readFileSync("../tutorialoutline.txt")+'';
	var doc = splitTutorialTxt(tutorialtemplate);	
	for (var i=0;i<doc.length;i++){
		doc[i]=doc[i].trim();
		contents+="<p>";
		if (i%2==0){
			contents+=doc[i];
		} else {
			var formatted = highlight(doc[i]);
			var fileName="tutorial_"+Math.floor(i/2);
			fs.writeFileSync("../demo/tutorial/"+fileName+".hx",doc[i]);
			docString="<div class=\"codeInsert tutorialCodeInsert\">"+formatted+"<a class=\"editLink\" target='editor' href=\"../editor.html?demo=tutorial/"+fileName+"\">✎</a></div>";
			contents+=docString;			
		}
	}

	var page = pageHeader+contents+pageFooter;
	fs.writeFileSync("../Documentation/Tutorial.html",page);

}

for (var i=0;i<modules.length;i++){
	genReferencePage(modules[i]);	
}
genReferencePage("");
genTutorialPage();