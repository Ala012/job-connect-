# Guide d'intégration Firebase Cloud Messaging (FCM)

## Configuration de Firebase Cloud Messaging pour les notifications push

Ce guide explique comment intégrer Firebase Cloud Messaging (FCM) pour les notifications push en production.

## Installation des dépendances

Ajoutez ces packages à votre `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  flutter_local_notifications: ^15.1.0
  timezone: ^0.9.2
```

## Configuration Firebase

### 1. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Créer un nouveau projet
3. Ajouter une application Flutter
4. Télécharger les fichiers de configuration (google-services.json pour Android et GoogleService-Info.plist pour iOS)

### 2. Configuration Android

Ajoutez `google-services.json` à `android/app/`

Modifiez `android/app/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Modifiez `android/build.gradle`:
```gradle
plugins {
    id 'com.google.gms.google-services' version '4.4.0' apply false
}
```

### 3. Configuration iOS

Ajoutez `GoogleService-Info.plist` à `ios/Runner/` en utilisant Xcode.

## Implémentation dans Flutter

### 1. Service Firebase Messaging

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = 
      FirebaseMessagingService._internal();
  
  late FirebaseMessaging _firebaseMessaging;

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal() {
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = 
        await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carryForwardToken: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
      _handleMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on notification');
      _navigateToScreen(message);
    });
  }

  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      NotificationService().showNotification(
        id: notification.hashCode,
        title: notification.title ?? 'JobConnect',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  void _navigateToScreen(RemoteMessage message) {
    // Navigate based on message data
    final data = message.data;
    
    if (data['type'] == 'application_status') {
      // Navigate to application history
    } else if (data['type'] == 'new_job') {
      // Navigate to job detail
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

// Top-level function for background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  _handleMessage(message);
}
```

### 2. Initialiser dans main.dart

```dart
import 'services/firebase_messaging_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize local notifications
  await NotificationService().initNotifications();
  
  // Initialize Firebase Messaging
  await FirebaseMessagingService().initialize();
  
  runApp(const MyApp());
}
```

## Envoi de notifications du backend

### Exemple Node.js/NestJS

```typescript
import * as admin from 'firebase-admin';

export async function sendNotification(
  deviceToken: string,
  title: string,
  body: string,
  data?: Record<string, string>,
) {
  const message = {
    notification: { title, body },
    data: data || {},
    token: deviceToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Message sent successfully:', response);
    return response;
  } catch (error) {
    console.error('Error sending message:', error);
    throw error;
  }
}

// Send to multiple devices
export async function sendMulticastNotification(
  deviceTokens: string[],
  title: string,
  body: string,
  data?: Record<string, string>,
) {
  const message = {
    notification: { title, body },
    data: data || {},
  };

  try {
    const response = await admin.messaging().sendMulticast({
      ...message,
      tokens: deviceTokens,
    });
    
    console.log(`${response.successCount} notifications sent successfully`);
    return response;
  } catch (error) {
    console.error('Error sending multicast message:', error);
    throw error;
  }
}

// Subscribe devices to topic
export async function subscribeToTopic(
  deviceTokens: string[],
  topic: string,
) {
  try {
    const response = await admin.messaging().subscribeToTopic(
      deviceTokens,
      topic,
    );
    console.log(`Subscribed to topic '${topic}'`);
    return response;
  } catch (error) {
    console.error('Error subscribing to topic:', error);
    throw error;
  }
}

// Send to topic
export async function sendToTopic(
  topic: string,
  title: string,
  body: string,
  data?: Record<string, string>,
) {
  const message = {
    notification: { title, body },
    data: data || {},
    topic,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Message sent to topic:', response);
    return response;
  } catch (error) {
    console.error('Error sending message to topic:', error);
    throw error;
  }
}
```

## Topics recommandés

```
- user_${userId}              // Notifications personnelles
- job_${jobId}                // Notifications pour cette offre
- company_${companyId}        // Notifications pour cette entreprise
- new_jobs_${location}        // Nouvelles offres par location
- application_status          // Statut des candidatures
```

## Tester les notifications

### Debug dans Flutter

```dart
// Afficher les messages reçus
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Message received:');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
});
```

### Tester via Firebase Console

1. Aller dans Firebase Console
2. Cloud Messaging
3. Envoyer un test de notification
4. Sélectionner l'app et les appareils
5. Composer le message

## Points importants

- ✅ Gérer les permissions de notifications pour Android 13+
- ✅ Implémenter des handlers pour les messages en foreground et background
- ✅ Tester sur les appareils réels (pas sur le simulateur)
- ✅ Gérer les cas où l'app est tuée ou fermée
- ✅ Ajouter une logique d'opt-in/opt-out pour les utilisateurs

## Ressources

- [Firebase Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
- [Flutter Firebase Tutorial](https://firebase.flutter.dev)
- [FCM Best Practices](https://firebase.google.com/docs/cloud-messaging)
