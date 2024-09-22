import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'model/productmodel.dart';
import 'widget/textFiledDecoration.dart';

class CRUDApp extends StatefulWidget {
  @override
  _CRUDAppState createState() => _CRUDAppState();
}

class _CRUDAppState extends State<CRUDApp> {

  DateTime datetimes = DateTime.now();

  static ScaffoldFeatureController snackbarmsg(
      BuildContext context, String? msg) {
    final snackBar = SnackBar(
      content: Text(msg!),
      action: SnackBarAction(
        label: '',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<Product> products = [];
  final TextEditingController TEProductName = TextEditingController();
  final TextEditingController TEProductCode = TextEditingController();
  final TextEditingController TEImg = TextEditingController();
  final TextEditingController TEUnitPrice = TextEditingController();
  final TextEditingController TEQty = TextEditingController();

  final _keyForm = GlobalKey<FormState>();

  bool isloading = false;

  void emptyController() {
    TEProductName.text = "";
    TEProductCode.text = "";
    TEImg.text = "";
    TEUnitPrice.text = "";
    TEQty.text = "";
  }

// ....................................................

  addOrEditWidget(BuildContext context, String title,
      {String? ProductName,
      String? ProductCode,
      String? Img,
      String? UnitPrice,
      String? Qty,
      String? id}) {
    if (title == 'Update') {
      TEProductName.text = ProductName!;
      TEProductCode.text = ProductCode!;
      TEImg.text = Img!;
      TEUnitPrice.text = UnitPrice!;
      TEQty.text = Qty!;
    }

    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: Text("$title item"),
              insetPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _keyForm,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFieldDecoraiton(
                          controller: TEProductName,
                          labelText: "ProductName",
                          hintText: 'Enter ProductName',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter ProductName";
                            } else if (RegExp(r"^\s")
                                .hasMatch(TEProductName.text)) {
                              return "Please remove white space";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Divider(
                          height: 5,
                          color: Colors.white,
                        ),
                        TextFieldDecoraiton(
                          controller: TEProductCode,
                          labelText: "ProductCode",
                          hintText: 'Enter ProductCode',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter ProductCode";
                            } else if (RegExp(r"^\s")
                                .hasMatch(TEProductCode.text)) {
                              return "Please remove white space";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Divider(
                          height: 5,
                          color: Colors.white,
                        ),
                        TextFieldDecoraiton(
                          controller: TEImg,
                          labelText: "Image",
                          hintText: 'Enter Imge Url',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Image Url";
                            } else if (RegExp(r"^\s").hasMatch(TEImg.text)) {
                              return "Please remove white space";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Divider(
                          height: 5,
                          color: Colors.white,
                        ),
                        TextFieldDecoraiton(
                          controller: TEUnitPrice,
                          labelText: "UnitPrice",
                          hintText: 'Enter UnitPrice',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter UnitPrice";
                            } else if (RegExp(r"^\s")
                                .hasMatch(TEUnitPrice.text)) {
                              return "Please remove white space";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Divider(
                          height: 5,
                          color: Colors.white,
                        ),
                        TextFieldDecoraiton(
                          controller: TEQty,
                          labelText: "Quantity",
                          hintText: 'Enter Quantity',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter Quantity";
                            } else if (RegExp(r"^\s").hasMatch(TEQty.text)) {
                              return "Please remove white space";
                            } else {
                              return null;
                            }
                          },
                        ),
                        Divider(
                          height: 5,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          if (_keyForm.currentState?.validate() == true) {
                            if (title == 'Add') {
                              addNewProduct();
                              snackbarmsg(context, "Data Added Successfully");
                              emptyController();
                              Navigator.of(context).pop();
                            } else {
                              updateProduct(id: id!);
                              snackbarmsg(context, "Data Updated Successfully");
                              emptyController();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: Text(title)),
                    TextButton(
                        onPressed: () {
                          emptyController();
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel')),
                  ],
                )
              ],
            ));
  }

  //................API Start................

  Future<void> getProductList() async {
    isloading = true;
    setState(() {});
    Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/ReadProduct');
    http.get(uri);
    http.Response response = await http.get(uri);
    print(response);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      products.clear();
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      for (var item in jsonResponse['data']) {
        products.add(Product(
          id: item['_id'] ?? "",
          ProductName: item['ProductName'] ?? "",
          ProductCode: item['ProductCode'] ?? "",


          Img: item['Img'] ?? "",
          UnitPrice: item['UnitPrice'] ?? "",
          Qty: item['Qty'] ?? "",
          TotalPrice: item['TotalPrice'] ?? "",
          CreatedDate: item['CreatedDate'] ?? "",
        ));
      }
    }
    isloading = false;
    setState(() {});
  }

  Future<void> addNewProduct() async {
    setState(() {});
    Uri uri = Uri.parse('http://164.68.107.70:6060/api/v1/CreateProduct');
    int totalPrice = int.parse(TEUnitPrice.text) * int.parse(TEQty.text);
    Map<String, dynamic> requestBody = {
      "ProductName": TEProductName.text,
      "ProductCode": TEProductCode.text,
      "Img": TEImg.text,
      "UnitPrice": TEUnitPrice.text,
      "Qty": TEQty.text,
      "TotalPrice": totalPrice.toString(),
      "CreatedDate": datetimes.toString(),
    };
    http.Response response = await http.post(uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode((requestBody)));
    getProductList();
  }

  Future<void> updateProduct({required String id}) async {
    Uri uri = Uri.parse("http://164.68.107.70:6060/api/v1/UpdateProduct/$id");
    int totalPrice = int.parse(TEUnitPrice.text) * int.parse(TEQty.text);
    Map<String, dynamic> requestBody = {
      "ProductName": TEProductName.text,
      "ProductCode": TEProductCode.text,
      "Img": TEImg.text,
      "UnitPrice": TEUnitPrice.text,
      "Qty": TEQty.text,
      "TotalPrice": totalPrice.toString(),
      "CreatedDate": datetimes.toString(),
    };
    http.Response response = await http.post(uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode((requestBody)));

    getProductList();
  }

  Future<void> deleteProduct({required String id}) async {
    Uri uri = Uri.parse("http://164.68.107.70:6060/api/v1/DeleteProduct/$id");
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
    getProductList();
  }

//................API End.................

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProductList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CRUD"),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                addOrEditWidget(context, 'Add');
              },
              icon: Icon(Icons.add, size: 40,)),
          IconButton(
              onPressed: () {
                getProductList();
              },
              icon: Icon(Icons.refresh,size: 40,)),

        ],
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
            color: Colors.grey,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (BuildContext context, int index) {
                      var product = products[index];
                      DateTime dateTime = DateTime.parse(product.CreatedDate);
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            "Image:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 8,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipOval(
                                                child: Image.network(
                                              product.Img,
                                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                    return Icon(Icons.error, color: Colors.red,size: 40,); // Error hole ekta Icon dekhabe
                                                  },
                                              width: 48.0,
                                              height: 48.0,
                                              fit: BoxFit.cover,

                                            )),
                                          ],
                                        )),
                                  ],
                                ),
                                customRow(title: 'Name', value: product.ProductName),
                                customRow(title: 'Code', value: product.ProductCode),
                                customRow(
                                    title: 'Unit Price', value: product.UnitPrice),
                                customRow(title: 'Quantity', value: product.Qty),
                                customRow(
                                    title: 'Total Price', value: product.TotalPrice),
                                customRow(
                                    title: 'Created Date',
                                    value:
                                        '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}'),
                                Divider(
                                  height: 10,
                                  color: Colors.redAccent,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          addOrEditWidget(
                                            context,
                                            'Update',
                                            id: product.id,
                                            ProductName: product.ProductName,
                                            ProductCode: product.ProductCode,
                                            Img: product.Img,
                                            UnitPrice: product.UnitPrice,
                                            Qty: product.Qty,
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color: Colors.green,
                                            ),
                                            Divider(
                                              indent: 10.0,
                                            ),
                                            Text(
                                              "edit",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          deleteProduct(id: product.id);
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete_forever,
                                              color: Colors.redAccent,
                                            ),
                                            Divider(
                                              indent: 10.0,
                                            ),
                                            Text(
                                              "delete",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
          ),
    );
  }

  Row customRow({required String title, required String value}) {
    return Row(
      children: [
        Expanded(
            flex: 4,
            child: Container(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )),
        Expanded(
            flex: 8,
            child: Container(
              child: Text(
                ": $value",
                style: TextStyle(fontSize: 16),
              ),
            )),
      ],
    );
  }
}
