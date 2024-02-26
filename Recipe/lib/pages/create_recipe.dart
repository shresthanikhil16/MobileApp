import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/pages/navbar.dart';
import 'package:recipe_app/widgets/color.dart';
import 'package:path/path.dart' as path;
import 'package:recipe_app/widgets/dimensions.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({Key? key}) : super(key: key);

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  File? pickedFile;
  UploadTask? uploadTask;
  bool isFilePicked = false;
  String? _imageUrl;

  Future<void> selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        pickedFile = File(result.files.single.path!);
        isFilePicked = true;
      });

      await uploadFile(); // Call uploadFile() after selecting the file
    }
  }

  Future uploadFile() async {
    if (!isFilePicked) {
      return;
    }

    final fileName = _name!.toLowerCase().replaceAll(' ', '') + '.jpg';
    final filePath = 'recipe_images/$fileName';

    final ref = FirebaseStorage.instance.ref().child(filePath);
    setState(() {
      uploadTask = ref.putFile(pickedFile!);
    });

    final snapshot = await uploadTask!.whenComplete(() => {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
      _imageUrl = urlDownload;
    });

    setState(() {
      isFilePicked = false;
    });
  }

  final _formKey = GlobalKey<FormState>();
  String? _name;
  num? _time;
  String? _timetype;
  int? _serving;
  String? _difficulty;
  int? _calories;
  List<String> _ingredients = [];
  List<num> _ingredientAmounts = [];
  List<TextEditingController> _ingredientControllers = [];
  List<TextEditingController> _amountControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF92BBFF), // Change primary color here
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.height16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Recipe Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
              ),
              SizedBox(height: Dimensions.height16),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the time';
                  }
                  return null;
                },
                onSaved: (value) {
                  _time = double.tryParse(value ?? '') ?? 0;
                },
              ),
              SizedBox(height: Dimensions.height16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Time Type'),
                value: _timetype,
                items: const [
                  DropdownMenuItem(value: 'u', child: Text('Hours')),
                  DropdownMenuItem(value: 'min', child: Text('Minutes')),
                ],
                onChanged: (value) {
                  setState(() {
                    _timetype = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a time type';
                  }
                  return null;
                },
              ),
              SizedBox(height: Dimensions.height16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Serving'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the serving';
                  }
                  return null;
                },
                onSaved: (value) {
                  _serving = int.tryParse(value ?? '') ?? 0;
                },
              ),
              SizedBox(height: Dimensions.height16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Difficulty'),
                value: _difficulty,
                items: const [
                  DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  setState(() {
                    _difficulty = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a difficulty';
                  }
                  return null;
                },
              ),
              SizedBox(height: Dimensions.height16),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the calories';
                  }
                  return null;
                },
                onSaved: (value) {
                  _calories = int.tryParse(value ?? '') ?? 0;
                },
              ),
              SizedBox(height: Dimensions.height16),
              Text(
                'Ingredients',
                style: TextStyle(fontSize: Dimensions.iconSize18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Dimensions.iconSize18),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _ingredients.length,
                itemBuilder: (context, index) => _buildIngredientForm(index),
              ),
              ElevatedButton(
                onPressed: _addIngredientForm,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF92BBFF)), // Change primary color here
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: Text('Add Ingredient'),
              ),

              ElevatedButton(
                onPressed: _savingRecipe ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveRecipe();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF92BBFF)), // Change primary color here
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Navbar(),
    );
  }

  Widget buildProgress() => StreamBuilder(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot){
        if (snapshot.hasData){
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: Dimensions.height50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColor.AppBack,
                  color: AppColor.AppBack,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              ],
            ),
          );
        }
        else{
          return SizedBox(height: Dimensions.height30);
        }
      });

  Widget _buildIngredientForm(int index) {
    final ingredientController = TextEditingController();
    final amountController = TextEditingController();

    final ingredientValueNotifier = ValueNotifier<String>(_ingredients[index]);
    final amountValueNotifier = ValueNotifier<String>(
        _ingredientAmounts[index].toString());

    ingredientValueNotifier.addListener(() {
      _ingredients[index] = ingredientValueNotifier.value;
    });

    amountValueNotifier.addListener(() {
      _ingredientAmounts[index] =
          double.tryParse(amountValueNotifier.value) ?? 0;
    });

    ingredientController.text = _ingredients[index];
    amountController.text = _formatAmountValue(
        _ingredientAmounts[index]);

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: ingredientController,
            decoration: const InputDecoration(labelText: 'Ingredient'),
            onChanged: (value) => ingredientValueNotifier.value = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an ingredient';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            controller: amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount'),
            onChanged: (value) => amountValueNotifier.value = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              return null;
            },
          ),
        ),
        IconButton(
          onPressed: () => _removeIngredientForm(index),
          icon: Icon(Icons.remove_circle),
          color: Colors.red,
        ),
      ],
    );
  }

  String _formatAmountValue(num value) {
    if (value == value.round()) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(1);
    }
  }

  void _addIngredientForm() {
    setState(() {
      final ingredientController = TextEditingController();
      final amountController = TextEditingController();

      _ingredientControllers.add(ingredientController);
      _amountControllers.add(amountController);

      _ingredients.add('');
      _ingredientAmounts.add(0);
    });
  }

  void _removeIngredientForm(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
      _amountControllers.removeAt(index);

      _ingredients.removeAt(index);
      _ingredientAmounts.removeAt(index);
    });
  }

  bool _savingRecipe = false;

  Future<void> _saveRecipe() async {
    if (_savingRecipe) {
      return;
    }

    setState(() {
      _savingRecipe = true;
    });

    try {
      final recipeData = {
        'name': _name,
        'time': _time,
        'timetype': _timetype,
        'serving': _serving,
        'difficulty': _difficulty,
        'cal': _calories,
        'imageUrl': _imageUrl,
      };

      final recipeRef = await FirebaseFirestore.instance.collection('recipes')
          .add(recipeData);
      final ingredientsRef = recipeRef.collection('Ingredients').doc(
          'Ingredients');
      final amountsRef = recipeRef.collection('ingredientAmounts').doc(
          'ingredientAmounts');

      final Map<String, dynamic> ingredientData = {};
      final Map<String, dynamic> amountData = {};

      for (int i = 0; i < _ingredients.length; i++) {
        ingredientData['Ingredient${i + 1}'] = _ingredients[i];
        amountData['Amount${i + 1}'] = _ingredientAmounts[i];
      }

      await ingredientsRef.set(ingredientData);
      await amountsRef.set(amountData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recipe: $error')),
      );
    } finally {
      setState(() {
        _savingRecipe = false;
      });
    }
  }
}
