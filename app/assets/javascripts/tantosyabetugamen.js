  //================================================================
  //   名　称    tantosyabetugamen
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.09.05  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
  
function update_gamen_list(code_id) {
	// alert(code_id);
  jQuery.ajax({
    url: "/tantosyabetugamenmasuta/update_gamen",
    type: "GET",
    data: {"tanto_id" : code_id},
    dataType: "html",
    success: function(data) {
      jQuery("#gamenupdate").html(data);
    }
  });
}


function chkMain_Tantosyabetugamen(){
	if(chkMainRequire_Tantosyabetugamen() == 1){
		return false;
	}
	
	var lscode = $('#input_form_担当者コード').val();  
	if(chkLength(lscode, 10) == 1){
		alert("担当者コーがながすぎます");
		$('#input_form_担当者コー').focus();
		return false;
	}
	
	var lsname = $('#input_form_画面プログラム').val();
	if(chkLength(lsname, 20) == 1){
		alert("画面プログラムがながすぎます");
		$('#input_form_画面プログラム').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_Tantosyabetugamen(){
  var lscode = $('#input_form_担当者コード').val();
  if(byteLength(lscode) < 1){
  	alert("担当者コードが必要です。");
  	$('#input_form_担当者コード').focus();
  	return 1;
  }
  
  var lsname = $('#input_form_画面プログラム').val();
  if(byteLength(lsname) < 1){
  	alert("画面プログラムがなが必要です。");
  	$('#input_form_画面プログラム').focus();
  	return 1;
  }
  
  return 0;
}