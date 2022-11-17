  //================================================================
  //   名　称    referentGamen.js
  //   説　明    
  //   補　足
  //   引　数 なし
  //   戻　値
  // (history)
  //   date         ver        name                      comments
  //  -------     -----      ----------------          -----------------
  //  2012.10.24  1.00.00     dinhlong.org@gmail.com       新規作成
  //=================================================================
var referentWindow;
function referentGamen(url,width,height) {
    popupGamen(url,width,height,"menuWindow");
}
function popupGamen(url,width,height,menuWindowName) {
    var left = parseInt((screen.availWidth/2) - (width/2));
    var top = parseInt((screen.availHeight/2) - (height/2));
    var windowFeatures = "width=" + width + ",height=" + height + ",scrollbars=1,status,resizable,left=" + left + ",top=" + top + "screenX=" + left + ",screenY=" + top;
    referentWindow = window.open(url, menuWindowName, windowFeatures);
	referentWindow.focus();
}