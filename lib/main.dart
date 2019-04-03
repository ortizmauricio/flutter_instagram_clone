import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() =>runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      theme:ThemeData(
        primarySwatch: Colors.blue,
        primaryIconTheme: new IconThemeData(color: Colors.black),
      ),
      home: MyHomePage(),
    );
  }

}

class userAccountPage extends StatefulWidget {
  var info;
  var token;
  var posts;
  var myAccount;

  userAccountPage(this.info, this.token, this.posts, this.myAccount, {Key key}):super (key:key);

  @override
  _userAccountPageState createState() => _userAccountPageState();
}

class _userAccountPageState extends State<userAccountPage> {
  var bioCtrl = TextEditingController();
  var imageChosen = false;
  File _image;

  Future _getImage() async {
    print(_image.toString() == "null");
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
      _image = image;
      imageChosen = true;
    });
  }

  Future<Response> upload(var token) async{
      FormData formData = new FormData.from({
        "image": new UploadFileInfo(_image, _image.path)
      });
      var response = await Dio().patch("http://serene-beach-48273.herokuapp.com/api/v1/posts", data: formData, options: Options(
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token"
        },
      ),);
    return response;
  }

  void editProfile(){
    //EditProfilePage editPage = new EditProfilePage();
    Navigator.of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              leading: new IconButton(
                icon: new Icon(Icons.close),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              title: new Text('Edit Profile',
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              
              
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                
                 child: new Column(
                   mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                      child: new CircleAvatar(
                        backgroundImage: NetworkImage(widget.info["profile_image_url"]),
                        radius: 50.0,
                      ),
                    ),
                    new FlatButton(
                        onPressed: () {
                          _getImage();
                          print("This ran, imageChosen is now $imageChosen");
                        },
                        child: new Text(
                          "Change Photo",
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        )),
                    imageChosen ? 
                    new FlatButton(
                        onPressed: () {
                          print("Posting image");
                        },
                        child: new Text(
                          "Submit Change",
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 20.0,
                              ),
                        )):Text(""),
                    new Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: new Column(
                        children: <Widget>[
                          TextField(
                            controller: bioCtrl, 
                            autocorrect: false,
                            style: TextStyle(fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              hintText: "Bio"  
                            ),
                            
                          ),
                          new OutlineButton(
                            textColor: Colors.blue,
                            
                            onPressed: ()
                            { ;}, 
                            borderSide: BorderSide.none, child: new Text("Change Bio", )),
                        ],
                      ),
                    ),
                    ],
                  )
                ),
              ],
            )),
      );
    }));
  }
  

Container buildFollowButton({String text, Color backgroundcolor, Color textColor, Color borderColor, Function function}) {
      return new Container(
        padding: const EdgeInsets.only(top: 2.0),
        child: new FlatButton(
            onPressed: function,
            child: new Container(
              decoration: new BoxDecoration(
                  color: backgroundcolor,
                  border: new Border.all(color: borderColor),
                  borderRadius: new BorderRadius.circular(5.0)),
              alignment: Alignment.center,
              child: new Text(text,
                  style: new TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
              width: 250.0,
              height: 27.0,
            )),
      );
  }

Future<List<dynamic>> getPosts(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";

    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    var posts_json =jsonDecode(response.body);
    print("Got new posts");
    print(posts_json);
    widget.posts = posts_json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
                title: new Text(
                widget.info["email"],
                style: const TextStyle(color: Colors.black),
              
              ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
      body: new Column(
        children: <Widget>[
        new Container(
          child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(widget.info["profile_image_url"]),
                          ),
                          new Expanded(
                            child: new Column(
                              children: <Widget>[
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    widget.myAccount ? 
                                    buildFollowButton(text: "Edit Profile",
                                      backgroundcolor: Colors.white,
                                      textColor: Colors.black,
                                      borderColor: Colors.grey,
                                      function: editProfile):Text(""),
                                  ],
                                )
                              ],
                            )
                          ),
                        
                        ],
                      ),
                      new Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15.0),
                        child: new Text(
                          widget.info["email"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      new Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1.0),
                        child: new Text(widget.info["bio"]),
                      ),
                    ],
                  ),
                ),
                new Divider(),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.list, color: Colors.blueAccent),
                    ),
                  ],
                ),
                new Divider(height: 0.0),
                  
              ],
            ),
        ),
         Expanded(
            child: new RefreshIndicator(
              onRefresh: _refresh,
              child:  ListView.builder(
                  itemCount: widget.posts.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                  return InstaPost(widget.posts[index], widget.token.toString());
                }
              ),
            )
             
          )
        ],
      )

      /*
      new Column(
        children: <Widget>[]
          Expanded(
            child: new Column(
              children: <Widget>[
                Expanded(
                  child: 
                    ListView.builder(
                        itemCount: widget.posts.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                        return InstaPost(widget.posts[index], widget.token.toString());
                      }
                    ),
                  )
                ],
            ) 
            
          ),
        ],
      ),
      */
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();
    setState(() {

    });

    return;
  }

  _getFeed() async {
    
    setState(() {
      getPosts(widget.token);
    });
  }
}

class _commentScreen extends StatefulWidget {

  List<dynamic> comments;
  var id;
  var token;
  _commentScreen(this.comments,this.id, this.token, {Key key}) :super(key:key);

  @override
  _commentScreenState createState() => _commentScreenState();
}

class commentList extends StatefulWidget {
List<dynamic> comments;

commentList(this.comments, {Key key}): super(key: key);

@override
  _commentListState createState() => _commentListState();
}

class _commentListState extends State<commentList> {
  @override
  Widget build(BuildContext context) {
    return Container(
            child: ListView.builder(
              itemCount: widget.comments.length,
              itemBuilder: (BuildContext context, int index) {
              return new ListTile(
                title: new Text(widget.comments[index]["text"]),
                leading: new CircleAvatar(
                  backgroundImage: NetworkImage(widget.comments[index]["user"]["profile_image_url"]),
                  backgroundColor: Colors.blueGrey,
                ),
              );
              }
            )
    );
  }
}

class _commentScreenState extends State<_commentScreen> {

  var commentsCtrl =TextEditingController();

   Future<List<dynamic>> addComment(text) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/${widget.id}/comments?text=$text";
    var getUrl = "https://serene-beach-48273.herokuapp.com/api/v1/posts/${widget.id}/comments?";

    var response = await http.post(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var getResponse = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});

    var serverResponse =jsonDecode(response.body);
    print(serverResponse);
    var newComments =jsonDecode(getResponse.body);
    print(newComments);
    return newComments;
    
  }

  void createComment(context) async{
    var newComments = await addComment(commentsCtrl.text);
    setState(() {
      widget.comments = newComments;
    });
  }

 
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Comments",
          style: new TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: commentList(widget.comments)
          ),
          new Divider(),
          new ListTile(
            title: new TextFormField(
              controller: commentsCtrl,
              decoration: new InputDecoration(labelText: "Write a comment..."),
            ),
            trailing: new OutlineButton(onPressed: (){ createComment(context);}, borderSide: BorderSide.none, child: new Text("Post"),),
          )
        ],
      ),
      
      
    );
  }
}

class InstaPost extends StatefulWidget {
  var post;
  var liked;
  var token;
  InstaPost(this.post, this.token);
  
  @override
  _InstaPostState createState() => _InstaPostState();
}

class _InstaPostState extends State<InstaPost> {

  IconData heart;
  Color likeColor;

  Future<dynamic> getUserInfo(id) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$id";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var info = jsonDecode(response.body);
    print(info);
    return info;

  }

  Future<dynamic> getUserPosts(id) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/users/$id/posts";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    var posts_json =jsonDecode(response.body);
   
    print(posts_json);
    return posts_json;

  }

  void likePost(var id) async{
    print(widget.token.toString());
    var response = await http.post("https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes", headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});
    print(jsonDecode(response.body));
   
  }

  void unlikePost(var id) async{
    var response = await http.delete("https://serene-beach-48273.herokuapp.com/api/v1/posts/$id/likes", headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token} "});
    print(jsonDecode(response.body));
  }

  Future<List> getComments() async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts/${widget.post["id"]}/comments";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${widget.token}"});

    return jsonDecode(response.body);

  }

 void commentsPage(context) async{
    var comments = await getComments();
    Navigator.push(context, MaterialPageRoute(builder: (context) => _commentScreen(comments, widget.post["id"], widget.token.toString())));
    
  }

  void userAccount(context) async{
    var info = await getUserInfo(widget.post["user_id"]);
    var userPosts = await getUserPosts(widget.post["user_id"]);
    Navigator.push(context, MaterialPageRoute(builder: (context) => userAccountPage(info, widget.token, userPosts, false)));
  }
 
  void checkifLiked(){
     if(widget.post['liked'])
      {
        widget.liked = true;
        heart = FontAwesomeIcons.solidHeart;
        likeColor = Colors.pink;
      }
      else{
        widget.liked = false;
        heart = FontAwesomeIcons.heart;
      }
  }


  void initState(){
    setState(() {
      checkifLiked();
    });
  }

  @override

  Widget build(BuildContext context) {
  return Container( 
      
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: new CircleAvatar(
              backgroundImage: NetworkImage(widget.post["user_profile_image_url"]),
              backgroundColor: Colors.grey,
            ),
            title: new Text(widget.post["user_email"], style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: (){
              userAccount(context);
            },
            subtitle:  Text("Posted at: ${widget.post["created_at"]}", style: TextStyle(fontSize: 10),),
          ),
          new Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.network(widget.post["image_url"])
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
              new GestureDetector(
                child: new Icon(
                  heart,
                  size: 25.0,
                  color: likeColor,
                  ),
                onTap: (){
                  if(!widget.liked)
                  {
                    likePost(widget.post["id"]);
                    setState(() {
                      widget.post["likes_count"]++;
                      widget.liked = true;
                      heart = FontAwesomeIcons.solidHeart;
                      likeColor = Colors.pink;
                    });
                  }
                  else
                  {
                    unlikePost(widget.post["id"]);
                    setState(() {
                      widget.post["likes_count"]--;
                      widget.liked = false;
                      heart = FontAwesomeIcons.heart;
                      likeColor = Colors.black;
                    });
                  }

                },
              ),
              new Container(
                margin: const EdgeInsets.only(left: 8.0),
                child:  Text("${widget.post["likes_count"]}", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              ),
              new Padding(padding: const EdgeInsets.only(right: 20.0)),
              new GestureDetector(
                child: const Icon(
                  FontAwesomeIcons.comment,
                  size: 25.0,
                ),
                onTap: () {
                  commentsPage(context);
                }),
                new Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child:  Text("${widget.post["comments_count"]}", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
              ),
            ],
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(left: 20.0, right: 8.0, bottom: 20.0),
                child: new Text("${widget.post["user_email"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                
              ),
              new Expanded(
                child: new Text(widget.post["caption"], style: TextStyle(fontSize: 12)),
              )
            ],
          ),

          
        ]));

      
  }
}

class userAccount extends StatefulWidget {

  var info;
  userAccount(this.info, {Key key}):super(key:key);

  @override
  _userAccountState createState() => _userAccountState();
}

class _userAccountState extends State<userAccount> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Column(
        children: <Widget>[
          Image.network(widget.info["profile_image_url"], height: 20,),
          Text(widget.info["email"].toString()),
          Text(widget.info["bio"].toString())
        ],
      ),
    );
  }
}

class imageScreen extends StatefulWidget {
  var token;
 
  imageScreen(this.token, {Key key}): super(key:key);

  @override
  _imageScreenState createState() => _imageScreenState();
}

class _imageScreenState extends State<imageScreen> {

  var captionCtrl = TextEditingController();
  MainAxisAlignment alignment = MainAxisAlignment.center;
  File _image;
  Future _getImage() async {
    print(_image.toString() == "null");
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
      _image = image;
    });
  }

  Future<Response> upload(var token) async{
    FormData formData = new FormData.from({
      "caption": captionCtrl.text.toString(),
      "image": new UploadFileInfo(_image, _image.path)
    });
    var response = await Dio().post("http://serene-beach-48273.herokuapp.com/api/v1/posts", data: formData, options: Options(
    headers: {
      HttpHeaders.authorizationHeader: "Bearer $token"
    },
  ),);

    print(response);
    return response;
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        child: new Column(
          mainAxisAlignment: alignment,
          children: <Widget>[
            new Center(
              child: (_image.toString() == "null") == true ? 
                  MaterialButton(
                    textColor: Colors.white,
                    child: Text("Select Image"),
                    color: Colors.blue,
                    onPressed: (){
                      _getImage();
                    },
                  )
                : 
                  new Container(
                    child: new Column(
                      children: <Widget>[
                        Image.file(_image),
                        TextField(
                            controller: captionCtrl, 
                            autocorrect: false,
                            style: TextStyle(fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              hintText: "Caption"  
                            ),
                            
                          ),
                        MaterialButton(
                          child: Text("Upload"),
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: (){
                            if(_image.toString() != "null")
                            {
                              upload(widget.token);
                              setState(() {
                                _image.toString() == "null";
                              });
                              
                            }
                          },
                        )
                      ],
                    ) 
                    ),
            )
          ],
        ),
      )
    );
    /*
    return Container(
      child: new Column(
        children: <Widget>[
          new Center(
            child: (_image.toString() == "null") == true ? Container(child: Text("No image"),) : new Container(child: Image.file(_image)),
          ),
          MaterialButton(
            child: Text("+"),
            color: Colors.red,
            onPressed: (){
              _getImage();
            },
          ),
          MaterialButton(
            child: Text("Upload"),
            color: Colors.blue,
            onPressed: (){
              if(_image.toString() != "null")
              {
                upload(widget.token);
              }
            },
          )
        ],
      )
    );*/
  }
}

class Feed extends StatefulWidget {
  List<dynamic> posts;
  var token;
  Feed(this.posts, this.token, {Key, key}): super(key:key);
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {

  Future<List<dynamic>> getPosts(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";

    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    var posts_json =jsonDecode(response.body);
    print("Got new posts");
    widget.posts = posts_json;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Fluttergram',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: new RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
                itemCount: widget.posts.length,
                itemBuilder: (BuildContext ctxt, int index) {
                return InstaPost(widget.posts[index], widget.token.toString());
                }
              ),
      ) 
      
    );
    
  }

  Future<Null> _refresh() async {
    await _getFeed();
    setState(() {

    });

    return;
  }

  _getFeed() async {
    
    setState(() {
      getPosts(widget.token);
    });
  }
}

class _SecondScreen extends StatefulWidget{
  List<dynamic> posts;
  List<dynamic> myPosts;
  var token;
  var id;
  var myInfo;
  _SecondScreen(this.posts, this.myPosts, this.token, this.myInfo, {Key key}) :super(key:key);

  @override
  SecondScreen createState() => SecondScreen();
  
}

class SecondScreen extends State<_SecondScreen> {
  
  PageController pageController = PageController();
  int _page = 0;
  
  @override
  Widget build(BuildContext context){
    return new Scaffold(
            body: new PageView(
              children: <Widget>[
                new Container(
                  color: Colors.white,
                  child: new Feed(widget.posts, widget.token),
                  ),
                new Container(
                  color: Colors.white,
                  child: imageScreen(widget.token),
                ),
                new Container(
                  color: Colors.white,
                  child: new userAccountPage(widget.myInfo, widget.token, widget.myPosts, true),
                ),
              ],
              controller: pageController,
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: pageChanged,
            ),
            bottomNavigationBar: new CupertinoTabBar(
              activeColor: Colors.orange,
              items: <BottomNavigationBarItem>[
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.home,
                        color: (_page == 0) ? Colors.black : Colors.grey),
                    title: new Container(height: 0.0),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.add_circle,
                        color: (_page == 1) ? Colors.black : Colors.grey),
                    title: new Container(height: 0.0),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.person,
                        color: (_page == 2) ? Colors.black : Colors.grey),
                    title: new Container(height: 0.0),
                    backgroundColor: Colors.white),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          );

    



    /*
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "My Profile",),
                Tab(
                  child: new Container(
                    child: Icon(Icons.camera),
                  )),
                Tab(text: "Posts"),
              ],
            ),
            title: Text('Tabs'),
          ),
          body: TabBarView(
            children: [
              new Container(
                child: new Column(
                  children: <Widget>[
                    Expanded(child: userAccount(widget.myInfo)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.myPosts.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                        return InstaPost(widget.myPosts[index], widget.token.toString());
                        }
                      ),
                    )
                  ],
                ),

              ),
              
              new Container(
                child: new Column(
                  children: <Widget>[
                    Expanded(
                      child: imageScreen(widget.token.toString())
                    )
                  ],
                ),
              ),
              ListView.builder(
                itemCount: widget.posts.length,
                itemBuilder: (BuildContext ctxt, int index) {
                return InstaPost(widget.posts[index], widget.token.toString());
                }
              )
            ],
          ),
        ),
      ),
    );
    */
  }


  void navigationTapped(int page) {
          //Animating Page
          pageController.jumpToPage(page);
    }

    void pageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }

      @override
      void initState() {
        super.initState();
        pageController = new PageController();
      }

      @override
      void dispose() {
        super.dispose();
        pageController.dispose();
      }

}

class MyHomePage extends StatelessWidget{
  var userCtrl = TextEditingController();
  var passCtrl =TextEditingController();

  void stuff(context) async {
    var token = await login();
    var allPosts = await getPosts(token);
    var myPosts = await getPosts2(token);
    var userInfo = await getUserInfo(token);

    Navigator.push(context, MaterialPageRoute(builder: (context) => _SecondScreen(allPosts, myPosts, token, userInfo)));

  }

  Future<dynamic> getUserInfo(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_account";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer ${token}"});

    var id = jsonDecode(response.body);
    print(id);
    return id;

  }


  Future<String> getID(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_account";
    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    var id = jsonDecode(response.body)["id"].toString();
    return id;

  }

  Future<String> login() async{
    var user = userCtrl.text;
    var pass = passCtrl.text;
    var url = "https://serene-beach-48273.herokuapp.com/api/login?username=${user}&password=${pass}";

    var response = await http.get(url);
    var token = jsonDecode(response.body)["token"].toString();
    return token;

  }

  Future<List<dynamic>> getPosts(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/posts";

    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    var posts_json =jsonDecode(response.body);
    return posts_json;
  }

  Future<List<dynamic>> getPosts2(token) async{
    var url = "https://serene-beach-48273.herokuapp.com/api/v1/my_posts";

    var response = await http.get(url, headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

    var posts_json =jsonDecode(response.body);
    return posts_json;
  }

  @override
  Widget build(BuildContext context){
      return Scaffold(
      body: new Center(
        child: new Padding(
          padding: const EdgeInsets.only(top: 240.0),
          child: new Column(
            children: <Widget>[
              new Text(
                'Fluttergram',
                style: new TextStyle(
                    fontSize: 70.0,
                    fontFamily: "Billabong",
                    color: Colors.black),
              ),
              new Padding(padding: const EdgeInsets.only(bottom: 50.0)),
              new Padding(
                padding: const EdgeInsets.only(right: 50.0, left: 50.0),
                child: new Column(
                  children: <Widget>[
                    TextField(
                      controller: userCtrl, 
                      autocorrect: false,
                      style: TextStyle(fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        hintText: "Username"
                      ),
                    ),
                    TextField(
                      controller: passCtrl, 
                      obscureText: true, 
                      autocorrect: false,
                      style:TextStyle(fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        hintText: "Password"
                      ),
                    ),
                    RaisedButton(
                      child: Text("Login"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      onPressed: (){stuff(context);},
                    ), 
                    ],
                    ),
                  ),
              
            ],
          ),
        ),
      ),
    );
  }

}
