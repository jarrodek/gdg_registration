library gdgregistration;

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:logging/logging.dart';

import 'package:gdg_registration/service/data_service.dart';
import 'package:gdg_registration/service/storage.dart';
import 'package:gdg_registration/router/router.dart';
import 'package:gdg_registration/registration_controller.dart';
import 'package:gdg_registration/component/data_handler/data_handler.dart';
import 'package:gdg_registration/component/setup/setup.dart';
import 'package:gdg_registration/component/setup/spreadsheet.dart';
import 'package:gdg_registration/component/setup/worksheet.dart';
import 'package:gdg_registration/component/setup/columns.dart';
import 'package:gdg_registration/component/registration/registration.dart';


void main() {
  Logger.root
      ..level = Level.FINEST
      ..onRecord.listen((LogRecord r) {
        print(r.message);
        window.console.info(r.stackTrace.toString());
      });
  var registrationModule = new Module()
    
    //routers
    ..bind(RouteInitializerFn, toValue: registrationAppRouteInitializer)
    ..bind(NgRoutingUsePushState, toFactory: (_) => new NgRoutingUsePushState.value(false))
    
    //Controllers
    ..bind(RegistrationController)
    
    //Services
    ..bind(DataService)
    ..bind(StorageService)
    
    //Components
    ..bind(DataHandlerComponent)
    ..bind(SetupComponent)
    ..bind(AddSpreadsheetComponent)
    ..bind(SelectWorksheetComponent)
    ..bind(RegistrationComponent)
    ..bind(MapColumnsComponent);
  
  applicationFactory().addModule(registrationModule).run();
}
//TEST SHEET: https://docs.google.com/spreadsheets/d/10VCuRwyN6pCE0gOXKasarh5H8-8dyEIv-O9wC8UUwjc/pubhtml

//list worksheets: https://spreadsheets.google.com/feeds/worksheets/1MZKtK9Ohq50V17ROEW_VcmCfmhRgmPR_81Tvq6G3Exw/public/basic?alt=json


//Query spreadsheet
//https://spreadsheets.google.com/feeds/list/1MZKtK9Ohq50V17ROEW_VcmCfmhRgmPR_81Tvq6G3Exw/od6/public/full?alt=json&sq=confirmation%3D123