import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '/core/data/datasources/gemini_remote_datasource.dart';
import '/core/services/speech_service.dart';
import '/core/services/tts_services.dart';
import '/features/auth/data/datasources/auth_remote_datasource.dart';
import '/features/auth/data/datasources/user_remote_datasource.dart';
import '/features/auth/data/models/user_profile_model.dart';
import '/features/auth/domain/repositories/auth_repository.dart';
import '/features/auth/data/repositories/auth_repository_impl.dart';
import '/features/auth/domain/repositories/user_repository.dart';
import '/features/auth/data/repositories/user_repository_impl.dart';
import '/features/auth/domain/usecases/login_usecase.dart';
import '/features/auth/domain/usecases/signup_usecase.dart';
import '/features/auth/domain/usecases/logout_usecase.dart';
import '/features/auth/domain/usecases/reset_password_usecase.dart';
import '/features/auth/domain/usecases/get_current_user_usecase.dart';
import '/features/scan_object/domain/repositories/object_detection_repository.dart';
import '/features/scan_object/data/repositories/object_detection_repository_impl.dart';
import '/features/scan_object/domain/usecases/detect_objects_usecase.dart';
import '/features/scan_object/domain/usecases/speak_detected_object_usecase.dart';
import '/features/read_text/domain/repositories/text_recognition_repository.dart';
import '/features/read_text/data/repositories/text_recognition_repository_impl.dart';
import '/features/read_text/domain/usecases/read_text_from_image_usecase.dart';
import '/features/read_text/domain/usecases/speak_text_usecase.dart';
import '/features/history/data/datasources/history_local_datasource.dart';
import '/features/history/data/repositories/history_repository_impl.dart';
import '/features/history/domain/repositories/history_repository.dart';
import '/features/history/domain/usecases/save_history_item_usecase.dart';
import '/features/history/domain/usecases/get_history_items_usecase.dart';
import '/features/history/domain/usecases/delete_history_item_usecase.dart';
import '/features/history/domain/usecases/clear_history_usecase.dart';
import '/features/person_recognition/data/datasources/person_local_datasource.dart';
import '/features/person_recognition/data/repositories/person_recognition_repository_impl.dart';
import '/features/person_recognition/domain/repositories/person_recognition_repository.dart';
import '/features/person_recognition/domain/usecases/enroll_person_usecase.dart';
import '/features/person_recognition/domain/usecases/get_all_team_members_usecase.dart';
import '/features/person_recognition/domain/usecases/match_person_usecase.dart';
import '/features/person_recognition/domain/usecases/speak_person_name_usecase.dart';
import '/features/person_recognition/domain/usecases/detect_face_usecase.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.read(firebaseAuthProvider));
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(ref.read(firestoreProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.read(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource);
});

// Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUseCase(repository);
});

final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return SignupUseCase(authRepository, userRepository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

final currentUserProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  final user = ref.read(getCurrentUserUseCaseProvider)();

  if (user == null) return null;

  final userRepository = ref.read(userRepositoryProvider);
  final userEntity = await userRepository.getUser(user.uid);
  return userEntity as UserProfileModel?;
});

final generativeModelProvider = Provider<GenerativeModel>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  return GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: apiKey,
  );
});

final geminiRemoteDataSourceProvider = Provider<GeminiRemoteDataSource>((ref) {
  final model = ref.read(generativeModelProvider);
  return GeminiRemoteDataSource(model);
});

// Services
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});

// Scan Object
final objectDetectionRepositoryProvider = Provider<ObjectDetectionRepository>((ref) {
  final geminiDataSource = ref.read(geminiRemoteDataSourceProvider);
  return ObjectDetectionRepositoryImpl(geminiDataSource);
});

final detectObjectsUseCaseProvider = Provider<DetectObjectsUseCase>((ref) {
  final repository = ref.read(objectDetectionRepositoryProvider);
  return DetectObjectsUseCase(repository);
});

final speakDetectedObjectUseCaseProvider = Provider<SpeakDetectedObjectUseCase>((ref) {
  final ttsService = ref.read(ttsServiceProvider);
  return SpeakDetectedObjectUseCase(ttsService);
});

// Read Text
final textRecognitionRepositoryProvider = Provider<TextRecognitionRepository>((ref) {
  final geminiDataSource = ref.read(geminiRemoteDataSourceProvider);
  return TextRecognitionRepositoryImpl(geminiDataSource);
});

final readTextFromImageUseCaseProvider = Provider<ReadTextFromImageUseCase>((ref) {
  final repository = ref.read(textRecognitionRepositoryProvider);
  return ReadTextFromImageUseCase(repository);
});

final speakTextUseCaseProvider = Provider<SpeakTextUseCase>((ref) {
  final ttsService = ref.read(ttsServiceProvider);
  return SpeakTextUseCase(ttsService);
});

// History
final historyLocalDataSourceProvider = Provider<HistoryLocalDataSource>((ref) {
  return HistoryLocalDataSource();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final localDataSource = ref.read(historyLocalDataSourceProvider);
  return HistoryRepositoryImpl(localDataSource: localDataSource);
});

final saveHistoryItemUseCaseProvider = Provider<SaveHistoryItemUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return SaveHistoryItemUseCase(repository);
});

final getHistoryItemsUseCaseProvider = Provider<GetHistoryItemsUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return GetHistoryItemsUseCase(repository);
});

final deleteHistoryItemUseCaseProvider = Provider<DeleteHistoryItemUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return DeleteHistoryItemUseCase(repository);
});

final clearHistoryUseCaseProvider = Provider<ClearHistoryUseCase>((ref) {
  final repository = ref.read(historyRepositoryProvider);
  return ClearHistoryUseCase(repository);
});

// Person Recognition
final personLocalDataSourceProvider = Provider<PersonLocalDataSource>((ref) {
  return PersonLocalDataSource();
});

final personRecognitionRepositoryProvider = Provider<PersonRecognitionRepository>((ref) {
  final localDataSource = ref.read(personLocalDataSourceProvider);
  final geminiRemoteDataSource = ref.read(geminiRemoteDataSourceProvider);
  return PersonRecognitionRepositoryImpl(
    localDataSource: localDataSource,
    geminiRemoteDataSource: geminiRemoteDataSource,
  );
});

final enrollPersonUseCaseProvider = Provider<EnrollPersonUseCase>((ref) {
  final repository = ref.read(personRecognitionRepositoryProvider);
  return EnrollPersonUseCase(repository);
});

final getAllTeamMembersUseCaseProvider = Provider<GetAllTeamMembersUseCase>((ref) {
  final repository = ref.read(personRecognitionRepositoryProvider);
  return GetAllTeamMembersUseCase(repository);
});

final matchPersonUseCaseProvider = Provider<MatchPersonUseCase>((ref) {
  final repository = ref.read(personRecognitionRepositoryProvider);
  return MatchPersonUseCase(repository);
});

final speakPersonNameUseCaseProvider = Provider<SpeakPersonNameUseCase>((ref) {
  final ttsService = ref.read(ttsServiceProvider);
  return SpeakPersonNameUseCase(ttsService);
});

final detectFaceUseCaseProvider = Provider<DetectFaceUseCase>((ref) {
  return DetectFaceUseCase();
});