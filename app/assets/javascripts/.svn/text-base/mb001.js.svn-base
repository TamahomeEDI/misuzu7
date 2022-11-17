  //================================================================
  //   名　称    tantosyamasuta
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.09.05  1.00.00     dinhlong.org@gmail.com       新規作成
  //=================================================================
function update_focus_menu(tantogroupcode,controlID) {
	jQuery.ajax({
		url: "/mb001/update_menulist",
		type: "GET",
		data: {"ajax_tantogroup_code" : tantogroupcode},
		dataType: "html",
		success: function(data) {
			jQuery("#"+controlID).html(data);
		}
	});
}

function update_sosiki(kijun_date) {
	if(kijun_date != null && kijun_date != ""){
		if(!isValidDate(kijun_date)){
			alert("基準日に誤りがあります。");
			$('#kijiundate').focus();
			return;
		} 
	}
	
	jQuery.ajax({
		url: "/mb001/update_sosiki",
		type: "GET",
		data: {"kijun_date" : kijun_date},
		dataType: "html",
		success: function(data) {
			jQuery("#jigyodate").attr('value',data);
		}
	});
}

function update_sosikiname(sosikicode,controlID) {
	jQuery.ajax({
		url: "/mb001/update_sosikiname",
		type: "GET",
		data: {"ajax_sosiki_code" : sosikicode},
		dataType: "html",
		success: function(data) {
			if(data=="") alert('組織コード がない');
			jQuery("#"+controlID).html(data);
		}
	});
}

function chk_tantocode(tantocode,kaisijitu)
{
	jQuery.ajax({
		url: "/mb001/checktantocode",
		type: "GET",
		data: {"tantocode" : tantocode,"kaisijitu" : kaisijitu},
		dataType: "html",
		success: function(data) {
			if(data=="1") alert('データが重複しています');
		}
	});
}
	

