import 'package:in_app_database/src/references/base.dart';

void main() {
  final database = InAppDatabaseInstance.i;

  for (int i = 1; i <= 10; i++) {
    // Create new post (posts/post_id)
    database.ref("posts").document("post_id_$i").set({
      "id": "post_id_$i",
      "title": "This is a new title of $i",
      "content": "This is a new content of $i",
      "author_id": "1",
      "category": "Technology",
      "tags": ["programming", "javascript"],
      "created_at": "2024-02-06T00:00:00Z",
      "updated_at": "2024-02-06T00:00:00Z",
      "published": true,
    }).then(documentLog);
  }

  return;
  // Update post by id (posts/post_id)
  database.ref("posts").document("post_id_1").update({
    "title": "Updated Blog Post",
    "content": "This post has been updated!",
  }).then(documentLog);

  // Delete post by id (posts/post_id)
  database.ref("posts").document("post_id_2").delete().then(documentLog);

  // Retrieve post by id (posts/post_id)
  database.ref("posts").document("post_id_3").get().then(documentLog);

  // Retrieve all post (posts)
  database.ref("posts").get().then(collectionLog);

  // Create new post comment (posts/post_id/comments/comment_id)
  for (int i = 1; i<=5;i++){
    database
        .ref("posts")
        .document("post_id_4")
        .collection("comments")
        .document("comment_id_$i")
        .set({
      "id": "comment_id_$i",
      "post_id": "post_id_4",
      "content": "Great post!",
      "author_id": "2",
      "created_at": "2024-02-06T00:00:00Z",
      "likes": [],
      "dislikes": [],
    }).then(documentLog);
  }

  // Update post comment by id (posts/post_id/comments/comment_id)
  database
      .ref("posts")
      .document("post_id_4")
      .collection("comments")
      .document("comment_id_1")
      .update({
    "content": "This is updated comment!",
  }).then(documentLog);

  // Delete post comment by id (posts/post_id/comments/comment_id)
  database
      .ref("posts")
      .document("post_id_4")
      .collection("comments")
      .document("comment_id_2")
      .delete()
      .then(documentLog);

  // Retrieve post comment by id (posts/post_id/comments/comment_id)
  database
      .ref("posts")
      .document("post_id_4")
      .collection("comments")
      .document("comment_id_3")
      .get()
      .then(documentLog);

  // Retrieve all post comments (posts/post_id/comments)
  database
      .ref("posts")
      .document("post_id_4")
      .collection("comments")
      .get()
      .then(collectionLog);

  print(database.collections);
}

void collectionLog(InAppQuerySnapshot value) {
  print(value.docs);
}

void documentLog(InAppDocumentSnapshot value) {
  print(value.data);
}
