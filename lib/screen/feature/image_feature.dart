import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/image_controller.dart';
import '../../helper/global.dart';
import '../../widget/custom_btn.dart';
import '../../widget/custom_loading.dart';

class ImageFeature extends StatefulWidget {
  const ImageFeature({super.key});

  @override
  State<ImageFeature> createState() => _ImageFeatureState();
}

class _ImageFeatureState extends State<ImageFeature> {
  final _c = ImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text('AI Image Creator'),

        //share btn
        actions: [
          Obx(
            () => _c.status.value == Status.complete
                ? IconButton(
                    padding: const EdgeInsets.only(right: 6),
                    onPressed: _c.shareImage,
                    icon: const Icon(Icons.share))
                : const SizedBox(),
          )
        ],
      ),

      //download btn
      floatingActionButton: Obx(() => _c.status.value == Status.complete
          ? Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: FloatingActionButton(
                onPressed: _c.downloadImage,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: const Icon(Icons.save_alt_rounded, size: 26),
              ),
            )
          : const SizedBox()),

      //body
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: mq.height * .02,
            bottom: mq.height * .1,
            left: mq.width * .04,
            right: mq.width * .04),
        children: [
          //text field
          TextFormField(
            controller: _c.textC,
            textAlign: TextAlign.center,
            minLines: 2,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
                hintText:
                    'Imagine something wonderful & innovative\nType here & I will create for you 😃',
                hintStyle: TextStyle(fontSize: 13.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),

          //ai image
          Container(
              height: mq.height * .5,
              margin: EdgeInsets.symmetric(vertical: mq.height * .015),
              alignment: Alignment.center,
              child: Obx(() => _aiImage())),
          Obx(() => _c.imageList.isEmpty
              ? const SizedBox()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(bottom: mq.height * .03),
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 10,
                    children: _c.imageList
                        .map((e) => InkWell(
                              onTap: () {
                                _c.url.value = e;
                                // Ensure status is updated
                                if (_c.status.value != Status.complete) {
                                  _c.status.value = Status.complete;
                                }
                              },
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: CachedNetworkImage(
                                  imageUrl: e,
                                  height: 100,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 100,
                                    width: 150,
                                    color: Colors.grey.shade300,
                                    child: Icon(Icons.broken_image,
                                        color: Colors.grey.shade700),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                )),

          //create btn
          // CustomBtn(onTap: _c.createAIImage, text: 'Create'),
          CustomBtn(onTap: _c.searchAiImage, text: 'Create'),
        ],
      ),
    );
  }

  Widget _aiImage() => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: switch (_c.status.value) {
          Status.none =>
            Lottie.asset('assets/lottie/ai_play.json', height: mq.height * .3),
          Status.complete => CachedNetworkImage(
              imageUrl: _c.url.value,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CustomLoading(),
              errorWidget: (context, url, error) {
                // If there's an error loading the current image, try the next one in the list if available
                if (_c.imageList.length > 1 &&
                    _c.imageList.first == _c.url.value) {
                  // Wait a moment, then use the next image in the list
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _c.url.value = _c.imageList[1];
                  });
                  return const CustomLoading();
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 32, color: Colors.red),
                      SizedBox(height: 8),
                      Text("Couldn't load the image",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      SizedBox(height: 10),
                      Text("Try a different search term",
                          textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () => _c.searchAiImage(),
                          child: Text("Try Again"))
                    ],
                  ),
                );
              },
            ),
          Status.loading => const CustomLoading()
        },
      );
}
