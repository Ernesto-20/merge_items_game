// import 'package:cloud_firestore/cloud_firestore.dart';

// FirebaseFirestore db = FirebaseFirestore.instance;

// Stream<List<({String id, String name, double score})>> getScore() async* {
//   yield* db.collection('score').snapshots().map((querySnapshot) {
//     return querySnapshot.docs.map((doc) {

//       double score = doc.data()['score'].toDouble();

//       return (id: doc.id, name: doc.data()['name'].toString(), score: score);
//     }).toList()
//       ..sort(
//           (({String id, String name, double score}) a, ({String id, String name, double score}) b) {
//         return a.score >= b.score ? -1 : 1;
//       });
//   });
// }

// Future<bool> post(({String name, double score}) data) async {
//   bool added = false;
//   await db.collection('score').add({
//     'name': data.name,
//     'score': data.score,
//   }).then((value) {
//     added = true;
//   }).onError((error, stackTrace) {
//     added = false;
//   });

//   return added;
// }

// Future<bool> update(({String id, String name, double score}) data) async {
//   bool added = false;
//   await db.collection('score').doc(data.id).update({'name': data.name, 'score': data.score}).then((value) {
//     added = true;
//   }).onError((error, stackTrace) {
//     added = false;
//   });

//   return added;
// }
