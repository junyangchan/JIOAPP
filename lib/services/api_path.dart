class APIPath {
  static String eventOngoing(String eventId) => 'events/$eventId';
  static String eventsOngoing() => 'events';
  static String eventInviteList(String eventId) => 'events/$eventId/InviteList';
  static String eventsPast(String uid) => 'users/$uid/events/self/Past';
  static String eventPast(String uid,String eventID) => 'users/$uid/events/self/Past/$eventID';
  static String eventsCurrent(String uid) => 'users/$uid/events/self/Current';
  static String eventCurrent(String uid,String eventID) => 'users/$uid/events/self/Current/$eventID';
  static String allConversations() => 'conversations';
  static String conversations(String conversationID) => 'conversations/$conversationID';
  static String profileconversations(String uid) =>'users/$uid/Conversations';
  static String personalconversation(String uid,String conversationID) => 'users/$uid/Conversations/$conversationID';
  static String groupConversation(String eventID) => 'groupConversations/$eventID';
  static String users() => 'users';
  static String user(String uid) => 'users/$uid';
  static String userfriendlist(String uid) => 'users/$uid/friendlist/';
  static String userfriend(String uid, String friend) => 'users/$uid/friendlist/$friend';
  static String userfriendRequest(String uid,String friend) => 'users/$uid/friendrequest/$friend';
  static String userfriendRequestlist(String uid) => 'users/$uid/friendrequest/';
  static String userjios(String uid) => 'users/$uid/jios';
  static String userjioed(String uid, String jioed) => 'users/$uid/jios/$jioed';
  static String userjioRequest(String uid, String friend) => 'users/$uid/jiorequest/$friend';
  static String userjioRequestlist(String uid) => 'user/$uid/jiorequest';
  static String userbojios(String uid) => 'users/$uid/bojios';
  static String userbojioed(String uid, String bojioed) => 'users/$uid/bojios/$bojioed';
  static String categories(String category) => 'categories/$category';
  static String categoryList() => 'categories';
}
