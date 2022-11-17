  //================================================================
  //   名　称    Login
  //   説　明    アクションを抑制しまた。
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.08.29  1.00.00     quandv118@gmail.com       新規作成
  //=================================================================
function chkMain_login(){
	if(chkMainRequire_login() == 1){
		return false;
	}
	
	var tantocode = $('#tantocode').val();  
	if(chkLength(tantocode, 10) == 1){
		alert("担当者コードがながすぎます");
		$('#tantocode').focus();
		return false;
	}
	
	var tantoName = $('#password').val();
	if(chkLength(tantoName, 16) == 1){
		alert("パスワードがながすぎます");
		$('#password').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_login(){
  var tantocode = $('#tantocode').val();
  if(byteLength(tantocode) < 1){
  	alert("担当者コードを入力して下さい。");
  	$('#tantocode').focus();
  	return 1;
  }
  
  var tantoName = $('#password').val();
  if(byteLength(tantoName) < 1){
  	alert("パスワードを入力して下さい。");
  	$('#password').focus();
  	return 1;
  }
  
  return 0;
}

function go_changepassword(){
	var tantocode = $('#tantocode').val();
	var link = $('#gochangepassword');
	link.click();
	if(tantocode.length > 0){
		window.open(link.attr("href") + "?id=" + tantocode);
	}
	else{
		window.open(link.attr("href"));
	}
}

function chkMain_login_edit(){
	if(chkMainRequire_login_edit() == 1){
		return false;
	}
	
	var tantocode = $('#tantocode').val();  
	if(chkLength(tantocode, 10) == 1){
		alert("担当者コードがながすぎます");
		$('#tantocode').focus();
		return false;
	}
	
	var password = $('#password').val();
	if(chkLength(password, 16) == 1){
		alert("パスワードがながすぎます");
		$('#password').focus();
		return false;
	}

	var newpassword = $('#newpassword').val();
	if(chkLength(newpassword, 16) == 1){
		alert("新パスワードがながすぎます");
		$('#newpassword').focus();
		return false;
	}

	var newpasswordconfirm = $('#newpasswordconfirm').val();
	if(chkLength(newpasswordconfirm, 16) == 1){
		alert("新パスワードの確認がながすぎます");
		$('#newpasswordconfirm').focus();
		return false;
	}

	if(newpassword != newpasswordconfirm){
		alert("新パスワードと確認入力が一致していません");
		$('#newpassword').focus();
		return false;
	}
	
	return true;
}

function chkMainRequire_login_edit(){
  var tantocode = $('#tantocode').val();
  if(byteLength(tantocode) < 1){
  	alert("担当者コードを入力して下さい。");
  	$('#tantocode').focus();
  	return 1;
  }
  
  var password = $('#password').val();
  if(byteLength(password) < 1){
  	alert("パスワードを入力して下さい。");
  	$('#password').focus();
  	return 1;
  }

  var newpassword = $('#newpassword').val();
  if(byteLength(newpassword) < 1){
  	alert("新パスワードを入力して下さい。");
  	$('#newpassword').focus();
  	return 1;
  }
  
  var newpasswordconfirm = $('#newpasswordconfirm').val();
  if(byteLength(newpasswordconfirm) < 1){
  	alert("新パスワードの確認を入力して下さい。");
  	$('#newpasswordconfirm').focus();
  	return 1;
  } 
  return 0;
}