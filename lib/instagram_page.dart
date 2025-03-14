import 'package:flutter/material.dart';
import 'package:smart_gallery/infra/utils.dart';
import 'package:smart_gallery/instagram_handler.dart';
import 'package:smart_gallery/models/meta_models/content_publishing_limit.dart';

class InstagramPage extends StatefulWidget {
  const InstagramPage({super.key});

  @override
  State<InstagramPage> createState() => _InstagramPageState();
}

class _InstagramPageState extends State<InstagramPage> {
  ContentPublishingLimit? contentPublishingLimit;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(
            'Quota Usage: ${contentPublishingLimit!.data.first.quotaUsage} / ${contentPublishingLimit!.data.first.config.quotaTotal}',
          ),
          Text(
            'Duration: ${Utils.durationToHMS(Duration(seconds: contentPublishingLimit!.data.first.config.quotaDuration))}',
          ),
        ],
      ),
    );
  }

  void _loadData() async {
    contentPublishingLimit = await InstagramAPIs().getContentPublishingLimit();
    setState(() {});
  }
}
