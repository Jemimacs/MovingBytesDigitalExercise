const fs = require('fs');
const readLine = require('readline');
const stream = require('stream');

var blacklist_data = [];
var line_count = 0;
initialize("blacklist.txt");

function initialize(blacklist){
	var instream = fs.createReadStream(blacklist, {encoding: 'utf8'});
	var outstream = new stream();
	var rl = readLine.createInterface(instream, outstream);

	rl.on('line', function(data){
		blacklist_data.push(data.split(" "));
		//console.log(blacklist_data);
		line_count++;
	});

	rl.on('close', function(){
		console.log(line_count);
		//check();
	});
}

// function check(){
// 	var isBlocked = check_blacklist("Melisa", 1341441);
// 	console.log(isBlocked);
// }

function check_blacklist(name, phone_number){
	//Asumsi: pada bagian form input sudah terdapat pengecekan bahwa name dan phone_number harus diisi/required, dan input type dari phone_number adalah number
	try{
		var res = false;
		for (let i = 0, len = blacklist_data.length; i < len; i++) {
			if((blacklist_data[i][0] == name) && (blacklist_data[i][1] == phone_number)){
				res = true;
				break;
			}
		}
		return res;
	}
	catch(err){
		console.log("Error occured while searching");
	}
}