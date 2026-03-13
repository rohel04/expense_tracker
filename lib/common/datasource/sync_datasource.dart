import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class SyncRemoteDataSource {
  Future<Either<UserCredential, bool>> signInGoogle();
  Future<void> logout();
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  @override
  Future<Either<UserCredential, bool>> signInGoogle() async {
    try {
      await GoogleSignIn.instance.disconnect();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return Left(await FirebaseAuth.instance.signInWithCredential(credential));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Right(false);
      }
      return const Right(false);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e);
    }
  }
}
