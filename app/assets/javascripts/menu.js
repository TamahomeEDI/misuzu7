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
  function menuchange(obj){  	
  	// $('#rightframe').attr("src","menu/list?id=00002");
  	// $('#rightframe').contents().find('#1412').toggle();
  	$('.divgamen').attr('style', 'display:none');
  	value = $(obj).attr('id')
  	if(value != null){
  		$('#gamen_' + value).attr('style', 'display:block');
  	}
  	
  	// change button
  	$('.selected').attr('class', 'notselected');
  	$('#select_' + value).attr('class', 'selected');
  }
  
  function showhidenode(obj){
  	value = $(obj).attr('id');
  	stringId = value.split('_');
  	id = ""
  	if(stringId.length > 1){
  		id = stringId[1];
  	}

  	$('#ul_' + id).toggle();
  	
  	// sign = $(obj).html;
  	if($('#ul_' + id + ':visible').length > 0){
  		$(obj).html('--');
  	}else{
  		$(obj).html('+');
  	}
  }

function expandallselect(){
	if($('#ul_00') != null){$('#ul_00').attr('style','display:block');}
	if($('#ul_') != null){$('#ul_').attr('style','display:block');}
	$('.listmenuleft').attr('style','display:block');
	$('.showhidebutton').html('--');
}
