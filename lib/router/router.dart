library gdgregistration.router.approuter;

import 'package:angular/angular.dart';

void registrationAppRouteInitializer(Router router, RouteViewFactory views) {
  
  views.configure({
    'start': ngRoute(path: '/start', defaultRoute: true, view: 'view/start.html'), //start screen 
    'register': ngRoute(path: '/register', view: 'view/register.html'), //register to the event screen
    'setup': ngRoute(path: '/setup', view: 'view/setup.html') //setup the app
  });
}