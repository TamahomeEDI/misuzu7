  //================================================================
  //   名　称    pw_sosikigrid.js
  //   説　明    
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.10.25  1.00.00     dinhlong.org@gmail.com       新規作成
  //=================================================================
function setReferentValue(SOSEKICODE_CONTROLVALUE,SOSEKINAME_CONTROLVALUE)
{
    var SOSEKICODE_CONTROLID=$("#hidSOSEKICODE_CONTROLID").val();
	var SOSEKINAME_CONTROLID=$("#hidSOSEKINAME_CONTROLID").val();
    window.opener.document.getElementById(SOSEKICODE_CONTROLID).value=SOSEKICODE_CONTROLVALUE;
    window.opener.document.getElementById(SOSEKINAME_CONTROLID).innerHTML =SOSEKINAME_CONTROLVALUE;
    window.close();

}
var arrSosikimeisyo = new Array();
var arrSearchoption = new Array();
var arrKobasosiki = new Array();
var arrSosikisyubetu = new Array();
var kensakuIndex=-1;
var message='該当データがありません。';
var sosikimeisyo;
var searchoption;
var kobasosiki;
var sosikisyubetu;
var JIGYOUKI_VALUE;
$(document).ready(function(){
	
	var curRow=-1;
	function setcurrent_row(rowIndex)
	{
		curRow = rowIndex-1;
	};
	function setcolor(){
		var lengthrow=$('#pw_sosiki tbody tr').length;
		for (i=0;i<lengthrow;i++)
  		{
  			if((i%2)==0) $('#pw_sosiki tbody tr').eq(i).css('background-color', '#FFFFFF');
  			else $('#pw_sosiki tbody tr').eq(i).css('background-color', '#E9F1F4');
  		}
		$('#pw_sosiki tbody tr').eq(curRow).css('background-color', '#FFFF00');	
	};
	
	$("#pw_sosiki tbody tr").live('click', function() {
		
		setcurrent_row($(this)[0].rowIndex);
		
		//set selecting row color
		setcolor();
		
	});
	
	///////////////////////FORM///////////////////////////
	function getKensakujyouken()
	 {
		sosikimeisyo=$('#sosikimeisyo').val();
		searchoption=$('#searchoption').val();
		kobasosiki=$('#kobasosiki').val();
		sosikisyubetu=$('#sosikisyubetu').val();
		JIGYOUKI_VALUE=$('#JIGYOUKI_VALUE').val();
	};
	
	function setkensakujyouken4array(arrIndex)
	{
		//save kensakujyouken
		kensakuIndex=arrIndex;
		arrSosikimeisyo[kensakuIndex] = sosikimeisyo;
		arrSearchoption[kensakuIndex] = searchoption;
		arrKobasosiki[kensakuIndex] = kobasosiki;
		arrSosikisyubetu[kensakuIndex] = sosikisyubetu;
	 };
	 
	 function disablecontrol()
	 {
	 	//disabled control search
		//disabled control search
		$('#sosikimeisyo').attr('disabled','disabled');
		$('#searchoption').attr('disabled','disabled');
		$('#kobasosiki').attr('disabled','disabled');
		$('#sosikisyubetu').attr('disabled','disabled');
		$('#searchForm').attr('disabled','disabled');
	 };
	 
	 function undisablecontrol()
	 {
	 	//undisabled control search
		$('#sosikimeisyo').removeAttr('disabled');
		$('#searchoption').removeAttr('disabled');
		$('#kobasosiki').removeAttr('disabled');
		$('#sosikisyubetu').removeAttr('disabled');
		$('#searchForm').removeAttr('disabled');
		$('#pw_sosiki tbody tr').html('');
	 };
	 
	 function setvalue4cancel()
	 {
	 	$('#sosikimeisyo').attr('value',arrSosikimeisyo[kensakuIndex]);
		$("#searchoption").val( arrSearchoption[kensakuIndex] ).attr('selected',true);
		$("#kobasosiki").val( arrKobasosiki[kensakuIndex] ).attr('selected',true);
		$("#sosikisyubetu").val( arrSosikisyubetu[kensakuIndex] ).attr('selected',true);
		$('#sosikimeisyo').focus();
		$('#btnOK').attr('disabled','disabled');
		kensakuIndex=kensakuIndex-1;
		if(kensakuIndex==-1) kensakuIndex=0;
	 };
	 
	 //
	 getKensakujyouken();
	 //
	 setkensakujyouken4array(0);
	 
     $("#searchForm").click(function() {
		
		//
		getKensakujyouken();
		var Flag=1;
		
		setkensakujyouken4array(1);
		
		//
		disablecontrol();
		
		$('.message').html('loading...........');
		jQuery.ajax({
		url: "/pw_sosiki",
		type: "GET",
		data: {"sosikimeisyo" : sosikimeisyo,"searchoption" : searchoption,"kobasosiki" : kobasosiki,"sosikisyubetu" : sosikisyubetu,"JIGYOUKI_VALUE" : JIGYOUKI_VALUE,"Flag" : Flag},
		dataType: "html",
		success: function(data) {
			$('.message').html('');
			jQuery("#pw_sosiki").html(data);
			var lengthRows=$('#pw_sosiki tbody tr').length;
			if(lengthRows==0) alert(message);
			else $('#btnOK').removeAttr('disabled');
		}
		});
	
	});
	
	$("#btnCancel").click(function() {
		
		//
		undisablecontrol();
		
		//set value
		setvalue4cancel();
		
	});
	
	
	$("#btnOK").click(function() {
		
		var SOSEKICODE_CONTROLVALUE=$('#pw_sosiki tbody tr').eq(curRow).find("td:eq(0) label").html();
		var SOSEKINAME_CONTROLVALUE=$('#pw_sosiki tbody tr').eq(curRow).find("td:eq(1) label").html();
		setReferentValue(SOSEKICODE_CONTROLVALUE,SOSEKINAME_CONTROLVALUE);
	});
	
	$("#btnClose").click(function() {
		window.close();
	});
	 
});
