import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/services/services.dart';

import 'package:productos_app/interfaces/input_decorations.dart';
import 'package:productos_app/widgets/widgets.dart';


class SignupScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 250),

              CardContainer(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Signin:', style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 10),

                    ChangeNotifierProvider(
                      create: ( _ ) => LoginFormProvider(),
                      child: _LoginForm(),
                    ),

                  ],
                ),
              ),

              SizedBox(height: 50),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
                child: Text('¿Ya tienes una cuenta?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                  shape: MaterialStateProperty.all(StadiumBorder())
                ),
              ),
              
              SizedBox(height: 50),


            ],
          ),
        ) 
      )
    );
  }
}

class _LoginForm extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
        // TODO: mantener la referencia al KEY
        key: loginForm.formKey,

        autovalidateMode: AutovalidateMode.onUserInteraction,

        child: Column(
          children: [
            
            TextFormField(
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: 'example.email@gmail.com',
                labelText: 'Email',
                prefixIcon: Icons.alternate_email
              ),
              onChanged: (value) => loginForm.email = value,
              validator: (value) {

                String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regExp  = new RegExp(pattern);

                return regExp.hasMatch(value ?? '') ? null : 'El formato de correo no es válido'; 

              },
            ),

            SizedBox(height: 30),

            TextFormField(
              autocorrect: false,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecorations.authInputDecoration(
                hintText: '******',
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline
              ),
              onChanged: (value) => loginForm.password = value,

              validator: (value) {
                if (value != null && value.length >= 6) return null;
                return 'La contraseña debe contener 6 carácteres';
              },
            ),

            SizedBox(height: 30),

            MaterialButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              disabledColor: Colors.grey,
              elevation: 0,
              color: Colors.deepPurple,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                child: Text(
                  loginForm.isLoading ? 'Espere...' : 'Registrarse', 
                  style: TextStyle(color: Colors.white)),
              ),
              onPressed: loginForm.isLoading ? null : () async {
                
                FocusScope.of(context).unfocus();
                final authService = Provider.of<AuthService>(context, listen: false);

                if( !loginForm.isValidForm() ) return;

                loginForm.isLoading = true;

                final String? errorMessage = await authService.createUser(loginForm.email, loginForm.password);
                if (errorMessage == null) {
                  Navigator.pushReplacementNamed(context, 'home');
                } else {
                  NotificationService.showSnackbar(errorMessage);
                  loginForm.isLoading = false;
                }
              }
            )
            
          ],
        ),
      ),
    );
  }
}