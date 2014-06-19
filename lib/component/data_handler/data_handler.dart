library gdgregistration.component.approuter;

import 'dart:html';

import 'package:angular/angular.dart';

@Component(selector: 'data-handler', template: '<!-- data handler ready -->', useShadowDom: false, publishAs: 'cmp')
class DataHandlerComponent implements AttachAware {

  Router router;

  DataHandlerComponent(Router this.router);

  void attach() {
    /*router.onRouteStart.listen((RouteStartEvent e) {

    });*/
    
    document.onKeyDown.listen(this._handleKonami);
  }
  
  /// Entered by the user conami code.
  List<int> konami = [];
  /// Konami code real sequence
  static const List<int> konamiSequence = const [38,38,40,40,37,39,37,39,66,65];
  
  ///Run action when Konami code has been entered.
  void _handleKonami(KeyboardEvent e){
    //left-37
    //up-38
    //right-39
    //bottom-40
    //b-66
    //a-35
    //sequence: up,up,down,down,left,right,left,right,B,A
    
    if(konami.length == 0 && e.keyCode != konamiSequence[0]) return;
    
    try{
      if(e.keyCode == konamiSequence[konami.length]){
        konami.add(e.keyCode);
        if(konami.length == konamiSequence.length){
          konami.clear();
          router.gotoUrl('/setup');
        }
      } else {
        konami.clear();
      }
    } catch(e){
      konami.clear();
    }
  }
}
