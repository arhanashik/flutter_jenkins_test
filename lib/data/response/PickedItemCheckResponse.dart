import 'package:o2o/data/product/product_entity.dart';

/// Created by mdhasnain on 27 Feb, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3. 

class PickedItemCheckResponse  {
   final int resultCode;
   final ProductEntity product;

   PickedItemCheckResponse._({this.resultCode, this.product});

   factory PickedItemCheckResponse.fromJson(Map<String, dynamic> json) {
     return PickedItemCheckResponse._(
       resultCode: json['resultCode'],
       product: ProductEntity.fromJson(json['product']),
     );
   }

   Map<String, dynamic> toJson() => {
     'resultCode': resultCode,
     'product': product.toJson(),
   };
}