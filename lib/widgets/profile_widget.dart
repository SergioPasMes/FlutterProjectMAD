import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mad/helpers/apiManager.dart';

class ProfileWidget extends StatefulWidget {
  final String? alias;
  final int? age;
  final String? profile_picture;
  void Function(String) onAliasChange;
  void Function(int) onAgeChange;
  void Function(String) onPictureChange;
  @override
  _ProfileWidget createState() => _ProfileWidget();

  ProfileWidget({this.alias, this.age, this.profile_picture,
                required this.onAliasChange, required this.onAgeChange, required this.onPictureChange});
}

class _ProfileWidget extends State<ProfileWidget> {
  late final _aliasController = TextEditingController(text: widget.alias);
  late final _ageController = TextEditingController(text: widget.age.toString());
  final _apiManager = ApiManager();
  late String _profilePicture = widget.profile_picture ?? 'pfp_0.png';
  final List<String> avatars = [
    'assets/profile_pictures/pfp_0.png',
    'assets/profile_pictures/pfp_1.png',
    'assets/profile_pictures/pfp_2.png',
    'assets/profile_pictures/pfp_3.png',
    'assets/profile_pictures/pfp_4.png',
    'assets/profile_pictures/pfp_5.png',
    'assets/profile_pictures/pfp_6.png',
    'assets/profile_pictures/pfp_7.png',
    'assets/profile_pictures/pfp_8.png',
    'assets/profile_pictures/pfp_9.png',
    'assets/profile_pictures/pfp_10.png',
    'assets/profile_pictures/pfp_11.png',
  ];
  String? _aliasError;
  String? _ageError;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _aliasController,
              inputFormatters: [LengthLimitingTextInputFormatter(16)],
              maxLength: 16,
              decoration: InputDecoration(
                  labelText: 'Alias',
                  border: OutlineInputBorder(),
                  errorText: _aliasError
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    _aliasError = null;
                  } else if (value.length < 3) {
                    _aliasError = 'El alias debe tener al menos 3 caracteres';
                  } else {
                    _aliasError = null;
                  }
                });
                widget.onAliasChange(value);
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
                errorText: _ageError,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 16 || age > 100) {
                    setState(() {
                      _ageError = 'Age must be between 16 and 100';
                    });
                  } else {
                    setState(() {
                      _ageError = null;
                    });
                    widget.onAgeChange(age);
                  }
                } else {
                  setState(() {
                    _ageError = null;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final String? chosenImage = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Choose Profile Image'),
                    content: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: avatars.map((ruta) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context, ruta);
                          },
                          child: SizedBox(
                            width: 70,
                            height: 70,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(ruta, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      }).toList(), /// Convert the map into a list of widgets for the Wrap
                    ),
                  ),
                );

                if (chosenImage != null) {
                  setState(() {
                    _profilePicture = chosenImage;
                  });
                  widget.onPictureChange(chosenImage);
                }
              },
              child: SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(_profilePicture, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
    );
  }
}