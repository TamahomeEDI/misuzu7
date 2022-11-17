  //================================================================
  //   名　称    tantogroupmasuta
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.09.05  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
  
function chkMain_Tantogroupmasuta(){
	if(chkMainRequire_Tantogroupmasuta() == 1){
		return false;
	}
	
	var lscode = $('#input_form_担当グループコード').val();  
	if(chkLength(lscode, 4) == 1){
		alert("担当グループコードがながすぎます");
		$('#input_form_担当グループコード').focus();
		return false;
	}
	
	var lsname = $('#input_form_担当グループ名称').val();
	if(chkLength(lsname, 20) == 1){
		alert("担当グループ名称がながすぎます");
		$('#input_form_担当グループ名称').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_Tantogroupmasuta(){
  var lscode = $('#input_form_担当グループコード').val();
  if(byteLength(lscode) < 1){
  	alert("担当グループコードが必要です。");
  	$('#input_form_担当グループコード').focus();
  	return 1;
  }
  
  var lsname = $('#input_form_担当グループ名称').val();
  if(byteLength(lsname) < 1){
  	alert("担当グループ名称がなが必要です。");
  	$('#input_form_担当グループ名称').focus();
  	return 1;
  }
  
  return 0;
}
