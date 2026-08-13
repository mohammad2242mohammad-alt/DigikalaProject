import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';


class HomePage extends StatefulWidget {

  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();

}



class _HomePageState extends State<HomePage> {


  final ProductService service = ProductService();


  late Future<List<Product>> products;



  @override
  void initState() {

    super.initState();

    products = service.getProducts();

  }




  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor: Colors.white,



      appBar: AppBar(

        backgroundColor: Colors.white,

        elevation: 0,


        title: const Text(

          'دیجی‌کالا',

          style: TextStyle(

            color: Colors.red,

            fontSize: 24,

            fontWeight: FontWeight.bold,

          ),

        ),

      ),



      body: FutureBuilder<List<Product>>(


        future: products,


        builder: (context, snapshot) {


          if (snapshot.connectionState == ConnectionState.waiting) {


            return const Center(

              child: CircularProgressIndicator(),

            );


          }



          if (snapshot.hasError) {


            return Center(

              child: Text(

                'خطا در دریافت اطلاعات:\n${snapshot.error}',

                textAlign: TextAlign.center,

              ),

            );


          }



          if (!snapshot.hasData || snapshot.data!.isEmpty) {


            return const Center(

              child: Text(

                'محصولی وجود ندارد',

                style: TextStyle(fontSize: 20),

              ),

            );


          }




          final products = snapshot.data!;



          return ListView.builder(


            itemCount: products.length,


            itemBuilder: (context, index) {


              final product = products[index];



              return Card(


                margin: const EdgeInsets.all(12),



                child: ListTile(


                  title: Text(product.name),



                  subtitle: Text(

                    '${product.price} تومان',

                  ),



                  trailing: Text(

                    '⭐ ${product.rating}',

                  ),


                ),


              );


            },

          );

        },

      ),


    );


  }

}