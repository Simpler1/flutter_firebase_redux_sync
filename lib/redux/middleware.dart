import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_redux_sync/redux/actions.dart';
import 'package:firebase_redux_sync/redux/app_state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

final allEpics = combineEpics<AppState>([counterEpic, incrementEpic]);

Stream<dynamic> incrementEpic(Stream<dynamic> actions, EpicStore<AppState> store) {
  return Observable(actions).ofType(TypeToken<IncrementCounterAction>()).flatMap((_) {
    return Observable.fromFuture(Firestore.instance
        .document("users/test")
        .updateData({'counter': store.state.counter + 1})
        .then((_) => CounterDataPushedAction())
        .catchError((error) => CounterOnErrorEventAction(error)));
  });
}

Stream<dynamic> counterEpic(Stream<dynamic> actions, EpicStore<AppState> store) {
  return Observable(actions) // 1
      .ofType(TypeToken<RequestCounterDataEventsAction>()) // 2
      .switchMap((RequestCounterDataEventsAction requestAction) {
    // 3
    return getUserClicks() // 4
        .map((counter) => CounterOnDataEventAction(counter)) // 7
        .takeUntil(actions.where((action) => action is CancelCounterDataEventsAction)); // 8
  });
}

Observable<int> getUserClicks() {
  return Observable(Firestore.instance.document("users/test").snapshots()) // 5
      .map((DocumentSnapshot doc) => doc['counter'] as int); // 6
}
