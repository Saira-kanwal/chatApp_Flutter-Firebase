import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class InsertPhoto extends StatefulWidget {
  final Function(File) onSelect;
  final String imageUrl;
  final String assetImg;
  const InsertPhoto({Key? key, required this.onSelect, required this.imageUrl,required this.assetImg}) : super(key: key);
  @override
  State<InsertPhoto> createState() => _InsertPhotoState();
}

class _InsertPhotoState extends State<InsertPhoto> {
  File? _image;

  ImageProvider<Object> showImage()
  {
    // if(_image != null)
    //     {
    //       return FileImage(_image!);
    //     }
    if(widget.imageUrl.isNotEmpty && _image == null)
    {
      return NetworkImage(widget.imageUrl);
    }
    else if((widget.imageUrl.isEmpty && _image != null) || (widget.imageUrl.isNotEmpty && _image != null) )
    {
      return FileImage(_image!);
    } else if( widget.imageUrl.isEmpty && _image == null)
      {
        return  AssetImage(widget.assetImg);
      }else
        {
          return AssetImage(widget.assetImg);
        }
  }

  //  void cropImage(XFile file) async{
  //   await ImageCropper.cropImage(sourcePath: file.path);
  //
  // }

  @override
  Widget build(BuildContext context) {

    return
      Stack(
          children: [
             Padding(
              padding: const EdgeInsets.all(15.0),
              child:

              Container(
                  height: 100,
                  width: 100,
                  decoration:  BoxDecoration(
                    color: Colors.grey.shade300,
                    image: DecorationImage(
                        image: showImage(),fit: BoxFit.fill),
                    borderRadius:  const BorderRadius.all(Radius.circular(100.0)),
                  ),
                  child: const Text('')
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: () async {
                  ImagePicker picker = ImagePicker();
                  var file = await picker.pickImage(
                      source: ImageSource.gallery,
                      preferredCameraDevice: CameraDevice.rear,
                      imageQuality: 85,
                  );
                  if(file != null)
                  {
                    File x = File(file.path);
                    _image = x;
                    if(_image != null)
                    {
                      widget.onSelect(_image!);
                    }
                    setState(() {

                    });
                  }
                },child:const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.add_a_photo_outlined,color: Colors.white,size: 20,),
                  ),

              ),
            ),
          ]
      );

  }
}