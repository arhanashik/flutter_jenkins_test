/// Created by mdhasnain on 17 Apr, 2020
/// Email: md.hasnain@healthcare-tech.co.jp
///  
/// Purpose of the class:
/// 1. 
/// 2. 
/// 3.

class ExampleItem {
  static const Pineapples = ExampleItem._('Pineapples');
  static const Watermelons = ExampleItem._('Watermelons');
  static const StarFruit = ExampleItem._('Star Fruit');
  static const values = [
    Pineapples,
    Watermelons,
    StarFruit,
  ];

  const ExampleItem._(this.text);

  final String text;
}