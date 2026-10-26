import 'package:flutter/material.dart';
import 'package:y3s1_final/models/product_model.dart';

final ValueNotifier<Set<int>> favoriteCodes = ValueNotifier<Set<int>>({});

void toggleFavorite(int code) {
  final updated = Set<int>.from(favoriteCodes.value);
  if (!updated.remove(code)) updated.add(code);
  favoriteCodes.value = updated;
}
class DataStore {
  final List<ProductModel> products = [
    ProductModel(
      code: 1001,
      name: "Shockproof Phone Case",
      category: "Case",
      oldprice: 12.0,
      discount: 10,
      image:
          "https://i.pinimg.com/736x/0d/48/a4/0d48a485cc7d81b9c7065e7d99929d4b.jpg",
      quantity: 1,
      rate: "4.5",
      view: "1.2K",
      size: ["iPhone 14", "iPhone 15", "Galaxy S24", "Redmi Note 13"],
      color: ["Black", "Clear", "Blue"],
      description:
          "A durable shockproof phone case designed to protect your phone from drops, "
          "scratches, and everyday damage. Made from flexible TPU with reinforced corners, "
          "it absorbs impact while keeping a slim and comfortable grip. Raised edges protect "
          "the screen and camera, and precise cutouts give easy access to all ports and buttons.",
    ),
    ProductModel(
      code: 1002,
      name: "Tempered Glass Screen Protector",
      category: "Screen Protector",
      oldprice: 8.0,
      discount: 15,
      image:
          "https://i.pinimg.com/736x/19/c5/8d/19c58d7f146ba6e5dd6983fa5baf6a6d.jpg",
      quantity: 1,
      rate: "4.7",
      view: "2.1K",
      size: ["iPhone 14", "iPhone 15", "Galaxy S24", "Redmi Note 13"],
      color: ["Clear", "Privacy", "Matte"],
      description:
          "9H hardness tempered glass that protects your screen from scratches, cracks, and "
          "fingerprints. Ultra-clear and touch-sensitive, it keeps the display sharp and "
          "responsive. Bubble-free installation with an easy alignment tray included.",
    ),
    ProductModel(
      code: 1003,
      name: "65W Fast Charger GaN",
      category: "Charger",
      oldprice: 35.0,
      discount: 20,
      image:
          "https://i.pinimg.com/736x/f1/db/30/f1db304b160146b9dafaf5b025d94d54.jpg",
      quantity: 1,
      rate: "4.8",
      view: "3.4K",
      size: ["20W", "33W", "65W"],
      color: ["White", "Black"],
      description:
          "A compact GaN fast charger that powers phones, tablets, and laptops quickly and "
          "safely. Supports PD and QC fast charging with built-in protection against "
          "overheating, overcurrent, and short circuits. Small enough to carry anywhere.",
    ),
    ProductModel(
      code: 1004,
      name: "USB-C Braided Cable",
      category: "Cable",
      oldprice: 10.0,
      discount: 12,
      image:
          "https://i.pinimg.com/736x/70/b7/e8/70b7e849ac6792d7d9c627532506ede8.jpg",
      quantity: 1,
      rate: "4.6",
      view: "1.8K",
      size: ["1m", "1.5m", "2m"],
      color: ["Black", "White", "Gray"],
      description:
          "A strong braided USB-C cable built for fast charging and quick data transfer. "
          "Reinforced connectors and a tangle-free nylon braid make it last through daily "
          "use. Supports up to 100W power delivery.",
    ),
    ProductModel(
      code: 1005,
      name: "Wireless Earbuds Pro",
      category: "Earbuds",
      oldprice: 60.0,
      discount: 25,
      image:
          "https://i.pinimg.com/736x/f6/0d/03/f60d03204c49d6227b652a54fa81b4d5.jpg",
      quantity: 1,
      rate: "4.9",
      view: "4.5K",
      size: ["Standard"],
      color: ["White", "Black", "Blue"],
      description:
          "True wireless earbuds with active noise cancellation, clear sound, and deep bass. "
          "Bluetooth 5.3 gives a stable connection, and the charging case provides up to 30 "
          "hours of total playtime. Comfortable fit with touch controls and water resistance.",
    ),
    ProductModel(
      code: 1006,
      name: "10000mAh Power Bank",
      category: "Power Bank",
      oldprice: 28.0,
      discount: 10,
      image:
          "https://i.pinimg.com/1200x/2d/f0/24/2df024a503ab470158e6a0f2b89c8332.jpg",
      quantity: 1,
      rate: "4.4",
      view: "980",
      size: ["10000mAh", "20000mAh"],
      color: ["Black", "White", "Blue"],
      description:
          "A slim and lightweight power bank that keeps your devices charged on the go. "
          "Dual output ports with fast charging support let you charge two devices at once. "
          "A digital display shows the remaining battery, and smart protection keeps charging safe.",
    ),
    ProductModel(
      code: 1007,
      name: "15W Wireless Charging Pad",
      category: "Wireless Charger",
      oldprice: 22.0,
      discount: 15,
      image:
          "https://i.pinimg.com/1200x/55/0c/95/550c95bd91aa2154df88a6f913dfc815.jpg",
      quantity: 1,
      rate: "4.3",
      view: "870",
      size: ["10W", "15W"],
      color: ["Black", "White", "Gray"],
      description:
          "A sleek wireless charging pad that charges your phone by simply placing it on top. "
          "Compatible with Qi-enabled phones and earbuds, with a non-slip surface and LED "
          "indicator. Foreign object detection keeps charging safe.",
    ),
    ProductModel(
      code: 1008,
      name: "Adjustable Phone Stand",
      category: "Stand",
      oldprice: 15.0,
      discount: 20,
      image:
          "https://i.pinimg.com/736x/df/ab/a9/dfaba99aa3f7ac407ab2253d6f33cd42.jpg",
      quantity: 1,
      rate: "4.8",
      view: "3.2K",
      size: ["Desk", "Portable"],
      color: ["Silver", "Black", "Pink"],
      description:
          "A sturdy aluminum phone stand with adjustable angle and height. Perfect for video "
          "calls, watching videos, and following recipes. Anti-slip pads keep your phone "
          "stable, and it folds flat for easy travel.",
    ),
    ProductModel(
      code: 1009,
      name: "Smart Watch Active",
      category: "Smart Watch",
      oldprice: 80.0,
      discount: 18,
      image:
          "https://i.pinimg.com/1200x/7b/8f/c2/7b8fc2879d842503cac1de15f9a1baf6.jpg",
      quantity: 1,
      rate: "4.6",
      view: "1.5K",
      size: ["41mm", "45mm"],
      color: ["Black", "Silver", "Pink"],
      description:
          "A smart watch with a bright AMOLED display, heart rate and sleep tracking, and "
          "multiple sport modes. Receive calls, messages, and app notifications on your wrist. "
          "Battery lasts up to 7 days, with IP68 water resistance.",
    ),
    ProductModel(
      code: 1010,
      name: "Portable Bluetooth Speaker",
      category: "Speaker",
      oldprice: 45.0,
      discount: 10,
      image:
          "https://i.pinimg.com/736x/23/ef/49/23ef4987d5c4065901b602329533ad82.jpg",
      quantity: 1,
      rate: "4.7",
      view: "2.7K",
      size: ["Mini", "Standard"],
      color: ["Black", "Blue", "Red", "Gray"],
      description:
          "A powerful portable speaker with rich sound and deep bass. Bluetooth 5.3 connects "
          "quickly, and the built-in battery plays up to 12 hours. Waterproof and dustproof, "
          "ideal for travel, parties, and outdoor use.",
    ),
    ProductModel(
      code: 1011,
      name: "Wireless Earbuds",
      category: "Audio",
      oldprice: 35.0,
      discount: 15,
      image:
          "https://i.pinimg.com/736x/35/41/a2/3541a2a125a5672eee310cb77aa2f2dc.jpg",
      quantity: 1,
      rate: "4.8",
      view: "3.2K",
      size: ["Small", "Medium", "Large"],
      color: ["White", "Black", "Pink"],
      description:
          "Enjoy clear sound and powerful bass with these wireless earbuds. "
          "Featuring Bluetooth 5.3, touch controls, and long battery life, "
          "they are perfect for music, gaming, and everyday use.",
    ),
    ProductModel(
      code: 1012,
      name: "Fast Charging Adapter",
      category: "Charger",
      oldprice: 25.0,
      discount: 10,
      image:
          "https://i.pinimg.com/1200x/0f/96/d9/0f96d95f23708999b198b41cc815a73e.jpg",
      quantity: 1,
      rate: "4.6",
      view: "1.8K",
      size: ["20W", "30W", "45W"],
      color: ["White", "Black"],
      description:
          "Charge your phone quickly and safely with this fast charging adapter. "
          "It features advanced protection against overheating and overcharging. "
          "Its compact design makes it ideal for home, office, and travel.",
    ),
    ProductModel(
      code: 1013,
      name: "Premium Phone Case",
      category: "Case",
      oldprice: 18.0,
      discount: 20,
      image:
          "https://i.pinimg.com/736x/39/aa/13/39aa13dd3d52f16bd2669e470d4e9383.jpg",
      quantity: 1,
      rate: "4.9",
      view: "4.5K",
      size: ["iPhone 13", "iPhone 14", "iPhone 15", "iPhone 16"],
      color: ["Pink", "Purple", "Black", "Clear"],
      description:
          "Protect your smartphone with this stylish premium phone case. "
          "Made from durable and shock-resistant materials, it protects "
          "your phone from scratches and accidental drops while keeping "
          "a slim and fashionable appearance.",
    ),
    ProductModel(
      code: 1014,
      name: "Magnetic Wireless Charger",
      category: "Charger",
      oldprice: 40.0,
      discount: 15,
      image:
          "https://i.pinimg.com/1200x/51/f1/02/51f1026615366622a962def9d523651f.jpg",
      quantity: 1,
      rate: "4.7",
      view: "2.1K",
      size: ["15W", "20W"],
      color: ["White", "Black", "Silver"],
      description:
          "Experience convenient wireless charging with this magnetic charger. "
          "Its strong magnetic connection keeps compatible phones securely "
          "in place. A lightweight and portable design makes charging "
          "simple at home or on the go.",
    ),
    ProductModel(
      code: 1015,
      name: "Phone Stand Holder",
      category: "Holder",
      oldprice: 12.0,
      discount: 5,
      image:
          "https://i.pinimg.com/736x/48/2a/4f/482a4fafe72d64a475eeda4f4735ec0a.jpg",
      quantity: 1,
      rate: "4.5",
      view: "950",
      size: ["Small", "Medium"],
      color: ["White", "Black", "Pink", "Blue"],
      description:
          "Enjoy hands-free phone use with this adjustable phone stand. "
          "It offers a stable base and flexible viewing angles for video calls, "
          "watching movies, reading, and online learning. Its foldable design "
          "makes it easy to carry anywhere.",
    ),
    ProductModel(
      code: 1016,
      name: "USB-C Fast Charging Cable",
      category: "Cable",
      oldprice: 15.0,
      discount: 10,
      image:
          "https://i.pinimg.com/736x/6c/61/ac/6c61acc8b13942c4019027212edda46b.jpg",
      quantity: 1,
      rate: "4.6",
      view: "1.5K",
      size: ["1 Meter", "2 Meters"],
      color: ["White", "Black", "Blue"],
      description:
          "Charge your devices efficiently with this durable USB-C cable. "
          "It supports fast charging for compatible devices and provides "
          "reliable data transfer. The flexible and reinforced design "
          "helps prevent everyday wear and damage.",
    ),
    ProductModel(
      code: 1017,
      name: "Smart Watch",
      category: "Wearable",
      oldprice: 65.0,
      discount: 20,
      image:
          "https://i.pinimg.com/736x/2a/f4/d2/2af4d211724d1a506f23e6219aeac2d2.jpg",
      quantity: 1,
      rate: "4.8",
      view: "5.2K",
      size: ["40mm", "44mm"],
      color: ["Black", "Pink", "Silver", "Gold"],
      description:
          "Stay connected with this stylish smart watch. It includes "
          "fitness tracking, heart rate monitoring, message notifications, "
          "and multiple sports modes. Its modern design is suitable "
          "for workouts and everyday activities.",
    ),
    ProductModel(
      code: 1018,
      name: "Tempered Glass Screen Protector",
      category: "Screen Protector",
      oldprice: 10.0,
      discount: 10,
      image:
          "https://i.pinimg.com/736x/4a/10/da/4a10dad0b44a870b9111256ab1f2b0f0.jpg",
      quantity: 1,
      rate: "4.7",
      view: "2.9K",
      size: ["iPhone", "Samsung", "Xiaomi"],
      color: ["Clear"],
      description:
          "Keep your phone screen protected with this high-quality "
          "tempered glass protector. It provides scratch resistance, "
          "clear visibility, and smooth touch sensitivity. The "
          "easy installation design helps reduce air bubbles.",
    ),
    ProductModel(
      code: 1019,
      name: "Power Bank 20000mAh",
      category: "Power Bank",
      oldprice: 55.0,
      discount: 15,
      image:
          "https://i.pinimg.com/736x/f9/cd/01/f9cd0192a20e7ca5b32d615f263853af.jpg",
      quantity: 1,
      rate: "4.9",
      view: "3.8K",
      size: ["10000mAh", "20000mAh"],
      color: ["Black", "White", "Blue"],
      description:
          "Keep your devices powered throughout the day with this "
          "high-capacity power bank. It features multiple charging "
          "ports, fast charging support, and built-in safety protection. "
          "Its portable design is perfect for travel and outdoor adventures.",
    ),
    ProductModel(
      code: 1020,
      name: "RGB Gaming Headset",
      category: "Headphones",
      oldprice: 50.0,
      discount: 25,
      image:
          "https://i.pinimg.com/736x/cc/01/ab/cc01ab3e43014cd131df13852cc3c8f8.jpg",
      quantity: 1,
      rate: "4.8",
      view: "2.6K",
      size: ["Standard", "Wireless"],
      color: ["Black", "White", "Pink"],
      description:
          "Enjoy immersive gaming audio with this RGB gaming headset. "
          "It features comfortable ear cushions, a clear microphone, "
          "and colorful lighting effects. Its detailed sound helps "
          "create an enjoyable gaming and entertainment experience.",
    ),
  ];
}
