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
  bool isLoading = false;
  ContentPublishingLimit? contentPublishingLimit;

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Quota Usage: ${contentPublishingLimit?.data.first.quotaUsage} / ${contentPublishingLimit?.data.first.config?.quotaTotal}\nDuration: ${Utils.durationToHMS(Duration(seconds: contentPublishingLimit?.data.first.config?.quotaDuration ?? 0))}',
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _loadData() async {
    isLoading = true;
    setState(() {});

    contentPublishingLimit = await InstagramAPIs().getContentPublishingLimit();
    isLoading = false;
    setState(() {});
  }
}
