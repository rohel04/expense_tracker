import 'package:expense_tracker/common/datasource/sync_datasource.dart';
import 'package:expense_tracker/fetch.dart';
import 'package:expense_tracker/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var user='';
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/background.jpg')
            )
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorUtil.kTextColor,
                      elevation: 0.0,
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                     )
                    ),
                    onPressed: () {
                      getData();
                      // if(user.isNotEmpty){
                      //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>FetchScreen(userId: user)), (route) => false);
                      //   // Navigator
                      // }
                    },
                    child:isLoading?
                    const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(color: Colors.black,)
                    ):
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google.png',height: 35,width: 35,),
                        const SizedBox(width: 10,),
                        const Text('Sign with google',style: TextStyle(color: Colors.black),),
                      ],
                    )
                  ),
                ),
                
              ],
            ),
          ),
        )
      ),
    );
  }

  navigate(){
    if(user.isNotEmpty){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>FetchScreen(userId: user)), (route) => false);
    }
  }

  getData() async{
    SyncRemoteDataSource a=SyncRemoteDataSourceImpl();
    setState(() {
      isLoading=true;
    });
    var result=await a.signInGoogle();
    result.fold((result) async{
      var shared=await SharedPreferences.getInstance();
      await shared.setString('user', result.user!.uid);
      setState(() {
        user=result.user!.uid;
        isLoading=false;
      });
      navigate();
    } ,
    (r){
       setState(() {
        isLoading=false;
      });
    });
   
   
  } 
}