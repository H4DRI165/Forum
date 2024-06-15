import 'dart:convert';
import '../model/comment.dart';
import '../model/post.dart';
import 'package:http/http.dart' as http;

class DataService {
  //  Fetch posts
  Future<List<Post>> fetchPosts() async {
    try {
      // Fetch users data
      final usersResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

      if (usersResponse.statusCode == 200) {
        List<dynamic> usersJson = json.decode(usersResponse.body);

        // Create a map of id to user data for quick lookup
        Map<int, Map<String, dynamic>> userDataMap = {};
        for (var user in usersJson) {
          userDataMap[user['id']] = user;
        }

        // Fetch posts data
        final postsResponse = await http
            .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

        if (postsResponse.statusCode == 200) {
          List<dynamic> postsJson = json.decode(postsResponse.body);

          // Filter posts to include only those with id existing in userDataMap
          List<Post> posts = postsJson
              .where((postJson) => userDataMap.containsKey(postJson['id']))
              .map((postJson) {
            int id = postJson['id'];
            Map<String, dynamic> user = userDataMap[id] ?? {};
            return Post.fromJson(postJson)
              ..name = user['name'] ?? ''
              ..email = user['email'] ?? '';
          }).toList();

          return posts;
        } else {
          throw Exception('Failed to load posts');
        }
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<Post>> searchPosts(String query) async {
    try {
      List<Post> posts = await fetchPosts();

      // Return an empty list when query is empty
      if (query.isEmpty) {
        return [];
      }

      // Filter posts based on query
      List<Post> filteredPosts = posts
          .where(
              (post) => post.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      return filteredPosts;
    } catch (e) {
      throw Exception('Failed to search posts: $e');
    }
  }

  // Fetch comments for a specific post using the user ID
  Future<List<Comment>> fetchCommentsForPost(String id) async {
    try {
      final commentsResponse = await http.get(Uri.parse(
          'https://jsonplaceholder.typicode.com/comments?postId=$id'));

      if (commentsResponse.statusCode == 200) {
        List<dynamic> commentsJson = json.decode(commentsResponse.body);
        List<Comment> comments = commentsJson
            .map((commentJson) => Comment.fromJson(commentJson))
            .toList();

        return comments;
      } else {
        throw Exception('Failed to load comments for post');
      }
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }
}
