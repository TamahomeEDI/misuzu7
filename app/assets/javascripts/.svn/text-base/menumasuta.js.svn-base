  //================================================================
  //   名　称    Login
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.09.04  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
  function menumasutachange(obj,tantogroupcode){  	
  	// $('#rightframe').attr("src","menu/list?id=00002");
  	// $('#rightframe').contents().find('#1412').toggle();
  	menuid = $(obj).attr('id')
  	// clear all item in screen
  	$('#menuright1_ajax').html("<h2>データを積載しています。</h2>");
  	$('#menuright2_ajax').html("<h2>データを積載しています。</h2>");
  	if(menuid != null){
  		// change menumasuta screen
  		// alert(menuid)
  		jQuery.ajax({
			url: "/menumasuta/update_screen1",
			type: "GET",
			data: {"ajax_menu_code" : menuid, "ajax_tantogroup_code" : tantogroupcode},
			dataType: "html",
			success: function(data) {
				jQuery("#menuright1_ajax").html(data);
			}
		});
		
		// change gamen screen

  		jQuery.ajax({
			url: "/menumasuta/update_screen2",
			type: "GET",
			data: {"ajax_menu_code" : menuid, "ajax_tantogroup_code" : tantogroupcode},
			dataType: "html",
			success: function(data) {
				jQuery("#menuright2_ajax").html(data);
			}
		});
  	}
  	
  	  	// change button
  	$('.selected').attr('class', 'notselected');
  	$('#select_' + menuid).attr('class', 'selected');
  }
  
// Valid data
function chkMain_Menumasuta1(){
	if(chkMainRequire_Menumasuta1() == 1){
		return false;
	}
	
	var lscode = $('#input_form_表示順序').val();  
	if(chkLength(lscode, 6) == 1){
		alert("表示順序がながすぎます");
		$('#input_form_表示順序').focus();
		return false;
	}
	
	//valid number
	if(!isNumber(lscode)){
		alert("表示順序に誤りがあります。");
		$('#input_form_表示順序').focus();
		return false;		
	}

	// check valid range
	floatValue = parseFloat(lscode);
	if(floatValue > 999.99){
		alert("表示順序に誤りがあります。");
		$('#input_form_表示順序').focus();
		return false;
	}
	
	var lsname = $('#input_form_メニュー名称').val();
	if(chkLength(lsname, 20) == 1){
		alert("メニュー名称がすぎます");
		$('#input_form_メニュー名称').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_Menumasuta1(){
  var lscode = $('#input_form_表示順序').val();
  if(byteLength(lscode) < 1){
  	alert("表示順序が必要です。");
  	$('#input_form_表示順序').focus();
  	return 1;
  }
  
  var lsname = $('#input_form_メニュー名称').val();
  if(byteLength(lsname) < 1){
  	alert("メニュー名称が必要です。");
  	$('#input_form_メニュー名称').focus();
  	return 1;
  }
  
  return 0;
}

function chkMain_Menumasuta2(){
	if(chkMainRequire_Menumasuta2() == 1){
		return false;
	}
	
	var lscode = $('#input_form_表示順序').val();  
	if(chkLength(lscode, 6) == 1){
		alert("表示順序がながすぎます");
		$('#input_form_表示順序').focus();
		return false;
	}
	
	//valid number
	if(!isNumber(lscode)){
		alert("表示順序に誤りがあります。");
		$('#input_form_表示順序').focus();
		return false;		
	}

	// check valid range
	floatValue = parseFloat(lscode);
	if(floatValue > 999.99){
		alert("表示順序に誤りがあります。");
		$('#input_form_表示順序').focus();
		return false;
	}
	
	var lsname = $('#input_form_ボタン名称').val();
	if(chkLength(lsname, 30) == 1){
		alert("ボタン名称がすぎます");
		$('#input_form_ボタン名称').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_Menumasuta2(){
  var lscode = $('#input_form_表示順序').val();
  if(byteLength(lscode) < 1){
  	alert("表示順序が必要です。");
  	$('#input_form_表示順序').focus();
  	return 1;
  }
  
  var lsname = $('#input_form_画面プログラム').val();
  if(byteLength(lsname) < 1){
  	alert("画面プログラムが必要です。");
  	$('#input_form_画面プログラム').focus();
  	return 1;
  }
  
  return 0;
}

function chkHeader_Menumasuta(){
	var lsname = $('#tantogroupcode').val();
	if(byteLength(lsname) < 1){
	  alert("担当グループが必要です。");
	  $('#tantogroupcode').focus();
	  return false;
	}
	
	return true;
}
