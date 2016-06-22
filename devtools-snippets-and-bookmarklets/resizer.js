;(function (w, d) {
  var data = [
    {
      tab: 'Desktop',
      modes: false,
      resolutions: [
        {desc: '30 inch',    x: 2560, y: 1600},
        {desc: '23-28 inch', x: 1920, y: 1280},
        {desc: '20-22 inch', x: 1680, y: 1050},
        {desc: '17-19 inch', x: 1280, y: 1024},
        {desc: '17 inch',    x: 1024, y: 768},
        {desc: '15 inch',    x: 800,  y: 600}
      ]
    }, {
      tab: 'Laptop',
      modes: false,
      resolutions: [
        {desc: '15-17 inch', x: 1920, y: 1200},
        {desc: '14-16 inch', x: 1600, y: 1200},
        {desc: '13-15 inch', x: 1440, y: 900},
        {desc: '12-15 inch', x: 1280, y: 800}
      ]
    }, {
      tab: 'Tablet',
      modes: true,
      resolutions: [
        {desc: 'iPad',                 x: 768, y: 1024},
        {desc: 'Android: extra large', x: 800, y: 1280},
        {desc: 'Android: large',       x: 600, y: 1024},
        {desc: 'Android: average',     x: 600, y: 800},
        {desc: 'Android: small',       x: 480, y: 800}
      ]
    }, {
      tab: 'Phone',
      modes: true,
      resolutions: [
        {desc: 'iPhone 4',         x: 640, y: 960},
        {desc: 'iPhone 1-3',       x: 320, y: 480},
        {desc: 'Android: large',   x: 540, y: 960},
        {desc: 'Android: average', x: 480, y: 800},
        {desc: 'Android: small',   x: 240, y: 320}
      ]
    }
  ]

  // Tab html function
  var fillTabHtml = function (tabIndex) {
    var html = ''
    for (var i = 0; i < data[tabIndex].resolutions.length; i++) {
      var res = data[tabIndex].resolutions[i]
      html += '<li><a href="javascript:bm_resizer_resize(' + res.x + ',' + res.y + ');"><span>' + res.x + ' &times; ' + res.y + '</span><span>' + res.desc + '</span></a></li>'; // space after colon and semicolon!
    }
    return html
  }

  // Build html
  var html = '<div class="bm_resizer_overlay" onclick="javascript:bm_resizer_close();"></div><div class="bm_resizer_content">'
  html += '<a id="bm_resizer_link_cancel" href="javascript:bm_resizer_close();" title="Close this dialog">&times;</a><h1>Resize browser window</h1><ol id="bm_resizer_tabs">'
  for (var i = 0; i < data.length; i++) {
    html += '<li' + (!i ? ' class="active"' : '') + '><a href="javascript:bm_resizer_activatetab(' + i + ');">' + data[i].tab + '</a></li>'
  }
  html += '</ol><ol id="bm_resizer_tabcontents">' + fillTabHtml(0) + '</ol>'
  html += '<div id="bm_resizer_modes"><label><input id="bm_resizer_mode_portrait" type="radio" name="bm_resizer_mode" value="portrait" checked/> Portrait</label>' +
    '<label><input id="bm_resizer_mode_landscape" type="radio" name="bm_resizer_mode" value="landscape"/> Landscape</label></div>'
  html += "<p>It's currently impossible to resize a top level window, so the links open a popup.</p>"; // space after colon!
  html += '<p class="last-child">JS by <a href="http://bran.name/" target="_blank">Bran</a>, resolutions by <a href="http://aukjepoppe.nl/" target="_blank">Aukje Poppe</a></p></div></div>'; // space after colon!

  // Add styles
  var styles = '<style>' +
    '#bm_resizer{font:11px/12px Arial,sans-serif;text-align:left}' +
    '#bm_resizer *{margin:0;border:0;padding:0}' +
    '#bm_resizer .bm_resizer_overlay{position:fixed;top:0;left:0;right:0;bottom:0;z-index:2147483646;background:#000;opacity:.5;-ms-filter:"progid:DXImageTransform.Microsoft.Alpha(Opacity=50)";filter:alpha(opacity=50)}' +
    '#bm_resizer .bm_resizer_content{position:fixed;top:20px;left:50%;width:200px;margin-left:-100px;padding:4px 5px;z-index:2147483647;background:#fff;-webkit-border-radius:6px;-moz-border-radius:6px;border-radius:6px}' +
    '#bm_resizer #bm_resizer_link_cancel{float:right;text-decoration:none;line-height:15px;font-size:19px;font-weight:bold;color:#666}' +
    '#bm_resizer #bm_resizer_link_cancel:hover{color:dodgerblue}' +
    '#bm_resizer h1{margin:0 0 4px;border:0;padding:0;font:bold 14px/14px Arial,sans-serif;color:#666;background:none}' +
    '#bm_resizer a{color:dodgerblue;text-decoration:none;font:11px/12px Arial,sans-serif}' +
    '#bm_resizer a:hover, #bm_resizer a:hover span{color:cornflowerblue;text-decoration:underline}' +
    '#bm_resizer p, #bm_resizer ol{margin:0 0 7px;padding:0;color:#666;font:11px/12px Arial,sans-serif}' +
    '#bm_resizer ol{margin:0;padding:3px 4px 0}' +
    '#bm_resizer li{background:none}' +
    '#bm_resizer #bm_resizer_tabs{border-top:0;padding-bottom:0}' +
    '#bm_resizer #bm_resizer_tabs li{display:inline-block;margin-right:5px;padding:2px 4px 0}' +
    '#bm_resizer #bm_resizer_tabs li.active{border-width:1px 1px 0;border-style:solid;border-color:#ccc}' +
    '#bm_resizer #bm_resizer_tabcontents{margin:0 0 7px;border:1px solid #ccc;font-size:0}' +
    '#bm_resizer #bm_resizer_tabcontents :last-child{margin-bottom:0}' +
    '#bm_resizer #bm_resizer_tabcontents a span{display:inline-block;width:70px;font-size:11px}' +
    '#bm_resizer #bm_resizer_tabcontents a span + span{width:115px;font-size:11px}' +
    '#bm_resizer #bm_resizer_modes{display:none;margin-bottom:7px}' +
    '#bm_resizer #bm_resizer_modes label{margin-right:10px;color:#666;cursor:pointer}' +
    '#bm_resizer p.last-child{margin:0}' +
    '#bm_resizer li{list-style:none;margin:0 0 2px;padding:0}' +
    '</style>'
  html += styles

  // Append html to body
  var bm_resizer = d.createElement('div')
  bm_resizer.id = 'bm_resizer'
  bm_resizer.innerHTML = html
  d.body.appendChild(bm_resizer)

  // Activate tab
  w.bm_resizer_activatetab = function (tabIndex) {
    d.getElementById('bm_resizer_tabcontents').innerHTML = fillTabHtml(tabIndex)
    var tabs = d.getElementById('bm_resizer_tabs').children
    for (var i = 0; i < tabs.length; i++) {
      tabs[i].className = ''
    }
    tabs[tabIndex].className = 'active'
    if (data[tabIndex].modes) {
      d.getElementById('bm_resizer_modes').style.display = 'block'
    } else {
      d.getElementById('bm_resizer_modes').style.display = 'none'
      d.getElementById('bm_resizer_mode_portrait').checked = true
    }
  }

  // Resize links
  w.bm_resizer_resize = function (x, y) {
    if (d.getElementById('bm_resizer_mode_landscape').checked) {
      x = x ^ y; y = x ^ y; x = x ^ y
    }
    var popup = w.open(w.location, d.title, 'width=' + x + ',height=' + y)
  }

  // Close resizer
  w.bm_resizer_close = function () {
    d.body.removeChild(d.getElementById('bm_resizer'))
  }
}(window, document))
