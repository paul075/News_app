import 'package:flutter/material.dart';
import 'package:news_api/healper/blog_tile.dart';
import 'package:news_api/healper/list_of_countries.dart';
import 'package:news_api/models/article.dart';
import 'package:news_api/services/news_service.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiService apiService = ApiService();
  final countryPicker = const FlCountryCodePicker(
    showDialCode: false,
    filteredCountries: myCountryList,
  );
  String Country = 'Nigeria(default)';
  String CountryACode = 'ng';
  String countryFlag = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Flutter',
            ),
            Text(
              'News',
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(children: <Widget>[
                /// Categories
                Container(
                  child: Column(
                    children: [
                      Text('select the country of your choice:'),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Show the country code picker when tapped.
                          final code =
                              await countryPicker.showPicker(context: context);
                          // Null check
                          if (code != null) {
                            setState(() {
                              Country = code.name;
                              CountryACode = code.code;
                              countryFlag = code.flagUri;
                            });
                          }
                        },
                        child: Container(
                            height: 40,
                            width: 300,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3))
                                ]),
                            child: Card(
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Opacity(
                                        opacity: 0,
                                        child: Icon(Icons.add_circle, color: Colors.white,)),
                                    Spacer(),
                                    Image(
                                      fit: BoxFit.cover,
                                      height: 22,
                                      image: (countryFlag == '')
                                          ? const AssetImage(
                                              'assets/nigeria_flag.png')
                                          : AssetImage(
                                              countryFlag,
                                              package: 'fl_country_code_picker',
                                            ),
                                    ),
                                    SizedBox(width: 5,),
                                    Text(
                                      Country,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_drop_down_sharp,size: 40,),
                                  ],
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                ),

                /// Blogs
                FutureBuilder(
                    future: apiService.fetchArticles(CountryACode),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Article>> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, int index) {
                            final article =
                                (snapshot.data as List<Article>)[index];
                            if (article.urlToImage.toString().isNotEmpty &&
                                article.description.toString().isNotEmpty) {
                              return BlogTile(
                                  imageUrl: article.urlToImage.toString(),
                                  title: article.title.toString(),
                                  desc: article.description.toString(),
                                  url: article.url.toString());
                            }
                            return Container();
                          },
                          itemCount: (snapshot.data as List<Article>).length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider();
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("${snapshot.error}"),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                        ),
                      );
                    })
              ])),
        ),
      ),
    );
  }


Future<void> _pullRefresh() async {
 await apiService.fetchArticles(CountryACode);
}
}
