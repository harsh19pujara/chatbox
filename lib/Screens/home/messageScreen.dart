import 'package:chatting_app/Screens/home/chatScreen.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return index == 0
                  ? ownStory('assets/images/dp1.png')
                  : storyWidget('assets/images/dp2.png');
            },
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 15,
              itemBuilder: (context, index) {
                return recentChatWidget();
              },
            ),
          ),
        )
      ],
    );
  }

  Widget storyWidget(String img) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage(img),
          radius: 27,
        ),
      ),
    );
  }

  Widget recentChatWidget() {
    return GestureDetector(
      onTap: (){
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatScreen(),));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 70,
        // decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(100)
        // ),
        // color: Colors.grey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Stack(children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/dp3.png'),
                    radius: 26,
                  ),
                  Positioned(
                    bottom: 3,
                    right: 3,
                    child: Container(
                      height: 10,
                      width: 10,
                      // alignment: AlignmentDirectional.bottomEnd,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF0FE16D)),
                    ),
                  )
                ]),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Emilia Clark',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Latest Message Message Message',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        '5 min ago',
                        style: TextStyle(fontSize: 12),
                      ),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFFF04A4C),
                        child: Text('5'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

      ),
    );
  }

  Widget ownStory(String img) {
    return Center(
      child: Stack(
        children: [
          storyWidget(img),
          Positioned(
            bottom: 3,
              right: 3,
              child: Container(
            height: 15,
            width: 15,
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Colors.black,
                size: 15,
              ),
            ),
          ))
        ],
      ),
    );
  }
}
