  //================================================================
  //   名　称    tantosyamasuta
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.09.05  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
  
function update_sosiki_list(kijun_date) {
	if(kijun_date != null && kijun_date != ""){
		if(!isValidDate(kijun_date)){
			alert("基準日に誤りがあります。");
			$('#kijiundate').focus();
			return;
		} 
	}
	// alert(code_id);
	jQuery.ajax({
		url: "/tantosyamasuta/update_sosiki",
		type: "GET",
		data: {"kijun_date" : kijun_date},
		dataType: "html",
		success: function(data) {
			jQuery("#sosiki_ajax").html(data);
		}
	});
}

function update_menu_list(tantogroupcode) {
	// alert(code_id);
	jQuery.ajax({
		url: "/tantosyamasuta/update_menulist",
		type: "GET",
		data: {"ajax_tantogroup_code" : tantogroupcode},
		dataType: "html",
		success: function(data) {
			jQuery("#menu_ajax").html(data);
		}
	});
}

function chkMain_Tantomasuta(){
	if(chkMainRequire_Tantomasuta() == 1){
		return false;
	}
	
	var lscode = $('#input_form_担当者コード').val();  
	if(chkLength(lscode, 10) == 1){
		alert("担当者コーがながすぎます");
		$('#input_form_担当者コー').focus();
		return false;
	}
	
	var lsname = $('#input_form_担当者名称').val();
	if(chkLength(lsname, 20) == 1){
		alert("担当者名称がながすぎます");
		$('#input_form_担当者名称').focus();
		return false;
	}
	
	var date1 = $('#input_form_開始日').val();
	if(date1 != null && date1 != ""){
		if(!isValidDate(date1)){
			alert("開始日に誤りがあります。");
			$('#input_form_開始日').focus();
			return false;
		} 
	}
	
	var date2 = $('#input_form_終了日').val();
	if(date2 != null && date2 != ""){
		if(!isValidDate(date2)){
			alert("終了日に誤りがあります。");
			$('#input_form_終了日').focus();
			return false;
		} 
	}
	
	if(date1 > date2){
		alert("開始日 ＞ 終了日となっています。");
		$('#input_form_終了日').focus();
		return false;
	}
	
	var lspass = $('#input_form_パスワード').val();
	if(chkLength(lspass, 16) == 1){
		alert("パスワードがながすぎます");
		$('#input_form_パスワード').focus();
		return false;
	}
	
	var lsitem1 = $('#input_form_ログインユーザー').val();
	if(chkLength(lsitem1, 32) == 1){
		alert("ログインユーザーがながすぎます");
		$('#input_form_ログインユーザー').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_Tantomasuta(){
  var lscode = $('#input_form_担当者コード').val();
  if(byteLength(lscode) < 1){
  	alert("担当者コードが必要です。");
  	$('#input_form_担当者コード').focus();
  	return 1;
  }
  
  var lsname = $('#input_form_担当者名称').val();
  if(byteLength(lsname) < 1){
  	alert("担当者名称がなが必要です。");
  	$('#input_form_担当者名称').focus();
  	return 1;
  }
 
  var lsdate1 = $('#input_form_開始日').val();
  if(byteLength(lsdate1) < 1){
  	alert("開始日がなが必要です。");
  	$('#input_form_開始日').focus();
  	return 1;
  }
   
  var lsdate2 = $('#input_form_終了日').val();
  if(byteLength(lsdate2) < 1){
  	alert("終了日がなが必要です。");
  	$('#input_form_終了日').focus();
  	return 1;
  }
 
  var lspass = $('#input_form_パスワード').val();
  if(byteLength(lspass) < 1){
  	alert("パスワードがなが必要です。");
  	$('#input_form_パスワード').focus();
  	return 1;
  }
  
  var lsgroupcode = $('#input_form_担当グループコード').val();
  if(byteLength(lsgroupcode) < 1){
  	alert("担当グループコードがなが必要です。");
  	$('#input_form_担当グループコード').focus();
  	return 1;
  } 
  return 0;
}
