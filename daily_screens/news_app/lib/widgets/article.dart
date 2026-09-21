class Article {
  final String author;
  final String timeAgo;
  final String title;
  final String category;
  final String imagePath;
  final int views;
  final int comments;
  final int likes;
  final String content;

  Article({
    required this.author,
    required this.timeAgo,
    required this.title,
    required this.category,
    required this.imagePath,
    required this.views,
    required this.comments,
    required this.likes,
    required this.content,
  });
}

List<Article> sampleArticles = [
  Article(
    author: 'Pulakit Bararia',
    timeAgo: '6 hours ago',
    title: 'How to Declutter Your Digital Life',
    category: 'Technology',
    imagePath: 'lib/assets/images/back.png',
    views: 5,
    comments: 3,
    likes: 1,
    content:
        'We have gone through a long way since the development of the internet. What started with a simple network connecting a few people or a small community has changed into a massive server connecting billions of people. We all are going through a digital boom right now because of the advances in artificial intelligence, Cheaper internet, and easy access to technological services, all of this has resulted in billions of apps and services aiming for different uses, each of them useful in their ways. The overwhelming option of apps has made us cluttered in our digital lives. There is an app for almost every single aspect of our life from simple messaging to maintaining our health. In this article we will explore various strategies to declutter your digital life and regain control over your technology usage.',
  ),
  Article(
    author: 'Pulakit Bararia',
    timeAgo: '2 days ago',
    title: "The Brain's Battle of Choices",
    category: 'Psychology',
    imagePath: 'lib/assets/images/back.png',
    views: 100,
    comments: 26,
    likes: 45,
    content:
        'Every day we make thousands of decisions, from what to eat for breakfast to complex life choices. Understanding how our brain processes these decisions can help us make better choices and reduce decision fatigue.',
  ),
  Article(
    author: 'Pulakit Bararia',
    timeAgo: '4 days ago',
    title: 'Teenage engineering - The next..',
    category: 'Design',
    imagePath: 'lib/assets/images/back.png',
    views: 100,
    comments: 26,
    likes: 32,
    content:
        'Teenage Engineering has revolutionized the way we think about product design. Their minimalist approach combined with powerful functionality has set new standards in the industry.',
  ),
];
