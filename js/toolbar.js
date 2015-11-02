function stopClick(){
	if (interpreter==null){
		interpreter = new Webbridge();
	}
	setbackgroundcolor(0);
	interpreter.stop();
}
function runClick(evt) {
	clearConsole();
	setbackgroundcolor(0);
	//compile(["restart"]);
	terryRun();
	consolePrint("Running Program",true);
	evt.preventDefault();
	return false;
}

function compile(args){
	setbackgroundcolor(0);
	terryRun();
}

function referenceClick(){
	if (interpreter==null){
		interpreter = new Webbridge();
	}
	var s = interpreter.get_functions();
	s=s.replace(/\n/g, "<br>");
	consolePrint(s,true);
}

function unfocus(){	
	document.body.focus();
	var els = document.getElementsByTagName("CANVAS");
	if (els.length>0){
		els[0].focus();
	}
	if (document.activeElement!=null) { document.activeElement.blur(); }
}

var interpreter;
function terryRun(){
	setbackgroundcolor(0x000000);
	//playSound(1232);
	if (interpreter==null){
		interpreter = new Webbridge();
	}
	var code = window.form1.code;

	var editor = code.editorreference;

	text = editor.getValue();
	stopClick();
	interpreter.runScript(text);
	unfocus();
}

function dateToReadable(title,time) {
	var year = time.getFullYear();
	var month = time.getMonth()+1;
	var date1 = time.getDate();
	var hour = time.getHours();
	var minutes = time.getMinutes();
	var seconds = time.getSeconds();

	if (month < 10) {
    	month = "0"+month;
	}
	if (date1 < 10) {
		date1 = "0"+date1;
	}
	if (hour < 10) {
		hour = "0"+hour;
	}
	if (minutes < 10) {
		minutes = "0"+minutes;
	}
	if (seconds < 10) {
		seconds = "0"+seconds;
	}

	var result = hour+":"+minutes+" "+year + "-" + month+"-"+date1+" "+title;
	return result;
}

function newClick() {
	if (!_editorDirty || confirm("You haven't saved your game - are you sure you want to create a new one?")) {
		editor.setValue("");
    	// Save it!
	} else {
	    // Do nothing!
	}

}

function saveClick() {
	var text=editor.getValue();

	var saveDat = {
		title:getTitle(),
		text:text,
		date: new Date()
	}

	var curSaveArray = [];
	if (localStorage['saves']===undefined) {

	} else {
		var curSaveArray = JSON.parse(localStorage.saves);
	}

	if (curSaveArray.length>19) {
		curSaveArray.splice(0,1);
	}
	curSaveArray.push(saveDat);
	var savesDatStr = JSON.stringify(curSaveArray);
	localStorage['saves']=savesDatStr;

	repopulateSaveDropdown(JSON.parse(savesDatStr));

	var loadDropdown = document.getElementById('loadDropDown');
	loadDropdown.selectedIndex=0;

	setEditorClean();

	consolePrint("saved file to local storage:<br><b>"+dateToReadable(saveDat.title,new Date(saveDat.date))+"</b>",true);
}



function loadDropDownChange() {
	var saveString = localStorage['saves'];
	if (saveString===undefined) {
			consolePrint("Eek, trying to load a file, but there's no local storage found. Eek!",true);
	}

	saves = JSON.parse(saveString);

	for (var i=0;i<saves.length;i++) {
		var sd = saves[i];
	    var val = sd.date;
	    //dateToReadable
	    if (val==this.value) {
	    	var saveText = sd.text;
			editor.setValue(saveText);
			setEditorClean();
			var loadDropdown = document.getElementById('loadDropDown');
			loadDropdown.selectedIndex=0;
			unfocus();
			stopClick();
			return;
	    }
	}

	consoleError("Eek, trying to load a save, but couldn't find it. :(",true);
}


function repopulateSaveDropdown(saves) {
	var loadDropdown = document.getElementById('loadDropDown');
	loadDropdown.options.length = 0;

	if (saves===undefined) {
		try {
			if (localStorage['saves']===undefined) {
				return;
			} else {
				saves = JSON.parse(localStorage["saves"]);
			}
		} catch (ex) {
			return;
		}
	}

    var optn = document.createElement("OPTION");
    optn.text = "Load";
    optn.value = "Load";
    loadDropdown.options.add(optn);

	for (var i=saves.length-1;i>=0;i--) {
		var sd = saves[i];
	    var optn = document.createElement("OPTION");
	    var key = dateToReadable(sd.title,new Date(sd.date));
	    optn.text = key;
	    optn.value = sd.date.toString();
	    loadDropdown.options.add(optn);
	}
	loadDropdown.selectedIndex=0;
}

repopulateSaveDropdown();
var loadDropdown = document.getElementById('loadDropDown');
loadDropdown.selectedIndex=0;

function levelEditorClick_Fn() {
	if (textMode || state.levels.length===0) {
		compile(["loadLevel",0]);
		levelEditorOpened=true;
    	canvasResize();
	} else {
		levelEditorOpened=!levelEditorOpened;
    	canvasResize();
    }
}

function shareClick() {
	consolePrint("Sending code to github...",true)
	var title = getTitle();//"Untitled Zeedonk Script";
//	compile();


	var source=editor.getValue();

	var gistToCreate = {
		"description" : "title",
		"public" : true,
		"files": {
			"readme.txt" : {
				"content": "Play this game by pasting the script in http://www.zeedonk.net/editor.html"
			},
			"script.hx" : {
				"content": source
			}
		}
	};


	var githubURL = 'https://api.github.com/gists';
	var githubHTTPClient = new XMLHttpRequest();
	githubHTTPClient.open('POST', githubURL);
	githubHTTPClient.onreadystatechange = function() {
		if(githubHTTPClient.readyState!=4) {
			return;
		}
		var result = JSON.parse(githubHTTPClient.responseText);
		if (githubHTTPClient.status===403) {
			consoleError(result.message);
		} else if (githubHTTPClient.status!==200&&githubHTTPClient.status!==201) {
			consoleError("HTTP Error "+ githubHTTPClient.status + ' - ' + githubHTTPClient.statusText);
		} else {
			var id = result.id;
			var url = "play.html?p="+id;
			url=qualifyURL(url);

			var editurl = "editor.html?hack="+id;
			editurl=qualifyURL(editurl);
			var sourceCodeLink = "link to source code:<br><a href=\""+editurl+"\">"+editurl+"</a>";

			consolePrint("GitHub submission successful - " + sourceCodeLink,true);

			consolePrint("The game can now be played at this url:<br><a target=\"_blank\" href=\""+url+"\">"+url+"</a>",true);

		}
	}
	githubHTTPClient.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	var stringifiedGist = JSON.stringify(gistToCreate);
	githubHTTPClient.send(stringifiedGist);
}

function rebuildClick() {
	clearConsole();
	compile(["rebuild"]);
}

function post_to_url(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        if(params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);

            form.appendChild(hiddenField);
         }
    }

    document.body.appendChild(form);
    form.submit();
}

function exportClick() {
	var sourceCode = editor.getValue();

	compile("restart");

	var sourceString = JSON.stringify(sourceCode);

	buildStandalone(sourceString);
}
