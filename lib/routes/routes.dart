import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hitster/pages/game_page.dart';

import '../functions/storage.dart' show checkStorageKey;
import '../pages/home_page.dart';

final GlobalKey<NavigatorState> globalNavigatorStateKey = GlobalKey<NavigatorState>();

// Future<String?> redirectGuardFuncCheck(String input) async {
//   //print('isStorageEmpty: ${isStorageEmpty()}');
//   if (pageInfo.isNotEmpty) return null;
//   final Map<String, dynamic> pageInfoCheck = await checkUser([]);
//   //print('pageInfoCheck: $pageInfoCheck');
//   if (pageInfoCheck.isNotEmpty && !pageInfoCheck.containsKey('error')) {
//     pageInfo=pageInfoCheck;
//     if (input=='/client') return checkStorageKey('client')?null:'/clients';
//     if (input=='/questionnaire') return checkStorageKey('questionnaire')?null:'/marketplace';
//     if (input=='/report') return checkStorageKey('reportInfo')?null:'/clients';
//     return null;
//   }
//   else {
//     logout();
//     return '/login';
//   }
// }
//
// Future<bool> onExit({String? gpath}) async {
//   bool sureLogout = true;
//   //print('canPop: ${globalNavigatorStateKey.currentState?.canPop()}');
//   print('onExit path: $gpath');
//   final String path = getPositionUrl();
//   print('path: $path');
//   if (path.isEmpty || path.contains('/login') || path.contains('/register')) {
//     print('show dialog');
//     sureLogout = await customDialog(
//         routeName: 'logoutAreYouSure',
//         pressOutside: false,
//         padding: const EdgeInsets.all(15),
//         withHistory: true,
//         constraints: const BoxConstraints(maxHeight: 150, maxWidth: 190),
//         widgets: (context, setState, newData) => Flex(
//           direction: Axis.vertical,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('האם אתה בטוח רוצה להתנתק?'),
//             const Expanded(child: SizedBox(height: 10)),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ElevatedButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     style: ElevatedButton.styleFrom(minimumSize: const Size(100,45), maximumSize: const Size(100,45), backgroundColor: const Color(0x00FFFFFF), side: const BorderSide(color: Color(0xffFDB95A))),
//                     child: Text(getWord('${pageInfo['language']}', 'cancel'))
//                 ),
//                 const SizedBox(width: 15),
//                 ElevatedButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     style: ElevatedButton.styleFrom(minimumSize: const Size(100,45), maximumSize: const Size(100,45), backgroundColor: const Color(0xffFDB95A)),
//                     child: Text((checkLanguageRtl()?'כן, התנתק':'yes, logout'))
//                 ),
//               ],
//             )
//           ],
//         )
//     )??false;
//     print('logout: $sureLogout');
//     if (sureLogout) {
//       logout();
//       removeHistory(url: '/login');
//     }
//   }
//   else if ((pageInfo['dialogNames']??[]).isNotEmpty) {
//     //Navigator.pop(globalNavigatorStateKey.currentContext!);
//     return false;
//   }
//   print('sureLogout: $sureLogout');
//
//   return sureLogout;
// }

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    navigatorKey: globalNavigatorStateKey,
    //observers: [GoRouterObserver()],
    //debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'game',
            builder: (BuildContext context, GoRouterState state) => GamePage(gameData: ((state.extra) as Map<String, dynamic>?)),
            redirect: (_, state) => checkStorageKey('game') || state.extra != null ? null : '/',
          ),
        ],
      ),

      // ShellRoute(
      //   //observers: [GoRouterObserver()],
      //   builder: (BuildContext context, GoRouterState state, Widget child) {
      //     final String path = '${state.fullPath}';
      //
      //     print('state.fullPath: $path\nstate.extra: ${(state.extra as Map<String, dynamic>?)}');
      //     if (checkStorageKey('questionnaire') && (path!='/questionnaire') && (path!='/sign_document')) deleteKeyFromStorage('questionnaire');
      //     if (checkStorageKey('action') && (path!='/make-action')) deleteKeyFromStorage('action');
      //     //if (checkStorageKey('reportInfo') && (path!='/report')) deleteKeyFromStorage('reportInfo');
      //     if (checkStorageKey('client') && (path=='/clients')) deleteKeyFromStorage('client');
      //
      //     return HomePage(urlName: '${path[1].toUpperCase()}${path.substring(2)}', data: (state.extra as Map<String, dynamic>?), child: child);
      //   },
      //   routes: [
      //     GoRoute(
      //         name: 'dashboard',
      //         path: '/dashboard',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: DashboardPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/clients',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: ClientsPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/client',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: ClientPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/report',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: ReportPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/funds',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: FundsPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/undefined',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: UndefinedPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/history',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: HistoryPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/tasks',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: TasksPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/actions',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: ActionsPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/marketplace',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: MarketplacePage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/settings',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: SettingsPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/questionnaire',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: QuestionnairePage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/messages',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: MessagesPage(data: (state.extra as Map<String, dynamic>?)))
      //     ),
      //     GoRoute(
      //         path: '/sign_document', ///:info
      //         redirect: (_,state) async {
      //           print('redirect state.extra: ${state.extra}');
      //           if ((state.extra is Map<String, dynamic> && (state.extra as Map<String, dynamic>).isNotEmpty) || checkStorageKey('questionnaire')) {
      //             return await redirectGuardFuncCheck('${state.fullPath}');
      //           }
      //           else if (state.pathParameters['token']!=null && (decodeWithJwt('${state.pathParameters['token']}','lakmsd@@#;e;d234advxvs').isNotEmpty)) {
      //             return null;
      //           }
      //           return '/login';
      //         },
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: PDFPage(pdfInfo: (state.extra is Map<String, dynamic>)?(state.extra as Map<String, dynamic>):{}))
      //     ),
      //     GoRoute(
      //         path: '/make-action',
      //         redirect: (_,state) async => await redirectGuardFuncCheck('${state.fullPath}'),
      //         onExit: (BuildContext context, GoRouterState g) async => await onExit(gpath: g.fullPath),
      //         pageBuilder: (_, state) => NoTransitionPage(child: PingPdfPage(data: (state.extra is Map<String, dynamic>)?(state.extra as Map<String, dynamic>):{}))
      //     ),
      //   ],
      // ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => IconButton(onPressed: () => context.go('/'), icon: Icon(Icons.ac_unit_sharp)),
  );

  static GoRouter get router => _router;
}
