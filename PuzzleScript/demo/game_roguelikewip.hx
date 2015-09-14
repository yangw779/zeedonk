Game.title="Roguelike Example";

//Palette stuff
var DOSpalette:Array<Int> = [
  0x000000, //0 - BLACK
  0x000080, //1 - BLUE
  0x008000, //2 - GREEN
  0x008080, //3 - CYAN
  0x800000, //4 - RED
  0x800080, //5 - MAGENTA
  0x808000, //6 - BROWN
  0xc0c0c0, //7 - LIGHT GRAY
  0x808080, //8 - DARK GRAY
  0x0000FF, //9 - BRIGHT BLUE
  0x00FF00, //10 - BRIGHT GREEN
  0x00FFFF, //11 - BRIGHT CYAN
  0xFF0000, //12 - BRIGHT RED
  0xFF00FF, //13 - BRIGHT MAGENTA
  0xFFFF00, //14 - BRIGHT YELLOW
  0xFFFFFF, //15 - WHITE
];

//Message line functions
var message:String = "ROGUELIKE";

//Screen functions
var screen:Array<String> = [];
var cellbackground:Array<Int> = [];
var cellforeground:Array<Int> = [];
var vmult:Array<Int> = [];
var updatescreen:Bool = false;
var mapwidth:Int = 24;
var mapheight:Int = 10;

function setupscreen(){
  //We're stuck with 768x480 aspect ratio for now
  Text.setfont(Font.DOS, 1);
  Gfx.showfps = true;
  updatescreen = true;
  Gfx.clearscreeneachframe=false;
  
  for(j in 0 ... mapheight){
    vmult.push(j * mapwidth);
    for(i in 0 ... mapwidth){
      cellforeground.push(7);
      cellbackground.push(0);
  	  screen.push(" ");
    }
  }
}
 
function drawscreen(){
  for(j in 0 ... mapheight){
    for(i in 0 ... mapwidth){
      Gfx.fillbox(i*8, j*11, 8, 11, DOSpalette[cellbackground[i + vmult[j]]]);
  	  Text.display((i*8)-7, (j*11)-2, screen[i + vmult[j]] + " ", DOSpalette[cellforeground[i + vmult[j]]]);
    }
  }
}

function placechar(x:Int, y:Int, t:String, col:Int, back:Int){
  if(inbox(x, y, 0, 0, mapwidth, mapheight)){
    screen[x + vmult[y]] = t;
    cellforeground[x + vmult[y]] = col;
    cellbackground[x + vmult[y]] = back;
  }
}

function getchar(x:Int, y:Int):String {
  if(inbox(x, y, 0, 0, mapwidth, mapheight)){
    return screen[x + vmult[y]];
  }else{
    return "X";
  }
}

function getfore(x:Int, y:Int):Int {
  if(inbox(x, y, 0, 0, mapwidth, mapheight)){
    return cellforeground[x + vmult[y]];
  }else{
    return 7;
  }
}

function getbackground(x:Int, y:Int):Int {
  if(inbox(x, y, 0, 0, mapwidth, mapheight)){
    return cellbackground[x + vmult[y]];
  }else{
    return 0;
  }
}


//Help Functions
function inbox(x:Float, y:Float, x1:Float, y1:Float, w:Float, h:Float):Bool {
  if (x >= x1 && y >= y1) {
    if (x < x1 + w && y < y1 + h) {
      return true;
    }
  }
  return false;
}
	
//Entity functions

var entity:Array<Object>;
var numentity:Int;

var player:Int;

function resetentity(t:Int){
  entity[t].x = 0;
  entity[t].y = 0;
  entity[t].active = false;
  entity[t].type = "nothing";
  entity[t].tile = "X";
  entity[t].fore = 7;
  entity[t].back = 0;
}

function getfreeentityindex():Int{
  var i:Int = 0;
  var z:Int = -1;
  if(numentity == 0) {
    z = 0; 
  }else {
    while (i < numentity) {
      if (!entity[i].active) {
        z = i;
        break;
      }
      i++;
    }
    if (z == -1) z = numentity;
	}
    
  if(z > entity.length - 1){
    entity.push({});
    numentity++;
  } 
  return z;
}

function create(_x:Int, _y:Int, t:String){
  var i:Int = getfreeentityindex();
  resetentity(i);
  
  entity[i].x = _x;
  entity[i].y = _y;
  entity[i].active = true;
  if(t == "player"){
  	entity[i].back = 0;
  	entity[i].fore = 15;
  	entity[i].tile = "@";
    entity[i].type = "player";
  }
}

function getplayer():Int {
  for(i in 0 ... numentity){
    if(entity[i].type == "player") return i;
  }
  return -1;
}

function new(){
  setupscreen();
  
  for(j in 0 ... mapheight){
    for(i in 0 ... mapwidth){
      if(Random.occasional()){
        placechar(i,j,Random.pickstring("X","F","#","Y"),Random.int(1,6),0);
      }
    }
  }

  entity = [];
  numentity = 0;
  create(12, 6, "player");
  message = "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
}

var inputthisframe:Bool;

function moveentity(t:Int, xchange:Int, ychange:Int){
  updatescreen = true;
  trace(entity[t].x, entity[t].y);
  placechar(entity[t].x,entity[t].y," ",7,0);
  entity[t].x+=xchange;
  entity[t].y+=ychange;
  trace(entity[t].x, entity[t].y);
}

function render(){
  if(updatescreen){
    Text.display(Text.CENTER, Gfx.screenheight - 19, message + " ", DOSpalette[15]);
 
    for(i in 0 ... numentity){
      if(entity[i].active){
        placechar(entity[i].x,entity[i].y,entity[i].tile,entity[i].fore,entity[i].back);
      }    
    }
    Gfx.clearscreen(DOSpalette[0]);
  	drawscreen();
  trace("Drawing screen this frame");
    updatescreen = false;
  }
    
  //Gfx.fillbox(Gfx.screenwidth-40,0,40,15, Col.BLACK);
}

function update() {
  player = getplayer();
  if(player > -1){
    if(Input.pressed(Key.UP)){
      trace("Move up");
      moveentity(player, 0, -1);
    }else if(Input.pressed(Key.DOWN)){
      trace("Move down");
      moveentity(player, 0, 1);
    }else if(Input.pressed(Key.LEFT)){
      trace("Move left");
      moveentity(player, -1, 0);
    }else if(Input.pressed(Key.RIGHT)){
      trace("Move right");
      moveentity(player, 1, 0);
    }
  }
  
  render();
}