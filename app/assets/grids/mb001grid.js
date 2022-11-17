  //================================================================
  //   名　称    mb001grid.js
  //   説　明    
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.10.24  1.00.00     dinhlong.org@gmail.com       新規作成
  //=================================================================
function genColumsID()
{
	var currentTime = new Date();
	var year = currentTime.getFullYear().toString();
	var month = (currentTime.getMonth()+1).toString();
	var day = currentTime.getDate().toString();
	var hours = currentTime.getHours().toString();
	var minutes = currentTime.getMinutes().toString();
	var seconds = currentTime.getSeconds().toString();
	var returnDate=year+month+day+hours+minutes+seconds;

	return returnDate;
}
	
function ReferentGamen(SOSEKICODE,SOSEKINAME)
{
	var JIGYOUKI=$("#jigyodate").val();
	var url="/pw_sosiki?SOSEKICODE_CONTROLID="+ SOSEKICODE +"&SOSEKINAME_CONTROLID="+ SOSEKINAME +"&JIGYOUKI_VALUE="+ JIGYOUKI;
    var width=1000;
    var height=600;
    popupGamen(url,width,height,"mb001Window");
}
 

var 担当者コード=1;
var 担当者名称=2;
var パスワード=3;
var 組織コード=4;
var 組織名称=5;
var ログインユーザー=6;
var 開始日=2;
var 終了日=3;
var パスワード更新日=4;
var 社員区分=5;
var 担当グループ=6;
var フォーカス＿メニュー=7;
var arrTantogroupcode = new Array();
var arrSosikicode = new Array();
var arrSosikiname = new Array();
var arrJigyodate = new Array();
var arrTantocode = new Array();
var arrTantoname = new Array();
var arrSearchoption = new Array();
var arrKijundate = new Array();
var kensakuIndex=-1;
var message1='該当データがありません。';
var message2='引き続き入力するならば < はい > を、';
var message3='検索に戻るならば < いいえ > を選択して下さい。';
var tantogroupcode;
var SOSIKICODE;
var SOSIKINAME;
var jigyodate;
var tantocode;
var tantoname;
var searchoption;
var kijundate;
$(document).ready(function(){
	
	var cssName=""
	var deleteCode="";
	var curRow=-1;
	function setcolor(){
		$('#TANTOMASUTA tbody tr').css('background-color', '#FFFFFF');
		$('#TANTOMASUTA tbody tr').eq(curRow-2).css('background-color', '#FFFF00');
		$('#TANTOMASUTA tbody tr').eq(curRow-1).css('background-color', '#FFFF00');	
	};
	
	function setcurrent_row(rowIndex,className)
	{
		curRow = rowIndex;
		cssName = className;
		if(cssName=='cssTwo') 
		{
			curRow=curRow-1;
			cssName='cssOne';
		}
	};
	
	function setflag()
	{
		var flag=$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq(0) input").val();
		if(flag!='ADDNEW') $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq(0) input").attr('value','UPDATE');
	};
	
	$("#TANTOMASUTA tbody tr").live('click', function() {
		
		setcurrent_row($(this)[0].rowIndex,$(this)[0].className);
		
		//set selecting row color
		setcolor();
		
		//check for update
		setflag();
		
	});
	
	function addrow()
	{
	   //add row one
	   $('#TANTOMASUTA tbody>tr:first').clone(true).insertAfter('#TANTOMASUTA tbody>tr:last');
       $('#TANTOMASUTA tbody>tr:last').attr("id", "txtAddnew");
       $('#TANTOMASUTA tbody>tr:last').attr("class", "cssOne");
	   
	   //add row two
       $('#TANTOMASUTA tbody>tr:eq(1)').clone(true).insertAfter('#TANTOMASUTA tbody>tr:last');
       $('#TANTOMASUTA tbody>tr:last').attr("id", "txtAddnew");
       $('#TANTOMASUTA tbody>tr:last').attr("class", "cssTwo");
	   
	};
	
	function setfocusrow()
	{
		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input").focus();
	};
	
	function setevent_row()
	{
	   
	   //担当コード
	   var Colum1ID="TANTO_UPDATE_"+genColumsID()+curRow;
	    var Colum2ID="KAISIDATE_UPDATE_"+genColumsID()+curRow;
	   var checkTanto="chk_tantocode(this.value,$('#"+ Colum2ID +"').val());";
	   var checkKaisiDate="chk_tantocode($('#"+ Colum1ID +"').val(),this.value);";
	   $('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+開始日+") input[type=text]").attr("id", Colum2ID);
	   $('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+開始日+") input[type=text]").attr('onChange', checkKaisiDate );
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input[type=text]").attr("id", Colum1ID);
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input[type=text]").attr('onChange', checkTanto );
	   
	   //
	   var Colum4ID="SOSEKICODE_UPDATE_"+genColumsID()+curRow;
	   var Colum5ID="SOSEKINAME_UPDATE_"+genColumsID()+curRow;
	   var referentFunction="ReferentGamen('"+ Colum4ID +"','"+ Colum5ID +"');";
	   var onchangeSOSIKICODE="update_sosikiname(this.value,'"+ Colum5ID +"');";
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+組織コード+") input[type=text]").attr("id", Colum4ID);
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+組織コード+") input[type=text]").attr("onchange", onchangeSOSIKICODE);
	   
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+組織名称+") label").attr("id", Colum5ID);
	   $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+組織コード+") input[type=button]").attr('onclick', referentFunction );
	   
	   var Colum7ID="FOCUSMENU_UPDATE_"+genColumsID()+curRow;
	   var changeFunction="update_focus_menu(this.options[this.selectedIndex].value,'"+ Colum7ID +"');";
	   $('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+担当グループ+") select").attr('onChange', changeFunction );
	   $('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+フォーカス＿メニュー+") select").attr("id", Colum7ID);
	};
	
	function add4checkvalidate()
	{
		//check validate
		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input").attr("class","required");
		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者名称+") input").attr("class","required");
		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+パスワード+") input").attr("class","required");
		$('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+開始日+") input").attr("class","required");
		$('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+終了日+") input").attr("class","required");
		$('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+担当グループ+") select").attr("class","requireselectlist");
	};
	
	function insertrow()
    {
    	var templateOne='<tr class="cssOne">'+ $('#hiddenOne').html()+'</tr>';
	    var templateTwo='<tr class="cssTwo">'+ $('#hiddenTwo').html()+'</tr>';
	    $('#TANTOMASUTA tbody tr').eq(curRow-3).after(templateOne+templateTwo);
    };
    
    function copyrow()
   {
   	 	var templateOne='<tr class="cssOne">'+ $('#TANTOMASUTA tbody tr').eq(curRow-2).html()+'</tr>';
	    var templateTwo='<tr class="cssTwo">'+ $('#TANTOMASUTA tbody tr').eq(curRow-1).html()+'</tr>';
		$('#TANTOMASUTA tbody tr').eq(curRow-3).after(templateOne+templateTwo);
		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq(0) input").attr('value','ADDNEW');
   };
  
   function remove_modify()
   {
   		 $('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input").removeAttr("readonly");
   		 $('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+開始日+") input").removeAttr("readonly");
   };
   
   function selectcontrol()
   {
   		$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input").select();
   };
   
   	//Add Rows to table
    $('#addRows').click(function() {
       
       //add new row 
	   addrow();
	    
	   var lengthRows=$('#TANTOMASUTA tbody tr').length;
	   setcurrent_row(lengthRows,'cssOne');
	    
	   setcolor();
	    
	   //set forcus row which selecting
	   setfocusrow();
	   
	   setevent_row();
	   
	   //check valiate when update
	   add4checkvalidate();
	  
	   return false;
	   
    });//End Add Rows
    
    //Insert Rows to table
    $('#insertRows').click(function() {
       if(curRow!=-1)
       {
	       //insert row
	       insertrow();
	       
	       //
	       setcolor();
	       
	       //
	       setfocusrow();
	       
	       //
	       setevent_row();
		   
		   //
		   add4checkvalidate();
		   
	   }
	   
	   return false;
  
    });//End Insert Rows
  
   //copy Rows to table
    $('#copyRows').click(function() {
       if(curRow!=-1)
       {
		   //copy row
		   copyrow();
	      
	      //
	      setcolor();
	      
	      //
	      remove_modify();
	      
	      //
	      selectcontrol();
	      
	  	  //
	  	  setevent_row();
		  
		   
		   //check validate
		   add4checkvalidate();
		}
  		return false;
  	});//End copy Rows
   	
    //Delete Checked Rows
    $('#delRows').click(function() {
         
         if(curRow!=-1)
		 {
			 var countDelete=0;
			 if(cssName=='cssTwo') curRow=curRow-1;
			 var tempRowIndex=curRow;
			 $('#TANTOMASUTA tbody>tr').each(function() {
				 if($(this)[0].rowIndex==curRow){
					 if(countDelete==0)
					 {
						if (!confirm("削除しますか?")) return false;
						var flag=$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq(0) input").val();
						var tantoCode=$('#TANTOMASUTA tbody tr').eq(curRow-2).find("td:eq("+担当者コード+") input").val();
						var kaisiDate=$('#TANTOMASUTA tbody tr').eq(curRow-1).find("td:eq("+開始日+") input").val();
						if((flag=='UPDATE') || (flag=='')) deleteCode=deleteCode + "," + tantoCode + ";" +kaisiDate;
					 }
					 $(this).remove();
					 countDelete+=1;
					 if(countDelete==2) curRow=-1;
				 }
					   
			 });
			 curRow=tempRowIndex;
			 var lengthRows=$('#TANTOMASUTA tbody tr').length;
			 if(lengthRows<curRow) curRow=lengthRows;
			 if(lengthRows<3) curRow=-1;
			 else
			 {
				 setcolor();
				 //setfocusrow();
			 }
		 }
		 return false;
     });//End Delete Checked Rows
     
     
     ///////////////////////FORM///////////////////////////
    function initializeForm()
    {
    	//
    	getKensakujyouken();
    	
    	//
    	//undisable btnUpdate,btnExportCSV button
		var lengthRows=$('#TANTOMASUTA tbody tr').length;
		if(lengthRows>2)
		{
			$('#btnUpdate').removeAttr('disabled');
			$('#btnExportCSV').removeAttr('disabled');
			disable_head_control();
			
			//main
			undisable_main_control();
		}
		else disable_main_control();
    };
    
    function getKensakujyouken()
	 {
		tantogroupcode=$('#tantogroupcode').val();
		SOSIKICODE=$('#FORM_INPUT_SOSEKICODE').val();
		SOSIKINAME=$('#FORM_INPUT_SOSEKINAME').html();
		jigyodate=$('#jigyodate').val();
		tantocode=$('#tantocode').val();
		tantoname=$('#tantoname').val();
		searchoption=$('#searchoption').val();
		kijundate=$('#kijundate').val();
	};
	
	function setkensakujyouken4array(arrIndex)
	{
		var FlagForm=$('#FlagForm').val();
		if(FlagForm=='0')
		{
			kensakuIndex=arrIndex;
			arrTantogroupcode[kensakuIndex] = "";
			arrSosikicode[kensakuIndex] = "";
			arrSosikiname[kensakuIndex] = "";
			var initial_jigyodate=$("#arrJigyodate").val();
			arrJigyodate[kensakuIndex] = initial_jigyodate;
			arrTantocode[kensakuIndex] = "";
			arrTantoname[kensakuIndex] = "";
			arrSearchoption[kensakuIndex] = "";
			var initial_arrKijundate=$("#arrKijundate").val();
			arrKijundate[kensakuIndex] = initial_arrKijundate;
			$('#FlagForm').attr('value','');
			arrIndex=1;
		}
		//save kensakujyouken
		kensakuIndex=arrIndex;
		arrTantogroupcode[kensakuIndex] = tantogroupcode;
		arrSosikicode[kensakuIndex] = SOSIKICODE;
		arrSosikiname[kensakuIndex] = SOSIKINAME;
		arrJigyodate[kensakuIndex] = jigyodate;
		arrTantocode[kensakuIndex] = tantocode;
		arrTantoname[kensakuIndex] = tantoname;
		arrSearchoption[kensakuIndex] = searchoption;
		arrKijundate[kensakuIndex] = kijundate;
	 };
	 
	function disable_head_control()
	 {
	 	//disabled control search
		$('#tantogroupcode').attr('disabled','disabled');
		$('#FORM_INPUT_SOSEKICODE').attr('disabled','disabled');
		$('#tantocode').attr('disabled','disabled');
		$('#tantoname').attr('disabled','disabled');
		$('#searchoption').attr('disabled','disabled');
		$('#kijundate').attr('disabled','disabled');
		$('#searchForm').attr('disabled','disabled');
		$('#FORM_INPUT_REFERENT').css('visibility', 'hidden');
	 };
	 
	function undisable_head_control()
	 {
	 	//undisabled control search
		$('#tantogroupcode').removeAttr('disabled');
		$('#FORM_INPUT_SOSEKICODE').removeAttr('disabled');
		$('#tantocode').removeAttr('disabled');
		$('#tantoname').removeAttr('disabled');
		$('#searchoption').removeAttr('disabled');
		$('#kijundate').removeAttr('disabled');
		$('#searchForm').removeAttr('disabled');
		$('#FORM_INPUT_REFERENT').css('visibility', 'visible');
		$('#TANTOMASUTA tbody tr.cssOne').html('');
		$('#TANTOMASUTA tbody tr.cssTwo').html('');
	 };
	 
	 function disable_main_control()
	 {
	 	//disabled control search
		$('#insertRows').attr('disabled','disabled');
		$('#addRows').attr('disabled','disabled');
		$('#copyRows').attr('disabled','disabled');
		$('#delRows').attr('disabled','disabled');
	 };
	 
	function undisable_main_control()
	 {
	 	//undisabled control search
		$('#insertRows').removeAttr('disabled');
		$('#addRows').removeAttr('disabled');
		$('#copyRows').removeAttr('disabled');
		$('#delRows').removeAttr('disabled');
	 };
	 
	function setvalue4cancel()
	 {
	 	$("#tantogroupcode").val( arrTantogroupcode[kensakuIndex] ).attr('selected',true);
		$("#FORM_INPUT_SOSEKICODE").attr('value',arrSosikicode[kensakuIndex]);
		$("#FORM_INPUT_SOSEKINAME").html(arrSosikiname[kensakuIndex]);
		$("#jigyodate").attr('value',arrJigyodate[kensakuIndex]);
		$('#tantocode').attr('value',arrTantocode[kensakuIndex]);
		$('#tantoname').attr('value',arrTantoname[kensakuIndex]);
		$("#searchoption").val( arrSearchoption[kensakuIndex] ).attr('selected',true);
		$('#kijundate').attr('value',arrKijundate[kensakuIndex] );
		$("#tantogroupcode").focus();
		$('#btnUpdate').attr('disabled','disabled');
		$('#btnExportCSV').attr('disabled','disabled');
		kensakuIndex=kensakuIndex-1;
		if(kensakuIndex==-1) kensakuIndex=0;
	 };
	 
	function saveKensakujyouken4update()
	 {
	 	$('#arrTantogroupcode').attr('value',arrTantogroupcode);
		$('#arrSosikicode').attr('value',arrSosikicode);
		$('#arrSosikiname').attr('value',arrSosikiname);
		$('#arrJigyodate').attr('value',arrJigyodate);
		$('#arrTantocode').attr('value',arrTantocode);
		$('#arrTantoname').attr('value',arrTantoname);
		$('#arrSearchoption').attr('value',arrSearchoption);
		$('#arrKijundate').attr('value',arrKijundate);
		$('#FlagForm').attr('value','0');
	 };
	 
	 //
	 initializeForm();
	 //
	 setkensakujyouken4array(0);
	
     $("#searchForm").click(function() {
		
		//
		getKensakujyouken();
		var Flag=1;
		
		//
		setkensakujyouken4array(1);
		
		//
		saveKensakujyouken4update();
		
		//
		disable_head_control();
		
		$('.message').html('loading...........');
		jQuery.ajax({
		url: "/mb001",
		type: "GET",
		data: {"tantogroupcode" : tantogroupcode,"SOSIKICODE" : SOSIKICODE,"tantocode" : tantocode,"tantoname" : tantoname,"searchoption" : searchoption,"kijundate" : kijundate,"Flag" : Flag},
		dataType: "html",
		success: function(data) {
			$('.message').html('');
			jQuery("#TANTOMASUTA").html(data);
			var lengthRows=$('#TANTOMASUTA tbody tr').length;
			if(lengthRows==2)
			{
				var message=message1+"\r\n" + message2 +"\r\n" + message3;
				if(confirm(message))
				{
					$('#addRows').click();
				}
				
			}
			else
			{
				$('#btnUpdate').removeAttr('disabled');
				$('#btnExportCSV').removeAttr('disabled');
				
				//main
				undisable_main_control();
			}
		}
		});
	
	});
	
	 $("#btnCancel").click(function() {
		
		//head
		undisable_head_control();
		//main
		disable_main_control();
		
		//set value
		setvalue4cancel();
	});
	
	function chk_input_hisu()
	{
		var returnValue=true;
		$("#TANTOMASUTA tbody>tr td input.required").each(function(){
            if($(this).val().trim().length == 0)
            {
               alert($(this).attr('alt')+'が必要です。');
               $(this).focus(); 
               returnValue=false;
               return false;
            }
        });
        
        return returnValue;
  };
	
	function chk_select_hisu()
	{
		var returnValue=true;
		$("#TANTOMASUTA tbody>tr td select.requireselectlist").each(function(){
            if($(this).val().trim().length == 0)
            {
               alert($(this).attr('alt')+'が必要です。');
               $(this).focus(); 
               returnValue=false;
               return false;
            }
        });
        
        return returnValue;
	};
	
	$("#btnUpdate").click(function() {
		
		//-------------------------------------------------------------------------------------------------
		//	更新確認メッセージ
		//-------------------------------------------------------------------------------------------------
		if (!confirm("更新しますか?")) return false;
		var returnValue=true;
		//
		returnValue=chk_input_hisu();
        if(!returnValue) return false;
        
        returnValue=chk_select_hisu();
        if(!returnValue) return false;
		
		//list code delete
		$("#deleteCode").attr('value',deleteCode);
		
		return returnValue;
	});
	
	$("#btnExportCSV").click(function() {
		
		//
		getKensakujyouken();
		window.location.href='/mb001?Flag=0&format=csv&tantogroupcode='+tantogroupcode+'&SOSIKICODE='+SOSIKICODE+'&tantocode='+tantocode+'&tantoname='+tantoname+'&searchoption='+searchoption+'&kijundate='+kijundate;
	});
	
	$("#btnClose").click(function() {
		window.close();
	});
	
});
