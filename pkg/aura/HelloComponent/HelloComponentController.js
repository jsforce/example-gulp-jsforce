({
  init: function() {
    var s = document.createElement('script');
    s.src = '/resource/HelloComponentJavaScript?' + Date.now();
    document.getElementsByTagName('head')[0].appendChild(s);
  },
  sumUp: function() {
    stomitaAuraDev.sumUp.apply(stomitaAuraDev, arguments);
  }
})