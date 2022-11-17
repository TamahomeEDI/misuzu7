// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

  //================================================================
  //   名　称    application.js
  //   説　明    クライアント側に動作を抑制します。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.08.27  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
function chkLength(str, maxLength){
	// 1: NG, 0: OK
	var stringLength = byteLength(str);
	if(stringLength > maxLength){
		return 1;
	}
	
	return 0;
}

function byteLength(str){
	var total = 0;
	var LOG2_256 = 8;
	var LN2x8 = Math.LN2 * LOG2_256;
	
	for(var i = 0; i < str.length; i++){
			total += Math.ceil(Math.log(str[i].charCodeAt()) / LN2x8);
	}
	
	return total;
}

function isValidDate(s) {
  // s format YYYY/MM/DD
  var bits = s.split('/');
  var y = bits[0], m  = bits[1], d = bits[2];
  // Assume not leap year by default (note zero index for Jan)
  var daysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31];

  // If evenly divisible by 4 and not evenly divisible by 100,
  // or is evenly divisible by 400, then a leap year
  if ( (!(y % 4) && y % 100) || !(y % 400)) {
    daysInMonth[1] = 29;
  }

  return d <= daysInMonth[--m]
}

function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}