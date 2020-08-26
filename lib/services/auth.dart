import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jio/app/home/models/user.dart';
import 'api_path.dart';
import 'firestore_service.dart';

abstract class AuthBase {
  Stream<FirebaseUser> get onAuthStateChanged;

  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<User> firebaseToUser(String user);
  Future<void> signOut();
  Future<void> updateLastSeen();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  final _service = FirestoreService.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return User(
      uid: user.uid,
      photoUrl: user.photoUrl,
      displayName: user.displayName ?? "Anonymous",
      exp: 10.0,
      ratings: 5.0,
      percent: 0.0,
      categoryLevels: [],
      friendlist: [],
      friendRequest: [],
      lastSeen: Timestamp.now(),
      chattingWith: null,
      pushToken: null,
      description: null,
      location: null,
    );
  }

  Stream<FirebaseUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged;
  }

  Future<User> firebaseToUser(String user) async {
    if (user == null) {
      return null;
    }
    updateLastSeen();
    var doc = await _firestore.document(APIPath.user(user)).get();
    print(doc.data['exp']);
    return User.fromMap(doc.data);
  }

  @override
  Future<void> updateLastSeen() async {
    final user = await _firebaseAuth.currentUser();
    _firestore
        .document(APIPath.user(user.uid))
        .updateData({'lastSeen': Timestamp.now()});
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return firebaseToUser(authResult.user.uid);
  }

  @override
  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    User user = _userFromFirebase(authResult.user);
    setUserProfile(user);
    return user;
  }

  Future<void> setUserProfile(User user) async => await _service.setData(
        path: APIPath.user(user.uid),
        data: user.toMap(),
      );

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
