import 'package:o2o/data/constant/const.dart';
import 'package:o2o/ui/widget/common/app_images.dart';

class ProductEntity {
  String title;
  int janCode;
  String category;
  int itemCount;
  int pickedItemCount;
  String imageUrl;
  int price;
  int flag;

  ProductEntity._({
    this.title,
    this.janCode,
    this.category,
    this.itemCount,
    this.pickedItemCount,
    this.imageUrl,
    this.price = 0,
    this.flag = 0,
  });

  ProductEntity(
      this.title,
      this.janCode,
      this.category,
      this.itemCount,
      this.pickedItemCount,
      this.imageUrl,
      {
        this.price = 0,
        this.flag = 0,
      }
  );

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return json == null? null : ProductEntity._(
      title: json['title'],
      janCode: json['janCode'],
      category: json['category'],
      itemCount: json['itemCount'],
      pickedItemCount: json['pickedItemCount'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      flag: json['flag'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'janCode': janCode,
    'category': category,
    'itemCount': itemCount,
    'pickedItemCount': pickedItemCount,
    'imageUrl': imageUrl,
    'price': price,
    'flag': flag,
  };

  static dummyProducts () {
    return [
      ProductEntity(
        'Product 1 name is very large but still it is okay bro',
        1111111111111,
        'Category 1 very very large and so large is not wow great fine ',
        3, 1, AppImages.NO_IMAGE_URL, price: 1200,
      ),
      ProductEntity('Product 2', 1111111111111,
        'Category 2', 2, 1, AppImages.NO_IMAGE_URL, price: 1200,),
      ProductEntity('Product 3', 1111111111111,
        'Category 3', 3, 3, AppImages.NO_IMAGE_URL, price: 1200,),
    ];
  }
}
