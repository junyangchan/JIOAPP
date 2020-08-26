import * as functions from 'firebase-functions';
import * as admin from'firebase-admin';

admin.initializeApp();

export const onConversationsCreated = functions.firestore.document("conversations/{conversationsID}").onCreate((snapshot,context)=>{
    const data = snapshot.data();
    const conversationsID = context.params.conversationsID;
    if (data){
        const members = data.members;
        for(let index = 0; index <members.length;index++){
            const currentUserID = members[index];
            const remainingUserIDs = members.filter((u:string)=> u!==currentUserID)
            remainingUserIDs.forEach((m:string) => {
                return admin.firestore().collection("users").doc(m).get().then((_doc)=>{
                    const userData = _doc.data();
                    if(userData){
                        return admin.firestore().collection("users").doc(currentUserID).collection("Conversations").doc(m).create(
                            {
                                "conversationsID": conversationsID,
                                "image": userData.photoUrl,
                                "name":userData.displayName,
                                "unseenCount":0,
                                "lastMessage": "",
                                "timestamp": null,
                                "type": "",
                                "receiverID": m,
                            }
                        );
                    }
                    return null;
                }).catch(()=>{return null});
            });
        }
    }
    return null;
});

export const onConversationUpdated = functions.firestore.document("conversations/{conversationsID}").onUpdate((change,context)=>{
    let data = change?.after.data();
    let conversationID = context.params.conversationsID;
    if(data){
        let members = data.members;
        let lastMessage = data.messages[data.messages.length-1];
        const idFrom = lastMessage.senderID;
        const idTo = members.filter((u:string)=> u!==idFrom);
        const contentMessage = lastMessage.content;

    // Get push token user to (receive)
    for(let i=0; i<idTo.length; i++){
        admin.firestore().collection('users').where('uid', '==', idTo[i]).get().then(querySnapshot => {
            querySnapshot.forEach(userTo => {
            console.log(`Found user to: ${userTo.data().displayName}`)
            if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
                // Get info user from (sent)
                return admin.firestore().collection('users').where('uid', '==', idFrom).get().then(querySnapshot2 => {
                    querySnapshot2.forEach(userFrom => {
                    console.log(`Found user from: ${userFrom.data().displayName}`)
                    const payload = {
                        notification: {
                            title: `"${userFrom.data().displayName}"`,
                            body: contentMessage,
                            badge: '1',
                            sound: 'default',
                            click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        },
                        data: {
                            type:"Chat",
                            conversationID: conversationID,
                            receiverID: userFrom.data().uid,
                            receiverName: userFrom.data().displayName,
                            receiverImage: userFrom.data().photoUrl != null? userFrom.data().photoUrl:"None",
                        },
                    }
                    // Let push to the target device
                    return admin.messaging().sendToDevice(userTo.data().pushToken, payload).then(response => {
                        console.log('Successfully sent message:', response)
                        })
                        .catch(error => {
                        console.log('Error sending message:', error);
                        return null;
                        })
                    })
                }).catch(()=>{return null})
            } else {
                console.log('Can not find pushToken target user')
                return null;
            }
            })
        }).catch(()=> {return null})
        }
        for(let index =0; index<members.length;index++){
            let currentUserID = members[index];
            let remainingUserIDs = members.filter((u:string)=> u!== currentUserID)
            remainingUserIDs.forEach((u:string) => {
                return admin.firestore().collection("users").doc(currentUserID).collection("Conversations").doc(u).update({
                    "lastMessage": lastMessage.content,
                    "timestamp": lastMessage.timestamp,
                    "type": lastMessage.type,
                    "unseenCount": admin.firestore.FieldValue.increment(1),
                });
            });
        }
    }
    return null;
});

exports.eventscleanup = functions.pubsub.schedule('every 1 hours').onRun(context => {
    let ref = admin.firestore().collection("events");
    let now = new Date();
    console.log(now.getTime());
    let oldEventsQuery = ref.where('startDate',"<=", now.getTime());
    oldEventsQuery.get().then(function(snapshot){
        snapshot.docs.forEach(function(child){
            console.log(child.id);
            let value = child.data();
            let participants = value['participants'];
            for(let index =0; index<participants.length;index ++){
                void admin.firestore().collection("users").doc(`${participants[index]}/events/self/Past/${child.id}`).set(value);
                let docRef = admin.firestore().collection("users").doc(participants[index]);
                docRef.get().then(function(_snapshot){
                    let userData = _snapshot.data();
                    let lst = userData?.categoryLevels;
                    let found = false;
                    for(let i = 0; i<lst.length;i++){
                        console.log(lst[i].category);
                        console.log(value.category);
                        if(lst[i].category['name'] == value.category['name']){
                            lst[i].level +=1 ;
                            found = true;
                            break;
                        }
                    }
                    if(!found){
                        lst.push({'category':value.category,'level':1})
                    }
                    let exp = userData?.exp;
                    let newExp = exp + 5/(Math.floor(exp/10)) +1;
                    let percent = (newExp % 10)/10;
                    void docRef.update('percent',percent);
                    void docRef.update("exp",newExp);
                    void docRef.update("categoryLevels",lst);
                }).catch(()=>{return null});
                void admin.firestore().collection("users").doc(participants[index]).collection('events/self/Current').doc(child.id).delete();
            }
            admin.firestore().collection('events').doc(child.id).collection('InviteList').get().then((_snapshot) => {
                _snapshot.docs.forEach((documentsnapshot) =>{
                    documentsnapshot.ref.delete().then().catch(()=>{return null});
                });
            }).catch(()=>{return null});
            void admin.firestore().collection('events').doc(child.id).delete();
            void admin.firestore().collection('groupConversations').doc(child.id).delete();
        })
    }).catch(()=>{return null});
});

exports.oninvitelistcreated = functions.firestore.document("events/{eventId}/InviteList/{invitelistID}").onCreate((snapshot,context)=>{
    const data = snapshot.data();
    const eventID = context.params.eventId;
    if (data){
        const userTo = data.inviteList;
        const userFrom = data.userFrom;
        admin.firestore().collection("events").doc(eventID).get().then((_data)=>{
            let event = _data.data();
            if (event){
                let name = event.name;
                admin.firestore().collection("users").doc(userFrom).get().then((_doc)=>{
                    const userData = _doc.data();
                    if(userData){
                        const payload = {
                            notification: {
                                title: `"${userData.displayName} has invited you to an event"`,
                                body: name,
                                badge: '1',
                                sound: 'default',
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            },
                            data: {
                                type:"Event",
                                eventID: eventID,
                            },
                        }
                        for(let index = 0; index <userTo.length;index++){
                            const currentUserID = userTo[index];
                            admin.firestore().collection("users").doc(currentUserID).get().then((_document) =>{
                                const user = _document.data();
                                    if(user){
                                        if(user.pushToken){
                                            return admin.messaging().sendToDevice(user.pushToken, payload).then(response => {
                                                console.log('Successfully sent message:', response)
                                                }).catch(error => {
                                                    console.log('Error sending message:', error);
                                                    return null;})
                                        }else{
                                            console.log('No push token detected')
                                            return null;
                                        }
                                    }else{
                                        console.log('No user detected')
                                        return null;
                                    }
                                }).catch(()=> {return null});
                            }
                        }
                    }).catch(()=> {return null});
        }
    }).catch(()=> {return null});
    }
    return null;
});

export const onGroupConversationUpdated = functions.firestore.document("groupConversations/{conversationsID}").onUpdate((change,context)=>{
    let data = change?.after.data();
    let conversationID = context.params.conversationsID;
    if(data){
        let lastMessage = data.messages[data.messages.length-1];
        const idFrom = lastMessage.senderID;
        const contentMessage = lastMessage.content;

        // Get info user from (sent)
        return admin.firestore().doc(`users/${idFrom}/events/self/Current/${conversationID}`).get().then(_event => {
            admin.firestore().doc(`users/${idFrom}`).get().then(_userFrom => {
                let userName = _userFrom.data()?.displayName;
                let eventName = _event.data()?.name;
                console.log(`Found user from: ${eventName}`)
                const payload = {
                            notification: {
                                title: eventName,
                                body: `${userName}: ${contentMessage}`,
                                badge: '1',
                                sound: 'default',
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            },
                            data: {
                                type:"Event Chat",
                                conversationID: conversationID,
                            },
                        };
                return admin.messaging().sendToTopic(conversationID,payload).then(response=> {
                    console.log('Successfully sent message:', response)
                }).catch(()=>{return null});
            }).catch(()=> {return null});
        }).catch(()=> {return null});
    }
    return null;
});

exports.onFriendRequest = functions.firestore.document("users/{uid}/friendrequest/{friendID}").onCreate((snapshot,context)=>{
    const yourID = context.params.uid;
    const friendID = context.params.friendID;

    admin.firestore().doc(`users/${friendID}`).get().then(_userFrom => {
                let userName = _userFrom.data()?.displayName;
                console.log(`Found user from: ${userName}`)
                const payload = {
                            notification: {
                                title: 'Friend Request',
                                body: `${userName} has just requested to follow you.`,
                                badge: '1',
                                sound: 'default',
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            },
                            data: {
                                type:"Friend Request",
                                userFrom: friendID,
                            },
                        };

            admin.firestore().doc(`users/${yourID}`).get().then((_document) =>{
                const user = _document.data();
                if(user){
                    if(user.pushToken){
                            return admin.messaging().sendToDevice(user.pushToken, payload).then(response => {
                                    console.log('Successfully sent message:', response)
                                    }).catch(error => {
                                    console.log('Error sending message:', error);
                                        return null;})
                                    }else{
                                        console.log('No push token detected')
                                        return null;
                                    }
                    }else{
                        console.log('No user detected')
                        return null;
                    }                          
                }).catch(()=> {return null});
            }).catch(()=> {return null});
        }
    );
            
exports.onFriendAccepted = functions.firestore.document("users/{uid}/friendlist/{friendID}").onCreate((snapshot,context)=>{
    const yourID = context.params.uid;
    const friendID = context.params.friendID;
    const data = snapshot.data();
    if(!data['AcceptedByMe']){
        admin.firestore().doc(`users/${friendID}`).get().then(_userFrom => {
                    let userName = _userFrom.data()?.displayName;
                    console.log(`Found user from: ${userName}`)
                    const payload = {
                                notification: {
                                    title: 'Friend Request Accepted',
                                    body: `${userName} has accepted your friend request.`,
                                    badge: '1',
                                    sound: 'default',
                                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                },
                                data: {
                                    type:"Friend Request Accepted",
                                    userFrom: friendID,
                                },
                            };

            admin.firestore().doc(`users/${yourID}`).get().then((_document) =>{
                const user = _document.data();
                if(user){
                    if(user.pushToken){
                            return admin.messaging().sendToDevice(user.pushToken, payload).then(response => {
                                    console.log('Successfully sent message:', response)
                                    }).catch(error => {
                                    console.log('Error sending message:', error);
                                        return null;})
                                    }else{
                                        console.log('No push token detected')
                                        return null;
                                    }
                    }else{
                        console.log('No user detected')
                        return null;
                    }
                }).catch(()=> {return null});
            }).catch(()=> {return null});
        }
    });

exports.onJIO = functions.firestore.document("users/{uid}/jios/{jioedID}").onCreate((snapshot,context)=>{
    const hostID = context.params.uid;
    const jioedID = context.params.jioedID;
        admin.firestore().doc(`users/${hostID}`).get().then(_userFrom => {
                    let userName = _userFrom.data()?.displayName;
                    console.log(`Found user from: ${userName}`)
                    const payload = {
                                notification: {
                                    title: 'JIOED!',
                                    body: `${userName} wants to start an event with you.`,
                                    badge: '1',
                                    sound: 'default',
                                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                },
                                data: {
                                    type:"JIO",
                                    userFrom: hostID,
                                },
                            };

            admin.firestore().doc(`users/${jioedID}`).get().then((_document) =>{
                const user = _document.data();
                if(user){
                    if(user.pushToken){
                            return admin.messaging().sendToDevice(user.pushToken, payload).then(response => {
                                    console.log('Successfully sent message:', response)
                                    }).catch(error => {
                                    console.log('Error sending message:', error);
                                        return null;})
                                    }else{
                                        console.log('No push token detected')
                                        return null;
                                    }
                    }else{
                        console.log('No user detected')
                        return null;
                    }
                }).catch(()=> {return null});
            }).catch(()=> {return null});
    });