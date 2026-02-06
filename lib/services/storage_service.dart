import '../models/academic_session.dart';
import '../models/assignment.dart';

// Abstract storage so we can swap implementations (e.g. shared_preferences vs future backend)
abstract class StorageService {
  Future<List<Assignment>> loadAssignments();
  Future<void> saveAssignments(List<Assignment> assignments);

  Future<List<AcademicSession>> loadSessions();
  Future<void> saveSessions(List<AcademicSession> sessions);
}
