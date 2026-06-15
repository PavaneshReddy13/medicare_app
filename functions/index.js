const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// 1. onAppointmentBooked -> notify receptionist
exports.onAppointmentBooked = functions.firestore
  .document('appointments/{appointmentId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const payload = {
      notification: {
        title: 'New Appointment Booked',
        body: `Patient ${data.patientName} just booked an OP slot at ${data.slotTime}.`,
      }
    };
    return admin.messaging().sendToTopic(`hospital_${data.hospitalId}_receptionists`, payload);
  });

// 2. onOPAccepted -> notify doctor
exports.onOPAccepted = functions.firestore
  .document('appointments/{appointmentId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    if (before.status === 'booked' && after.status === 'accepted') {
      const payload = {
        notification: {
          title: 'OP Accepted',
          body: `Reception accepted OP for ${after.patientName}. Token: ${after.tokenNumber}.`,
        }
      };
      return admin.messaging().sendToTopic(`doctor_${after.doctorId}`, payload);
    }
    return null;
  });

// 3. onPrescriptionCreated -> notify patient
exports.onPrescriptionCreated = functions.firestore
  .document('prescriptions/{prescriptionId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const payload = {
      notification: {
        title: 'New Prescription Generated',
        body: `Your doctor has finalized your prescription. Tap to view and set daily reminders.`,
      }
    };
    return admin.messaging().sendToTopic(`patient_${data.patientId}`, payload);
  });

// 4. onLabRequestCreated -> notify lab technician
exports.onLabRequestCreated = functions.firestore
  .document('lab_requests/{requestId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const payload = {
      notification: {
        title: 'New Lab Test Request',
        body: `Dr. ${data.doctorId} requested a ${data.testType} for ${data.patientName}.`,
      }
    };
    return admin.messaging().sendToTopic(`hospital_${data.hospitalId}_labtechs`, payload);
  });

// 5. onLabReportUploaded -> notify doctor and patient
exports.onLabReportUploaded = functions.firestore
  .document('lab_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    if (before.status === 'pending' && after.status === 'completed') {
      const payload = {
        notification: {
          title: 'Lab Results Ready',
          body: `Results for ${after.testType} are now uploaded and available.`,
        }
      };
      await admin.messaging().sendToTopic(`doctor_${after.doctorId}`, payload);
      return admin.messaging().sendToTopic(`patient_${after.patientId}`, payload);
    }
    return null;
  });

// 6. onStaffApproved -> notify staff member
exports.onStaffApproved = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();
    const uid = context.params.userId;
    if (before.status === 'pending' && after.status === 'approved') {
      const payload = {
        notification: {
          title: 'Account Approved!',
          body: `Your account as a ${after.role} has been approved. You may now log in.`,
        }
      };
      return admin.messaging().sendToTopic(`user_${uid}`, payload);
    }
    return null;
  });
