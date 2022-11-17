  //================================================================
  //   名　称    SeisankankatukoujoumasutaController
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.08.27  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
function chkMain_Seisankankatukoujoumasuta(){
	if(chkMainRequire() == 1){
		return false;
	}
	
	var kojoCode = $('#input_form_生産管轄工場コード').val();  
	if(chkLength(kojoCode, 3) == 1){
		alert("生産管轄工場コードがながすぎます");
		$('#input_form_生産管轄工場コード').focus();
		return false;
	}
	
	var kojoName = $('#input_form_生産管轄工場名称').val();
	if(chkLength(kojoName, 20) == 1){
		alert("工場名称がながすぎます");
		$('#input_form_生産管轄工場名称').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire(){
  var kojoCode = $('#input_form_生産管轄工場コード').val();
  if(byteLength(kojoCode) < 1){
  	alert("生産管轄工場コードが必要です。");
  	$('#input_form_生産管轄工場コード').focus();
  	return 1;
  }
  
  var kojoName = $('#input_form_生産管轄工場名称').val();
  if(byteLength(kojoName) < 1){
  	alert("工場名称が必要です。");
  	$('#input_form_生産管轄工場名称').focus();
  	return 1;
  }
  
  return 0;
}
