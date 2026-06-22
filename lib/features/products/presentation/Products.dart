import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_roots/Utils/AppBarWidget.dart';
import 'package:urban_roots/features/dashboard/dashboard_controller.dart';
import 'package:urban_roots/features/products/navigation/product_navigation.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/banner.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/image_slider.dart';
import 'package:urban_roots/features/dashboard/presentation/widgets/products_slider.dart';
import 'package:urban_roots/features/products/data/ProductsController.dart';
import 'package:urban_roots/features/products/models/Product.dart';
import 'package:urban_roots/features/products/presentation/ProductCard.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> futureProducts;
  ProductsController productsController = Get.put(ProductsController());

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() {
    setState(() {
      futureProducts =
          productsController.listProducts(context, 0, 0, 10000, 0, 0, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.sizeOf(context).width;
    var screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
        appBar: AppBarWidget(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight / 5, child: SliderPage()),
              Container(
                margin: EdgeInsets.all(10),
                height: screenHeight / 8,
                child: Text(
                  "Product Categories",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              SizedBox(height: screenHeight / 5, child: ProductSliderPage()),
              Container(
                margin: EdgeInsets.all(10),
                height: 40,
                child: Text(
                  "Our Products",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 30),
                alignment: Alignment.topRight,
                height: 30,
                child: InkWell(
                  onTap: () {
                    DashboardController.findOrPut().goToTab(1);
                  },
                  child: Text(
                    "See All",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.deepOrange),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(
                height: 600,
                child: FutureBuilder<List<Product>>(
                  future: futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No products available'));
                    } else {
                      final displayCount = snapshot.data!.length < 6
                          ? snapshot.data!.length
                          : 6;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: displayCount,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 7.0,
                            childAspectRatio:
                                MediaQuery.of(context).size.width < 600
                                    ? 0.6
                                    : 0.7,
                          ),
                          itemBuilder: (context, index) {
                            return ProductCard(
                              id: int.tryParse(snapshot.data![index].id) ?? 0,
                              name: snapshot.data![index].name,
                              grams: snapshot.data![index].grams,
                              stock: snapshot.data![index].stock,
                              price: snapshot.data![index].price,
                              imageUrl: snapshot.data![index].imageUrl,
                              onProductTap: () => openProductDetails(
                                context,
                                snapshot.data![index],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 320,
                child: BannerSection(),
              )
            ],
          ),
        ));
  }
}
